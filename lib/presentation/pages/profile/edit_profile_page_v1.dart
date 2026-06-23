import 'package:firebase_auth/firebase_auth.dart';
import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:knowme/features/astrology/application/astrology_generation_coordinator.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/narrative_runtime/integration/narrative_runtime_loader.dart';
import 'package:knowme/features/narrative_runtime/integration/profile_narrative_mapper.dart';
import 'package:knowme/features/narrative_runtime/presentation/profile_narrative_section.dart';
import '../../../domain/models/profile_model.dart';
import '../../../services/profile_service.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/location_picker.dart';

class EditProfilePageV1 extends StatefulWidget {
  const EditProfilePageV1({super.key});

  @override
  State<EditProfilePageV1> createState() => _EditProfilePageV1State();
}

class _EditProfilePageV1State extends State<EditProfilePageV1> {
  final _profileService = ProfileService();
  final _narrativeLoader = NarrativeRuntimeLoader();
  final nameController = TextEditingController();
  final birthPlaceController = TextEditingController();

  ProfileModel? _originalProfile;

  DateTime? birthDate;
  TimeOfDay? birthTime;

  String gender = 'male';
  String timezone = 'Asia/Bangkok';

  double? latitude;
  double? longitude;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  ProfileNarrativeData? _narrativeData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final profile = await _profileService.loadProfile();
      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'Profile not found';
        });
        return;
      }

      _originalProfile = profile;
      nameController.text = profile.name;
      birthPlaceController.text = profile.birthPlace;
      gender = profile.gender.isNotEmpty ? profile.gender : 'male';
      timezone = profile.timezone.isNotEmpty ? profile.timezone : 'Asia/Bangkok';
      latitude = profile.latitude;
      longitude = profile.longitude;
      birthDate = _parseBirthDate(profile.birthDate);
      birthTime = _parseBirthTime(profile.birthTime);

      setState(() {
        _isLoading = false;
      });

      _loadNarrative();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _loadNarrative() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) return;

      final narrative = await _narrativeLoader.loadForUser(
        uid,
        generatedAt: DateTime.now().toUtc(),
      );
      if (!mounted || narrative == null) return;
      setState(() {
        _narrativeData = ProfileNarrativeMapper.fromResult(narrative);
      });
    } catch (_) {
      // Narrative is additive — profile edit remains usable without it.
    }
  }

  DateTime? _parseBirthDate(String raw) {
    return BirthProfileFormat.parseStoredDate(raw);
  }

  TimeOfDay? _parseBirthTime(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  Future<void> _pickBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: birthTime ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (picked != null) {
      setState(() => birthTime = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Birth Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Birth Time';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _apiBirthDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _birthDataChanged(ProfileModel before, ProfileModel after) {
    return before.birthDate != after.birthDate ||
        before.birthTime != after.birthTime ||
        before.birthPlace != after.birthPlace ||
        before.latitude != after.latitude ||
        before.longitude != after.longitude ||
        before.timezone != after.timezone;
  }

  ProfileModel? _buildUpdatedProfile() {
    if (birthDate == null ||
        birthTime == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }

    return ProfileModel(
      name: nameController.text.trim(),
      gender: gender,
      birthDate: BirthProfileFormat.storageDate(birthDate!),
      birthTime: _formatTime(birthTime),
      birthPlace: birthPlaceController.text.trim(),
      latitude: latitude!,
      longitude: longitude!,
      timezone: timezone,
    );
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        birthDate == null ||
        birthTime == null ||
        birthPlaceController.text.trim().isEmpty ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final original = _originalProfile;
    if (original == null) return;

    final updated = _buildUpdatedProfile();
    if (updated == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _profileService.saveProfile(updated);

      if (!mounted) return;

      final birthChanged = _birthDataChanged(original, updated);
      final wasComplete = BirthProfileReadiness.isComplete(original);
      final isComplete = BirthProfileReadiness.isComplete(updated);

      if (isComplete && (birthChanged || !wasComplete)) {
        await AstrologyGenerationCoordinator().ensureGenerated(user.uid);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );

      _originalProfile = updated;
      context.read<ProfileProvider>().refreshProfile();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            enabled: !_isSaving,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: gender,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => gender = value);
                    }
                  },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isSaving ? null : _pickBirthDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_formatDate(birthDate)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isSaving ? null : _pickBirthTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_formatTime(birthTime)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isSaving
                ? null
                : () async {
                    final result = await LocationPicker.pick(context);
                    if (result != null) {
                      setState(() {
                        birthPlaceController.text = result['name'];
                        latitude = result['lat'];
                        longitude = result['lng'];
                      });
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                birthPlaceController.text.isEmpty
                    ? 'Select Birth Place'
                    : birthPlaceController.text,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Timezone: $timezone',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 30),
          if (_narrativeData != null) ...[
            ProfileNarrativeSection(data: _narrativeData!),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
