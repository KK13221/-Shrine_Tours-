import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/model/itinerary_model.dart';
import '../../../trip_planning/data/model/place.dart';
import '../../../trip_planning/data/model/trips.dart';
import '../bloc/itinerary_bloc.dart';
import '../bloc/get_itinerary_bloc.dart';
import '../../../trip_planning/presentation/bloc/trip_planning_bloc.dart';
import '../../../../core/widgets/plan_restriction_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

class ItineraryViewScreen extends StatefulWidget {
  const ItineraryViewScreen({super.key});

  @override
  State<ItineraryViewScreen> createState() => _ItineraryViewScreenState();
}

class _ItineraryViewScreenState extends State<ItineraryViewScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  LatLng? _cityLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  bool _isAddingActivity = false;
  bool _isLoadingRoute = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _durationHourController = TextEditingController();
  final TextEditingController _durationMinController = TextEditingController();

  // Ordered place list for current day (used for Open in Maps)
  List<Place> _currentDayPlaces = [];

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _costController.dispose();
    _durationHourController.dispose();
    _durationMinController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _fetchItinerary();

    // Fetch destination city location for default map centering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final planState = context.read<TripPlanningBloc>().state;
      if (planState.destination.isNotEmpty) {
        _fetchCityLocation(planState.destination);
      }
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _userLocation = LatLng(position.latitude, position.longitude);
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _fetchItinerary() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final blocState = context.read<GetItineraryBloc>().state;

      // If the router already fired FetchItineraryRequested (via route extra),
      // the bloc won't be in Initial state — skip the duplicate fetch.
      if (blocState is! GetItineraryInitial) return;

      // Fallback: router didn't have an itineraryId (no extra passed),
      // so try to get it from TripPlanningBloc state (creation flow).
      final planState = context.read<TripPlanningBloc>().state;
      String? itineraryId;

      if (planState.selectedTripDetails != null &&
          planState.selectedTripDetails!.itineraryId.isNotEmpty) {
        itineraryId = planState.selectedTripDetails!.itineraryId;
      } else if (planState.createdTrip != null &&
          planState.createdTrip!.itineraryId.isNotEmpty) {
        itineraryId = planState.createdTrip!.itineraryId;
      }

      if (itineraryId != null && itineraryId.isNotEmpty) {
        context
            .read<GetItineraryBloc>()
            .add(FetchItineraryRequested(itineraryId));
      }
    });
  }

  Future<void> _fetchCityLocation(String cityName) async {
    try {
      final query = Uri.encodeComponent(cityName);
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=${ApiConstants.googleApiKey}';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;

          if (mounted) {
            setState(() {
              _cityLocation = LatLng(lat, lng);
            });

            // If we have no places yet, move camera to the city
            if (_markers.isEmpty ||
                (_markers.length == 1 &&
                    _markers.any((m) => m.markerId.value == 'start_location'))) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_cityLocation!, 12),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error geocoding city: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Map Update ─ Markers + Real Road Polyline via Directions API
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _updateMap(GetItinerarySuccess state) async {
    final tripPlanningState = context.read<TripPlanningBloc>().state;
    final dayData = state.itinerary.days.firstWhere(
      (d) => d.dayNumber == state.selectedDay,
      orElse: () => state.itinerary.days.first,
    );

    // ── Build ordered places from sorted activities ──
    final sortedActivities =
        List<ItineraryActivityModel>.from(dayData.activities)
          ..sort((a, b) =>
              _parseTime(a.activityTime).compareTo(_parseTime(b.activityTime)));

    List<Place> orderedPlaces = [];
    for (var activity in sortedActivities) {
      if (activity.placeId.isEmpty) continue;
      final place = dayData.places.firstWhere(
        (p) => p.id == activity.placeId,
        orElse: () => Place(
            id: '',
            name: '',
            category: '',
            imageUrl: '',
            typicalDuration: '',
            rating: 0,
            reviewsCount: 0,
            latitude: 0,
            longitude: 0,
            verified: false),
      );
      if (place.id.isNotEmpty && place.latitude != 0) {
        orderedPlaces.add(place);
      }
    }

    // Fallback: no activities matched — use raw places
    if (orderedPlaces.isEmpty) {
      orderedPlaces = List.from(dayData.places);
    }

    _currentDayPlaces = orderedPlaces;

    if (!mounted) return;

    // ── Build markers ──
    Set<Marker> markers = {};

    // Starting point marker (Google-style blue dot)
    LatLng? startLatLng;
    String? startPointName;
    final selectedSp = tripPlanningState.selectedStartingPoint;
    final detailsSp = tripPlanningState.selectedTripDetails?.startingPoint;

    if (selectedSp != null) {
      startLatLng = LatLng(selectedSp.latitude, selectedSp.longitude);
      startPointName = selectedSp.name;
    } else if (detailsSp != null) {
      // Fallback: use the starting point stored in trip details
      startLatLng = LatLng(detailsSp.latitude, detailsSp.longitude);
      startPointName = detailsSp.name;
    } else if (_userLocation != null) {
      startLatLng = _userLocation;
    }

    if (startLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('start_location'),
        position: startLatLng,
        // Google Maps blue dot style — use default blue circle
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: startPointName ?? 'Your Location',
        ),
      ));
    }

    // Place markers — red pins (standard Google Maps pin)
    for (int i = 0; i < orderedPlaces.length; i++) {
      final place = orderedPlaces[i];
      markers.add(Marker(
        markerId: MarkerId('place_${place.id}'),
        position: LatLng(place.latitude, place.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.typicalDuration,
        ),
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _isLoadingRoute = true;
      });
    }

    // ── Fetch real road polyline ──
    await _fetchAndDrawPolyline(state.selectedDay, startLatLng, orderedPlaces);

    // ── Fit camera to all points ──
    if (_mapController != null) {
      final allPoints = <LatLng>[
        if (startLatLng != null) startLatLng,
        ...orderedPlaces.map((p) => LatLng(p.latitude, p.longitude)),
      ];
      if (allPoints.length >= 2) {
        final bounds = _calculateBounds(allPoints);
        await _mapController!
            .animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      } else if (allPoints.length == 1) {
        await _mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(allPoints.first, 14));
      } else if (_cityLocation != null) {
        // Fallback: no points to show (empty itinerary) — center on city
        await _mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(_cityLocation!, 12));
      }
    }
  }

  Future<void> _fetchAndDrawPolyline(
      int dayNumber, LatLng? origin, List<Place> places) async {
    if (places.isEmpty) {
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    try {
      final List<LatLng> allPolylineCoords = [];

      // Determine origin
      final LatLng routeOrigin =
          origin ?? LatLng(places.first.latitude, places.first.longitude);

      // Build waypoint list: origin → place[0] → place[1] → ... → place[last]
      // We call Directions API in segments of max 25 waypoints per request
      // For simplicity, build one request per consecutive pair if ≤ 10 places
      final List<LatLng> waypoints =
          places.map((p) => LatLng(p.latitude, p.longitude)).toList();

      // Use Google Directions API for all cases
      final allCoords = await _getDirectionsPolyline(
        origin: routeOrigin,
        destination: waypoints.last,
        waypoints: waypoints.length > 1
            ? waypoints.sublist(0, waypoints.length - 1)
            : [],
      );
      allPolylineCoords.addAll(allCoords);

      if (!mounted) return;

      if (allPolylineCoords.isNotEmpty) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: PolylineId('route_day_$dayNumber'),
              points: allPolylineCoords,
              color: const Color(0xFF4285F4), // Google blue
              width: 5,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            ),
          };
          _isLoadingRoute = false;
        });
      } else {
        // Fallback straight-line polyline
        _drawFallbackPolyline(dayNumber, routeOrigin, waypoints);
      }
    } catch (e) {
      debugPrint('Polyline fetch error: $e');
      if (!mounted) return;
      final routeOrigin = origin ??
          (places.isNotEmpty
              ? LatLng(places.first.latitude, places.first.longitude)
              : null);
      final waypoints =
          places.map((p) => LatLng(p.latitude, p.longitude)).toList();
      if (routeOrigin != null) {
        _drawFallbackPolyline(dayNumber, routeOrigin, waypoints);
      }
    }
  }

  /// Calls Google Directions API directly for multi-waypoint routes
  Future<List<LatLng>> _getDirectionsPolyline({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
  }) async {
    final waypointStr =
        waypoints.map((p) => '${p.latitude},${p.longitude}').join('|');

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&waypoints=optimize:false|$waypointStr'
      '&mode=driving'
      '&key=${ApiConstants.googleApiKey}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') {
      debugPrint('Directions API status: ${data['status']}');
      return [];
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) return [];

    final overviewPolyline = (routes.first
        as Map<String, dynamic>)['overview_polyline'] as Map<String, dynamic>;
    final encoded = overviewPolyline['points'] as String;

    return _decodePolyline(encoded);
  }

  /// Decodes a Google encoded polyline string into LatLng list
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _drawFallbackPolyline(
      int dayNumber, LatLng origin, List<LatLng> waypoints) {
    if (!mounted) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('route_day_$dayNumber'),
          points: [origin, ...waypoints],
          color: const Color(0xFF4285F4),
          width: 4,
          patterns: [PatternItem.dash(12), PatternItem.gap(8)],
        ),
      };
      _isLoadingRoute = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Open in Google Maps
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openInGoogleMaps() async {
    if (_currentDayPlaces.isEmpty) return;

    final tripPlanningState = context.read<TripPlanningBloc>().state;

    // Build origin
    String origin = '';
    final openSp = tripPlanningState.selectedStartingPoint;
    final openDetailsSp = tripPlanningState.selectedTripDetails?.startingPoint;

    if (openSp != null) {
      origin = '${openSp.latitude},${openSp.longitude}';
    } else if (openDetailsSp != null) {
      // Fallback: use the starting point from trip details
      origin = '${openDetailsSp.latitude},${openDetailsSp.longitude}';
    } else if (_userLocation != null) {
      origin = '${_userLocation!.latitude},${_userLocation!.longitude}';
    }

    final destination = _currentDayPlaces.last;
    final destStr = '${destination.latitude},${destination.longitude}';

    String url;
    if (_currentDayPlaces.length == 1) {
      // Just navigate to the single place
      url = 'https://www.google.com/maps/dir/?api=1'
          '${origin.isNotEmpty ? "&origin=$origin" : ""}'
          '&destination=$destStr'
          '&travelmode=driving';
    } else {
      // Build waypoints (all except last)
      final waypointStr = _currentDayPlaces
          .sublist(0, _currentDayPlaces.length - 1)
          .map((p) => Uri.encodeComponent('${p.latitude},${p.longitude}'))
          .join('%7C'); // pipe separator

      url = 'https://www.google.com/maps/dir/?api=1'
          '${origin.isNotEmpty ? "&origin=${Uri.encodeComponent(origin)}" : ""}'
          '&destination=${Uri.encodeComponent(destStr)}'
          '&waypoints=$waypointStr'
          '&travelmode=driving';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build methods
  // ─────────────────────────────────────────────────────────────────────────

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetItineraryBloc, GetItineraryState>(
      listener: (context, state) {
        if (state is GetItinerarySuccess) {
          _updateMap(state);
        }
      },
      builder: (context, state) {
        final planState = context.read<TripPlanningBloc>().state;

        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildBody(context, state, planState),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GetItineraryState state,
      TripPlanningState planState) {
    if (state is GetItineraryLoading || state is GetItineraryInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GetItineraryFailure) {
      return _buildError(state.message);
    }

    if (state is GetItinerarySuccess) {
      final sortedDays = List<ItineraryDayModel>.from(state.itinerary.days)
        ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

      return Column(
        children: [
          _buildHeader(context, state, planState),
          _buildDayTabs(context, state, sortedDays),
          Expanded(
            child: Stack(
              children: [
                _buildMapSection(state),
                _buildDetailsSheet(context, state, planState, sortedDays),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildHeader(BuildContext context, GetItinerarySuccess state,
      TripPlanningState planState) {
    final city =
        planState.destination.isEmpty ? 'Destination' : planState.destination;
    final startDate = planState.startDate;
    final endDate = planState.endDate;

    String dateRange = "Select Dates";
    if (startDate != null && endDate != null) {
      dateRange =
          "${startDate.day} ${_getMonth(startDate.month)} - ${endDate.day} ${_getMonth(endDate.month)} ${endDate.year % 100}";
    }

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  'Itinerary for $city',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (state.isReoptimizing)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryPink,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.auto_awesome,
                      color: AppColors.primaryPink),
                  tooltip: 'Reoptimize Itinerary',
                  onPressed: () async {
                    final profileState = context.read<ProfileBloc>().state;
                    final isPremium = profileState.profile.premium;

                    if (!isPremium) {
                      final prefs = await SharedPreferences.getInstance();
                      final hasReoptimized =
                          prefs.getBool('reoptimized_${state.itinerary.id}') ??
                              false;

                      if (hasReoptimized) {
                        if (context.mounted) {
                          PlanRestrictionBottomSheet.show(
                            context,
                            title: 'Reoptimization Limit',
                            message:
                                'Free users can reoptimize each itinerary only once. Upgrade to Premium for unlimited AI optimizations!',
                          );
                        }
                        return;
                      }

                      // Save that it was reoptimized once
                      await prefs.setBool(
                          'reoptimized_${state.itinerary.id}', true);
                    }

                    if (context.mounted) {
                      context.read<GetItineraryBloc>().add(
                          ReoptimizeItineraryRequested(state.itinerary.id));
                    }
                  },
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              '$dateRange  (${planState.adults} Adults, ${planState.kids} Kid)',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs(BuildContext context, GetItinerarySuccess state,
      List<ItineraryDayModel> sortedDays) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedDays.length,
        itemBuilder: (context, index) {
          final day = sortedDays[index].dayNumber;
          final isSelected = state.selectedDay == day;

          return GestureDetector(
            onTap: () {
              context.read<GetItineraryBloc>().add(ChangeItineraryDay(day));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isSelected ? AppColors.primaryPink : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Day $day',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? AppColors.primaryPink : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection(GetItinerarySuccess state) {
    return Container(
      height: 420,
      width: double.infinity,
      color: Colors.grey[200],
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              // Re-trigger bounds fit once controller is ready
              final bloc = context.read<GetItineraryBloc>().state;
              if (bloc is GetItinerarySuccess) {
                _fitCameraToCurrentPlaces(bloc);
              }
            },
            initialCameraPosition: CameraPosition(
              target: _cityLocation ?? _userLocation ?? const LatLng(22.7196, 75.8577),
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
          ),
          // Loading indicator for route
          if (_isLoadingRoute)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                color: const Color(0xFF4285F4),
                minHeight: 3,
              ),
            ),
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: _openInGoogleMaps,
              child: _buildMapButton('Open in Maps', Icons.map_outlined),
            ),
          ),
        ],
      ),
    );
  }

  void _fitCameraToCurrentPlaces(GetItinerarySuccess state) async {
    if (_mapController == null) return;
    final allPoints = <LatLng>[
      if (_userLocation != null) _userLocation!,
      ..._currentDayPlaces.map((p) => LatLng(p.latitude, p.longitude)),
    ];
    if (allPoints.length >= 2) {
      final bounds = _calculateBounds(allPoints);
      await _mapController!
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } else if (allPoints.length == 1) {
      await _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(allPoints.first, 14));
    } else if (_cityLocation != null) {
      // Default to city center if no places
      await _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_cityLocation!, 12));
    }
  }

  Widget _buildMapButton(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: AppColors.successGreen),
        ],
      ),
    );
  }

  Widget _buildDetailsSheet(BuildContext context, GetItinerarySuccess state,
      TripPlanningState planState, List<ItineraryDayModel> sortedDays) {
    final dayData = sortedDays.firstWhere(
      (d) => d.dayNumber == state.selectedDay,
      orElse: () => sortedDays.first,
    );

    final sortedActivities =
        List<ItineraryActivityModel>.from(dayData.activities)
          ..sort((a, b) =>
              _parseTime(a.activityTime).compareTo(_parseTime(b.activityTime)));

    final dayDate =
        planState.startDate?.add(Duration(days: state.selectedDay - 1));
    String dateStr = dayDate != null
        ? "${dayDate.day} ${_getMonth(dayDate.month)} ${dayDate.year % 100}"
        : "Day ${state.selectedDay}";

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            if (_isAddingActivity)
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: AppColors.textMuted),
                                onPressed: () {
                                  setState(() {
                                    _isAddingActivity = false;
                                  });
                                },
                              ),
                            GestureDetector(
                              onTap: () {
                                if (_isAddingActivity) {
                                  final hr =
                                      _durationHourController.text.trim();
                                  final min =
                                      _durationMinController.text.trim();

                                  List<String> parts = [];

                                  if (hr.isNotEmpty) parts.add("$hr Hour");
                                  if (min.isNotEmpty) parts.add("$min Min");

                                  final duration = parts.join(' ');
                                  context.read<GetItineraryBloc>().add(
                                        AddActivityRequested(
                                          itineraryId: state.itinerary.id,
                                          dayNumber: state.selectedDay,
                                          time: _timeController.text,
                                          title: _titleController.text,
                                          cost: 0.0,
                                          duration: duration,
                                          icon: 'explore',
                                          placeId: '',
                                        ),
                                      );
                                  setState(() {
                                    _isAddingActivity = false;
                                    _titleController.clear();
                                    _timeController.clear();

                                    _durationHourController.text = 'hr';
                                    _durationMinController.clear();
                                  });
                                } else {
                                  setState(() {
                                    _isAddingActivity = true;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isAddingActivity
                                      ? AppColors.successGreen
                                      : AppColors.primaryPink,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isAddingActivity ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (_isAddingActivity) ...[
                      _buildAddActivityForm(),
                      const SizedBox(height: 24),
                    ],
                    ...sortedActivities.map((activity) {
                      final index = sortedActivities.indexOf(activity);
                      return _buildTimelineItem(
                          activity,
                          index == sortedActivities.length - 1,
                          state.itinerary.id);
                    }),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Save and Proceed',
                      onPressed: () {
                        // final itinerary = state.itinerary;
                        // final trip = Trips(
                        //   id: itinerary.id,
                        //   city: itinerary.city,
                        //   imageUrl:
                        //       'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400',
                        //   startDate: planState.startDate
                        //           ?.toIso8601String()
                        //           .split('T')
                        //           .first ??
                        //       '',
                        //   endDate: planState.endDate
                        //           ?.toIso8601String()
                        //           .split('T')
                        //           .first ??
                        //       '',
                        //   placesCount: planState.selectedPlaces.length,
                        //   days: itinerary.days.length,
                        //   adults: planState.adults,
                        //   kids: planState.kids,
                        // );
                        // context.read<ItineraryBloc>().add(AddItinerary(trip));
                        context.push('/packing-list');
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(
      ItineraryActivityModel activity, bool isLast, String itineraryId) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBgColor(activity.icon).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getActivityIcon(activity.icon),
                  color: AppColors.textDark,
                  size: 24,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey[200],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activity.activityTime,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          // Text(
                          //   '₹ ${activity.cost.toInt()}',
                          //   style: GoogleFonts.inter(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w700,
                          //     color: AppColors.textDark,
                          //   ),
                          // ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              context.read<GetItineraryBloc>().add(
                                    RemoveActivityRequested(
                                      activityId: activity.id,
                                      itineraryId: itineraryId,
                                    ),
                                  );
                            },
                            child: const Icon(Icons.close,
                                size: 16, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.duration,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconBgColor(String icon) {
    switch (icon) {
      case 'car':
        return Colors.orange;
      case 'temple':
        return Colors.orangeAccent;
      case 'activity':
      case 'explore':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getActivityIcon(String icon) {
    switch (icon) {
      case 'car':
        return Icons.directions_car_outlined;
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'temple':
        return Icons.temple_hindu_outlined;
      case 'sun':
        return Icons.wb_sunny_outlined;
      case 'activity':
      case 'map':
        return Icons.place_outlined;
      case 'explore':
        return Icons.explore_outlined;
      default:
        return Icons.explore_outlined;
    }
  }

  DateTime _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';

      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      return DateTime(2000, 1, 1);
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.primaryPink),
            const SizedBox(height: 16),
            Text(
              'Failed to load itinerary',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textMuted)),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              onPressed: _fetchItinerary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
              secondary: AppColors.primaryPink,
              onSecondary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        _timeController.text = "$hour:$minute $period";
      });
    }
  }

  Widget _buildAddActivityForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        hintText: 'Time (Select)',
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.access_time, size: 18),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title (e.g. Search Hotel)',
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              // Expanded(
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: Colors.grey[200]!),
              //     ),
              //     child: TextField(
              //       controller: _durationValController,
              //       keyboardType: TextInputType.number,
              //       decoration: const InputDecoration(
              //         hintText: '1',
              //         border: InputBorder.none,
              //       ),
              //       textAlign: TextAlign.center,
              //       style: GoogleFonts.inter(fontSize: 14),
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _durationHourController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Hour',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _durationMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Min',
                      border: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
