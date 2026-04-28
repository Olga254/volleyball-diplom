import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../utils/auth_storage.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  String? _selectedRole;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get selectedRole => _selectedRole;
  bool get isLoggedIn => _currentUser != null;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  String _generatePasswordHash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // МОК-ВХОД ДЛЯ ТЕСТОВЫХ ПОЛЬЗОВАТЕЛЕЙ
  void signInAsMock(String role, String fullName, String email, String position, String experience) {
    _currentUser = User(
      id: 'mock-$role-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _userProfile = {
      'id': 'mock-$role-id',
      'email': email,
      'full_name': fullName,
      'phone': '+79990000000',
      'role': role,
      'birth_date': '1990-01-01',
      'position': position,
      'experience': experience,
      'created_at': DateTime.now().toIso8601String(),
    };
    _selectedRole = role;
    notifyListeners();
  }

  // Администратор (двойное нажатие) – через Supabase
  Future<void> signInAsAdmin(String email, String password) async {
    try {
      final cleanedEmail = email.trim().toLowerCase();
      final AuthResponse res = await _supabase.client.auth.signInWithPassword(
        email: cleanedEmail,
        password: password,
      );
      _currentUser = res.user;
      await _loadUserProfile();
      _selectedRole = _userProfile?['role'];
      await AuthStorage.saveCredentials(email, password);
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка входа администратора: $e');
    }
  }

  // Капитан (тройное нажатие) – через Supabase
  Future<void> signInAsCaptain(String email, String password) async {
    try {
      final cleanedEmail = email.trim().toLowerCase();
      final AuthResponse res = await _supabase.client.auth.signInWithPassword(
        email: cleanedEmail,
        password: password,
      );
      _currentUser = res.user;
      await _loadUserProfile();
      _selectedRole = _userProfile?['role'];
      await AuthStorage.saveCredentials(email, password);
      notifyListeners();
    } catch (e) {
      throw Exception('Ошибка входа капитана: $e');
    }
  }

  // Загрузка профиля после входа
  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;
    final profileResponse = await _supabase.client
        .from('profiles')
        .select()
        .eq('id', _currentUser!.id)
        .maybeSingle();
    if (profileResponse == null) {
      final userMeta = _currentUser!.userMetadata ?? {};
      final newProfile = {
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'full_name': userMeta['full_name'] ?? 'Пользователь',
        'phone': userMeta['phone'] ?? '',
        'role': userMeta['role'] ?? 'игрок',
        'birth_date': userMeta['birth_date'],
        'position': userMeta['position'],
        'team_name': userMeta['team_name'],
        'experience': userMeta['experience'] ?? '',
        'password_hash': '',
        'password_changed_at': DateTime.now().toUtc().toIso8601String(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await _supabase.client.from('profiles').insert(newProfile);
      _userProfile = newProfile;
    } else {
      _userProfile = profileResponse;
    }
  }

  // Обычный вход через Supabase
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cleanedEmail = email.trim().toLowerCase();
      final AuthResponse res = await _supabase.client.auth.signInWithPassword(
        email: cleanedEmail,
        password: password,
      );
      _currentUser = res.user;
      await _loadUserProfile();
      _selectedRole = _userProfile?['role'];
      await AuthStorage.saveCredentials(email, password);
      notifyListeners();
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      throw Exception('Неверный email или пароль');
    } catch (e) {
      debugPrint('Ошибка входа: $e');
      throw Exception('Ошибка входа: $e');
    }
  }

  // Регистрация
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required DateTime birthDate,
    String? position,
    String? teamName,
    String? experience,
  }) async {
    try {
      final cleanedEmail = email.trim().toLowerCase();
      if (cleanedEmail.isEmpty) throw Exception('Введите email');
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(cleanedEmail)) throw Exception('Некорректный email адрес');
      if (password.length < 6) throw Exception('Пароль должен содержать минимум 6 символов');
      if (fullName.trim().isEmpty) throw Exception('Введите полное имя');
      final cleanedPhone = _cleanPhoneNumber(phone);
      if (cleanedPhone.isEmpty) throw Exception('Введите номер телефона');
      final phoneRegex = RegExp(r'^\+[0-9]{10,15}$');
      if (!phoneRegex.hasMatch(cleanedPhone)) throw Exception('Некорректный номер телефона');
      final now = DateTime.now();
      if (birthDate.isAfter(now)) throw Exception('Дата рождения не может быть в будущем');
      final minAgeDate = DateTime(now.year - 14, now.month, now.day);
      if (birthDate.isAfter(minAgeDate)) throw Exception('Возраст должен быть не менее 14 лет');

      final passwordHash = _generatePasswordHash(password);

      final AuthResponse authResponse = await _supabase.client.auth.signUp(
        email: cleanedEmail,
        password: password,
        data: {
          'full_name': fullName.trim(),
          'phone': cleanedPhone,
          'role': role,
          'birth_date': birthDate.toIso8601String().split('T')[0],
          'position': position,
          'team_name': teamName,
          'experience': experience ?? '',
        },
      );
      if (authResponse.user == null) throw Exception('Регистрация не удалась');
      _currentUser = authResponse.user;

      final profileData = {
        'id': _currentUser!.id,
        'email': cleanedEmail,
        'full_name': fullName.trim(),
        'phone': cleanedPhone,
        'role': role,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        'position': position,
        'team_name': teamName,
        'experience': experience ?? '',
        'password_hash': passwordHash,
        'password_changed_at': DateTime.now().toUtc().toIso8601String(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      await _supabase.client.from('profiles').insert(profileData);
      await _supabase.client.from('password_history').insert({
        'user_id': _currentUser!.id,
        'password_hash': passwordHash,
        'changed_at': DateTime.now().toUtc().toIso8601String(),
      });

      final createdProfile = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', _currentUser!.id)
          .single();
      _userProfile = createdProfile;
      _selectedRole = role;
      await AuthStorage.saveCredentials(email, password);
      notifyListeners();
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('user already registered')) {
        throw Exception('Пользователь с таким email уже зарегистрирован');
      }
      if (msg.contains('phone already registered')) {
        throw Exception('Пользователь с таким номером телефона уже зарегистрирован');
      }
      throw Exception('Ошибка регистрации: ${e.message}');
    } catch (e) {
      debugPrint('Ошибка регистрации: $e');
      rethrow;
    }
  }

  // Обновление роли
  Future<void> updateRole(String newRole) async {
    if (_currentUser == null) return;
    try {
      await _supabase.client
          .from('profiles')
          .update({'role': newRole})
          .eq('id', _currentUser!.id);
      _userProfile?['role'] = newRole;
      _selectedRole = newRole;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления роли: $e');
    }
  }

  // Обновление профиля
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    try {
      await _supabase.client
          .from('profiles')
          .update(data)
          .eq('id', _currentUser!.id);
      _userProfile?.addAll(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления профиля: $e');
    }
  }

  // Выход
  Future<void> signOut() async {
    await _supabase.client.auth.signOut();
    _currentUser = null;
    _userProfile = null;
    _selectedRole = null;
    await AuthStorage.clearCredentials();
    notifyListeners();
  }

  // Вспомогательная очистка номера телефона
  String _cleanPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('8')) {
      cleaned = '+7${cleaned.substring(1)}';
    } else if (cleaned.startsWith('7') && !cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    } else if (cleaned.length == 10 && cleaned.startsWith('9')) {
      cleaned = '+7$cleaned';
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }
}