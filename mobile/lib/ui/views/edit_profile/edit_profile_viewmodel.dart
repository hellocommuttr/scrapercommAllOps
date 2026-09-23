import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/settings_service.dart';
import '../profile/erase_device.dart';

/// Name, phone, email, location and photo — stored in SQLite on this device only.
/// Nothing is uploaded: Commuttr has no accounts.
class EditProfileViewModel extends ReactiveViewModel {
  final _settings = locator<SettingsService>();
  final _nav = locator<NavigationService>();
  final _dialogs = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings];

  static const maxLength = 40;
  static const defaultLocation = 'Cape Town, South Africa';
  static const otherLocation = 'Other…';
  static const commonLocations = [
    defaultLocation,
    'Bellville',
    'Mitchells Plain',
    'Khayelitsha',
    'Cape Town CBD',
    'Wynberg',
    'Parow',
    'Durbanville',
    'Somerset West',
  ];

  final formKey = GlobalKey<FormState>();

  late final nameController = TextEditingController(text: _settings.displayName);
  late final phoneController = TextEditingController(text: _settings.phone);
  late final emailController = TextEditingController(text: _settings.email);

  late String location = _settings.homeArea.isEmpty ? defaultLocation : _settings.homeArea;

  /// The dropdown's choices: the common areas, the saved one if it isn't among them, and "Other…".
  List<String> get locationOptions => [
    ...commonLocations,
    if (!commonLocations.contains(location)) location,
    otherLocation,
  ];

  String? get photoBase64 => _settings.photoBase64;
  bool get hasPhoto => (photoBase64 ?? '').isNotEmpty;

  // -- validation

  String? validateName(String? value) {
    if ((value ?? '').trim().length > maxLength) return 'Keep it to $maxLength characters or fewer.';
    return null;
  }

  String? validatePhone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(v)) return 'Enter a valid phone number.';
    return null;
  }

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  // -- location

  /// Picking "Other…" is handled by the view (it asks for the area's name).
  void setLocation(String? value) {
    final v = (value ?? '').trim();
    if (v.isNotEmpty && v != otherLocation) location = v.length > maxLength ? v.substring(0, maxLength) : v;
    // Rebuild the dropdown so a cancelled "Other…" goes back to the saved area.
    locationRevision++;
    rebuildUi();
  }

  /// Bumped on every change so the dropdown is rebuilt with [location] selected.
  int locationRevision = 0;

  // -- photo (saved straight away)

  static const photoKey = 'photo';

  /// Returns a message to show when the photo couldn't be read.
  Future<String?> changePhoto() async {
    try {
      final file = await runBusyFuture(
        ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85),
        busyObject: photoKey,
        throwException: true,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      await _settings.setPhotoBase64(base64Encode(bytes));
      return 'Photo updated.';
    } catch (_) {
      return "Couldn't open that photo. Try another one.";
    }
  }

  Future<void> removePhoto() => _settings.setPhotoBase64(null);

  // -- account (there isn't one)

  Future<void> changePassword() => _dialogs.showDialog(
    title: 'Change password',
    description: "Commuttr doesn't use accounts or passwords, so your details stay on this phone.",
    buttonTitle: 'OK',
  );

  void openPrivacy() => _nav.navigateToOfflineDataView();

  Future<void> deleteAccount() => confirmAndEraseDevice(title: 'Delete my data?', confirmLabel: 'Delete my data');

  // -- save

  /// Saves everything and closes. Returns false when the form did not validate.
  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? true)) return false;
    await runBusyFuture(
      Future.wait([
        _settings.setDisplayName(nameController.text),
        _settings.setPhone(phoneController.text),
        _settings.setEmail(emailController.text),
        _settings.setHomeArea(location),
      ]),
    );
    _nav.back();
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
