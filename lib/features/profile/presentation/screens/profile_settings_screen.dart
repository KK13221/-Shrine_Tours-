import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/profile_bloc.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  String selectedCountryCode = '+91';

  final List<Map<String, String>> countryCodes = [
    {'code': '+91', 'country': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'country': 'USA', 'flag': '🇺🇸'},
    {'code': '+92', 'country': 'Pakistan', 'flag': '🇵🇰'},
    {'code': '+880', 'country': 'Bangladesh', 'flag': '🇧🇩'},
    {'code': '+971', 'country': 'UAE', 'flag': '🇦🇪'},
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '+61', 'country': 'Australia', 'flag': '🇦🇺'},
    {'code': '+81', 'country': 'Japan', 'flag': '🇯🇵'},
    {'code': '+86', 'country': 'China', 'flag': '🇨🇳'},
    {'code': '+94', 'country': 'Sri Lanka', 'flag': '🇱🇰'},
  ];

  File? _pickedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  bool _wasSaving = false; // Track previous saving state

  @override
  void initState() {
    super.initState();

    // ── Fire LoadProfile so state is always fresh ──────────────────────────
    // When API is ready, this triggers the real fetch.
    // For now it restores the default UserProfile.
    context.read<ProfileBloc>().add(LoadProfile());

    // Seed controllers from whatever is in state right now.
    // They will NOT auto-update if bloc emits later —
    // that's intentional: user edits should not be overwritten mid-type.
    final profile = context.read<ProfileBloc>().state.profile;
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _dobController = TextEditingController(text: profile.dob);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // ── Initials from name ─────────────────────────────────────────────────────
  // Derived from state.profile.name, so it reflects whatever the backend
  // returns once API is wired. Falls back gracefully for single-word names.

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  // ── Photo picker ───────────────────────────────────────────────────────────

  void _showPhotoOptions() {
    final hasAnyPhoto = _pickedImageFile != null ||
        (context.read<ProfileBloc>().state.profile.avatarUrl.isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoPickerSheet(
        onTakePhoto: () => _pickImage(ImageSource.camera),
        onChooseFromGallery: () => _pickImage(ImageSource.gallery),
        onRemovePhoto: hasAnyPhoto ? _removePhoto : null,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (mounted) Navigator.of(context).pop();

    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked != null && mounted) {
      setState(() => _pickedImageFile = File(picked.path));
      // Upload the avatar to the server
      context.read<ProfileBloc>().add(UploadAvatar(filePath: picked.path));
    }
  }

  void _removePhoto() {
    Navigator.of(context).pop();
    // Clears the locally picked file only.
    // The avatar will now fall back to state.profile.profilePictureUrl
    // (if present) or initials — no separate action needed.
    setState(() => _pickedImageFile = null);
    // TODO: When API is ready, also dispatch to clear the server URL:
    // context.read<ProfileBloc>().add(RemoveProfilePhoto());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF121212) : Colors.white;
    final titleColor = isDark ? Colors.white : AppColors.textDark;
    final iconColor = isDark ? Colors.white : AppColors.textDark;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 28, color: iconColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile Settings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: iconColor),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // Clear the picked image file when upload completes
          if (!state.isUploadingAvatar && _pickedImageFile != null) {
            setState(() => _pickedImageFile = null);
          }

          // Show success snackbar when profile update completes successfully
          if (_wasSaving && !state.isSaving && !state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile updated successfully!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }

          // Update the tracking variable
          _wasSaving = state.isSaving;
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // ── Seed controllers once after LoadProfile completes ─────────────
            // Only update if controllers are still showing the default/empty
            // values to avoid overwriting user edits mid-session.
            // When API is ready this block will naturally populate from the
            // real API response via state.profile.
            if (!state.isLoading && _nameController.text.isEmpty) {
              _nameController.text = state.profile.name;
              _emailController.text = state.profile.email;
              _phoneController.text = state.profile.phone;
              _dobController.text = state.profile.dob;
            }

            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar ─────────────────────────────────────────────────
                  // Initials come from state.profile.name.
                  // Photo comes from _pickedImageFile (local for now).
                  // TODO: Also pass state.profile.photoUrl when API is ready.
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: state.isUploadingAvatar
                              ? null
                              : _showPhotoOptions,
                          child: Stack(
                            children: [
                              _ProfileAvatar(
                                imageFile: _pickedImageFile,
                                photoUrl: state.profile.avatarUrl,
                                initials: _getInitials(state.profile.name),
                              ),
                              if (state.isUploadingAvatar)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryPink,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: state.isUploadingAvatar
                              ? null
                              : _showPhotoOptions,
                          child: Text(
                            state.isUploadingAvatar
                                ? 'Uploading...'
                                : 'Change Photo',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: state.isUploadingAvatar
                                  ? AppColors.textMuted
                                  : AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Fields ─────────────────────────────────────────────────
                  _buildField(context, 'Full Name', _nameController),
                  const SizedBox(height: 20),
                  _buildField(context, 'Email', _emailController),
                  const SizedBox(height: 20),
                  _buildPhoneField(context),
                  const SizedBox(height: 20),
                  _buildField(context, 'Date of Birth', _dobController),
                  const SizedBox(height: 32),

                  // ── Save button ────────────────────────────────────────────
                  PrimaryButton(
                    text: 'Save Changes',
                    isLoading: state.isSaving,
                    onPressed: () {
                      context.read<ProfileBloc>().add(UpdateProfile(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            dob: _dobController.text,
                          ));
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// PHONE FIELD
  Widget _buildPhoneField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white60 : AppColors.textMuted;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : AppColors.cardBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              /// 🔥 COUNTRY CODE DROPDOWN
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    dropdownColor: fillColor,
                    style: GoogleFonts.inter(color: textColor),
                    icon: const Icon(Icons.arrow_drop_down),
                    selectedItemBuilder: (context) {
                      return countryCodes.map((country) {
                        return Row(
                          children: [
                            Text(country['flag']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              country['code']!,
                              style: GoogleFonts.inter(color: textColor),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    items: countryCodes.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['code'], // ✅ ONLY CODE stored
                        child: Row(
                          children: [
                            Text(country['flag']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${country['code']}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCountryCode = value!;
                      });
                    },
                  )),

              /// Divider
              Container(
                height: 24,
                width: 1,
                color: borderColor,
              ),

              /// 🔥 PHONE INPUT
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: textColor,
                  ),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    hintText: 'Enter phone number',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Theme-aware field ──────────────────────────────────────────────────────

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white60 : AppColors.textMuted;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : AppColors.cardBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryPink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE AVATAR
//
// Priority (highest → lowest):
//   1. _pickedImageFile  → user just picked from gallery/camera (local File)
//   2. profilePictureUrl → URL from state.profile.profilePictureUrl (network)
//   3. initials          → fallback when both above are absent
//
// When API is ready: pass state.profile.profilePictureUrl as [photoUrl].
// No other changes needed — the priority chain handles everything.
// ─────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final File? imageFile; // local picked file — overrides everything
  final String? photoUrl; // from state.profile.profilePictureUrl
  final String initials; // fallback

  const _ProfileAvatar({
    required this.initials,
    this.imageFile,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve which image provider to use, in priority order.
    ImageProvider? resolvedImage;

    if (imageFile != null) {
      // Priority 1: user just picked a new photo locally
      resolvedImage = FileImage(imageFile!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      // Priority 2: existing photo from state/API
      resolvedImage = NetworkImage(photoUrl!);
    }
    // Priority 3: no image → show initials (resolvedImage stays null)

    final showInitials = resolvedImage == null;

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryPink,
            shape: BoxShape.circle,
            image: resolvedImage != null
                ? DecorationImage(image: resolvedImage, fit: BoxFit.cover)
                : null,
          ),
          child: showInitials
              ? Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        // Camera badge
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 14,
              color: AppColors.primaryPink,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PHOTO PICKER BOTTOM SHEET — theme-aware
// ─────────────────────────────────────────────

class _PhotoPickerSheet extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;
  final VoidCallback? onRemovePhoto;

  const _PhotoPickerSheet({
    required this.onTakePhoto,
    required this.onChooseFromGallery,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFF0F0F0);
    final subtitleColor = isDark ? Colors.white38 : AppColors.textMuted;
    final handleColor = isDark ? Colors.white24 : const Color(0xFFDDDDDD);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Profile Photo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              subtitle: 'Open camera',
              iconColor: AppColors.primaryPink,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onTap: onTakePhoto,
            ),
            Divider(height: 1, color: dividerColor, indent: 60),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              subtitle: 'Pick from your photos',
              iconColor: AppColors.primaryPink,
              textColor: textColor,
              subtitleColor: subtitleColor,
              onTap: onChooseFromGallery,
            ),
            // if (onRemovePhoto != null) ...[
            //   Divider(height: 1, color: dividerColor, indent: 60),
            //   _SheetOption(
            //     icon: Icons.delete_outline,
            //     label: 'Remove Photo',
            //     subtitle: 'Revert to initials',
            //     iconColor: Colors.red,
            //     textColor: Colors.red,
            //     subtitleColor: subtitleColor,
            //     onTap: onRemovePhoto!,
            //   ),
            // ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final Color textColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.textColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        GoogleFonts.inter(fontSize: 12, color: subtitleColor)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: subtitleColor, size: 20),
          ],
        ),
      ),
    );
  }
}
