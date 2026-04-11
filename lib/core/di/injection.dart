import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shrine_tours/features/auth/domain/repositories/auth_repository.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';
import 'package:shrine_tours/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:shrine_tours/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:shrine_tours/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:shrine_tours/features/trip_planning/data/datasource/trips_data_source.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/trips_repository.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/add_place_to_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/create_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/delete_trip_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_trips_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/update_trip_usecase.dart';
import 'package:shrine_tours/features/profile/data/datasource/profile_data_source.dart';
import 'package:shrine_tours/features/trip_planning/data/datasource/places_data_source.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/places_repository.dart';
import 'package:shrine_tours/features/trip_planning/domain/repositories/places_repository.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_places_usecase.dart';
import 'package:shrine_tours/features/trip_planning/domain/usecases/get_suggested_places_usecase.dart';
import 'package:shrine_tours/features/trip_planning/presentation/bloc/add_places_bloc.dart';
import 'package:shrine_tours/features/profile/domain/repositories/profile_repository.dart';
import 'package:shrine_tours/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/get_payment_methods_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/add_payment_method_usecase.dart';
import 'package:shrine_tours/features/profile/domain/usecases/get_subscription_usecase.dart';
import 'package:shrine_tours/features/profile/presentation/bloc/payment_method_bloc.dart';
import 'package:shrine_tours/features/trip_planning/data/datasource/weather_datasource.dart';
import 'package:shrine_tours/features/trip_planning/data/repository/weather_repository.dart';
import 'package:shrine_tours/features/trip_planning/presentation/bloc/weather/weather_bloc.dart';
import '../../core/api/api_client.dart';
import '../../core/api/dio_config.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forget_password_bloc.dart';
import '../../features/itinerary/presentation/bloc/itinerary_bloc.dart';
import '../../features/itinerary/data/datasource/itinerary_datasource.dart';
import '../../features/itinerary/data/repository/itinerary_repository_impl.dart';
import '../../features/itinerary/domain/repositories/itinerary_repository.dart';
import '../../features/itinerary/domain/usecases/generate_itinerary_usecase.dart';
import '../../features/itinerary/domain/usecases/get_itinerary_usecase.dart';
import '../../features/itinerary/presentation/bloc/generate_itinerary_bloc.dart';
import '../../features/itinerary/presentation/bloc/get_itinerary_bloc.dart';
import '../../features/packing/data/datasource/packing_datasource.dart';
import '../../features/packing/data/repository/packing_repository_impl.dart';
import '../../features/packing/domain/repositories/packing_repository.dart';
import '../../features/packing/domain/usecases/update_transports_usecase.dart';
import '../../features/packing/domain/usecases/get_packing_list_usecase.dart';
import '../../features/packing/domain/usecases/toggle_packing_item_usecase.dart';
import '../../features/packing/domain/usecases/add_packing_category_usecase.dart';
import '../../features/packing/domain/usecases/add_packing_item_usecase.dart';
import '../../features/packing/presentation/bloc/packing_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/trip_planning/presentation/bloc/trip_planning_bloc.dart';
import '../../features/payment/data/datasources/payment_data_source.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/create_order_usecase.dart';
import '../../features/payment/domain/usecases/verify_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_order_history_usecase.dart';
import '../../features/payment/domain/usecases/download_invoice_usecase.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // ── Token storage ─────────────────────────────────────────────────────────
  getIt.registerSingleton<TokenStorageRepo>(
    TokenStorageRepo(getIt<SharedPreferences>()),
  );

  // Core network dependencies
  getIt.registerLazySingleton(() => DioConfig.createDio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(dio: getIt()));

  // ── Auth repository ───────────────────────────────────────────────────────
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(getIt<TokenStorageRepo>(), getIt<ApiClient>()),
  );

  // ── Auth Use Cases ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );

  // ── Places dependencies ───────────────────────────────────────────────────
  getIt.registerLazySingleton<PlacesDataSource>(
    () => PlacesDataSourceImpl(),
  );
  getIt.registerLazySingleton<IPlacesRepository>(
    () => PlacesRepository(getIt<PlacesDataSource>()),
  );
  getIt.registerLazySingleton<GetPlacesUseCase>(
    () => GetPlacesUseCase(getIt<IPlacesRepository>()),
  );
  getIt.registerLazySingleton<GetSuggestedPlacesUseCase>(
    () => GetSuggestedPlacesUseCase(getIt<IPlacesRepository>()),
  );

  // ── Profile dependencies ──────────────────────────────────────────────────
  getIt.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepository(getIt<ProfileDataSource>()),
  );
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<UploadAvatarUseCase>(
    () => UploadAvatarUseCase(getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<GetPaymentMethodsUseCase>(
    () => GetPaymentMethodsUseCase(getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<AddPaymentMethodUseCase>(
    () => AddPaymentMethodUseCase(getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<GetSubscriptionUseCase>(
    () => GetSubscriptionUseCase(getIt<IProfileRepository>()),
  );

  // ── Trips dependencies ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<TripsDataSource>(
    () => TripsDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ITripsRepository>(
    () => TripsRepository(getIt<TripsDataSource>()),
  );
  getIt.registerLazySingleton<GetTripsUseCase>(
    () => GetTripsUseCase(getIt<ITripsRepository>()),
  );
  getIt.registerLazySingleton<CreateTripUseCase>(
    () => CreateTripUseCase(getIt<ITripsRepository>()),
  );
  getIt.registerLazySingleton<UpdateTripUseCase>(
    () => UpdateTripUseCase(getIt<ITripsRepository>()),
  );
  getIt.registerLazySingleton<DeleteTripUseCase>(
    () => DeleteTripUseCase(getIt<ITripsRepository>()),
  );
  getIt.registerLazySingleton<AddPlaceToTripUseCase>(
    () => AddPlaceToTripUseCase(getIt<ITripsRepository>()),
  );

  // ── Weather dependencies ──────────────────────────────────────────────────
  getIt.registerLazySingleton<WeatherDataSource>(
    () => WeatherDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<IWeatherRepository>(
    () => WeatherRepository(getIt<WeatherDataSource>()),
  );

  // ── Itinerary dependencies ────────────────────────────────────────────────
  getIt.registerLazySingleton<ItineraryDataSource>(
    () => ItineraryDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<IItineraryRepository>(
    () => ItineraryRepositoryImpl(getIt<ItineraryDataSource>()),
  );
  getIt.registerLazySingleton<GenerateItineraryUseCase>(
    () => GenerateItineraryUseCase(getIt<IItineraryRepository>()),
  );
  getIt.registerLazySingleton<GetItineraryUseCase>(
    () => GetItineraryUseCase(getIt<IItineraryRepository>()),
  );

  // ── Packing dependencies ──────────────────────────────────────────────────
  getIt.registerLazySingleton<PackingDataSource>(
    () => PackingDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<IPackingRepository>(
    () => PackingRepositoryImpl(getIt<PackingDataSource>()),
  );
  getIt.registerLazySingleton<UpdateTransportsUseCase>(
    () => UpdateTransportsUseCase(getIt<IPackingRepository>()),
  );
  getIt.registerLazySingleton<GetPackingListUseCase>(
    () => GetPackingListUseCase(getIt<IPackingRepository>()),
  );
  getIt.registerLazySingleton<TogglePackingItemUseCase>(
    () => TogglePackingItemUseCase(getIt<IPackingRepository>()),
  );
  getIt.registerLazySingleton<AddPackingCategoryUseCase>(
    () => AddPackingCategoryUseCase(getIt<IPackingRepository>()),
  );
  getIt.registerLazySingleton<AddPackingItemUseCase>(
    () => AddPackingItemUseCase(getIt<IPackingRepository>()),
  );

  // ── Payment dependencies ──────────────────────────────────────────────────
  getIt.registerLazySingleton<PaymentDataSource>(
    () => PaymentDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(getIt<PaymentDataSource>()),
  );
  getIt.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<VerifyPaymentUseCase>(
    () => VerifyPaymentUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<GetOrderHistoryUseCase>(
    () => GetOrderHistoryUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<DownloadInvoiceUseCase>(
    () => DownloadInvoiceUseCase(getIt<PaymentRepository>()),
  );

  // BLoCs
  getIt.registerFactory(() => AuthBloc(repository: getIt<AuthRepository>()));
  getIt.registerFactory(() => ForgetPasswordBloc(
        getIt<ForgotPasswordUseCase>(),
        getIt<VerifyOtpUseCase>(),
        getIt<ResetPasswordUseCase>(),
      ));
  getIt.registerFactory(() => PaymentMethodBloc(
        getIt<GetPaymentMethodsUseCase>(),
        getIt<AddPaymentMethodUseCase>(),
      ));
  getIt.registerFactory(() => AddPlacesBloc(
        getIt<GetPlacesUseCase>(),
        getIt<GetSuggestedPlacesUseCase>(),
        getIt<AddPlaceToTripUseCase>(),
      ));
  getIt.registerFactory(() => TripPlanningBloc(
        getIt<CreateTripUseCase>(),
        getIt<UpdateTripUseCase>(),
      ));
  getIt.registerFactory(() =>
      ItineraryBloc(getIt<GetTripsUseCase>(), getIt<DeleteTripUseCase>()));
  getIt.registerFactory(
      () => GenerateItineraryBloc(getIt<GenerateItineraryUseCase>()));
  getIt.registerFactory(() => GetItineraryBloc(getIt<GetItineraryUseCase>()));
  getIt.registerFactory(() => PackingBloc(
        getIt<UpdateTransportsUseCase>(),
        getIt<GetPackingListUseCase>(),
        getIt<TogglePackingItemUseCase>(),
        getIt<AddPackingCategoryUseCase>(),
        getIt<AddPackingItemUseCase>(),
      ));
  getIt.registerFactory(() => ProfileBloc(
        getIt<GetProfileUseCase>(),
        getIt<UpdateProfileUseCase>(),
        getIt<UploadAvatarUseCase>(),
        getIt<GetSubscriptionUseCase>(),
        getIt<GetOrderHistoryUseCase>(),
        getIt<DownloadInvoiceUseCase>(),
      ));

  getIt.registerFactory(() => WeatherBloc(getIt<IWeatherRepository>()));
  getIt.registerFactory(() => PaymentBloc(
        createOrderUseCase: getIt<CreateOrderUseCase>(),
        verifyPaymentUseCase: getIt<VerifyPaymentUseCase>(),
      ));
}
