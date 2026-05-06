import 'package:flutter/material.dart';

import '../../domain/models/profile_model.dart';
import '../../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  ProfileModel? _profile;

  bool _isLoading = false;

  ProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get hasProfile => _profile != null;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _profileService.loadProfile();

      _profile = result;
    } catch (e) {
      debugPrint("Load profile error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _profileService.saveProfile(profile);

      _profile = profile;

      notifyListeners();
    } catch (e) {
      debugPrint("Save profile error: $e");
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void clear() {
    _profile = null;

    notifyListeners();
  }
}
