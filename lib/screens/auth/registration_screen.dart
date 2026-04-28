import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_storage.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  DateTime? _selectedDate;
  String? _selectedPosition;
  final List<String> _positions = [
    'Защитник', 'Связующий', 'Либеро', 'Диагональный', 'Доигровщик',
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.removeListener(_formatPhoneNumber);
    _phoneController.dispose();
    _teamNameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _formatPhoneNumber() {
    final text = _phoneController.text;
    if (text.isEmpty) return;
    String digitsOnly = text.replaceAll(RegExp(r'[^\d+]'), '');
    if (digitsOnly.startsWith('8')) {
      digitsOnly = '+7${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('7') && !digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    } else if (digitsOnly.length == 10 && digitsOnly.startsWith('9')) {
      digitsOnly = '+7$digitsOnly';
    } else if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    }
    String formatted = '';
    if (digitsOnly.startsWith('+7')) {
      final numbers = digitsOnly.substring(2);
      if (numbers.isNotEmpty) {
        formatted = '+7';
        if (numbers.isNotEmpty) {
          formatted += ' (${numbers.substring(0, numbers.length > 3 ? 3 : numbers.length)}';
          if (numbers.length > 3) {
            formatted += ') ${numbers.substring(3, numbers.length > 6 ? 6 : numbers.length)}';
            if (numbers.length > 6) {
              formatted += '-${numbers.substring(6, numbers.length > 8 ? 8 : numbers.length)}';
              if (numbers.length > 8) {
                formatted += '-${numbers.substring(8, numbers.length > 10 ? 10 : numbers.length)}';
              }
            }
          }
        }
      }
    } else {
      formatted = digitsOnly;
    }
    if (text != formatted) {
      _phoneController.value = _phoneController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  String _getCleanPhoneNumber() {
    String digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^\d+]'), '');
    if (digitsOnly.startsWith('8')) {
      digitsOnly = '+7${digitsOnly.substring(1)}';
    } else if (digitsOnly.startsWith('7') && !digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    } else if (digitsOnly.length == 10 && digitsOnly.startsWith('9')) {
      digitsOnly = '+7$digitsOnly';
    } else if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+$digitsOnly';
    }
    return digitsOnly;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.selectedRole ?? 'игрок';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).primaryColor.withAlpha(100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getRoleIcon(role), color: Theme.of(context).primaryColor, size: 24),
                    const SizedBox(width: 10),
                    Text(_getRoleDisplayName(role), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/role'),
                      child: Text('Изменить', style: TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700))),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', hintText: 'example@gmail.com', prefixIcon: Icon(Icons.email), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8F9FA)),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите email';
                  final email = value.trim();
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(email)) return 'Некорректный email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  hintText: 'Не менее 6 символов',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите пароль';
                  if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Подтвердите пароль',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Подтвердите пароль';
                  if (value != _passwordController.text) return 'Пароли не совпадают';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Полное имя', hintText: 'Иванов Иван Иванович', prefixIcon: Icon(Icons.person), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8F9FA)),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value == null || value.isEmpty ? 'Введите ваше имя' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                          : '',
                    ),
                    decoration: const InputDecoration(labelText: 'Дата рождения', hintText: 'Выберите дату', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8F9FA)),
                    validator: (value) => value == null || value.isEmpty ? 'Выберите дату рождения' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (role == 'игрок' || role == 'любитель')
                DropdownButtonFormField<String>(
                  initialValue: _selectedPosition,
                  decoration: InputDecoration(
                    labelText: role == 'игрок' ? 'Позиция в команде' : 'Позиция (если есть)',
                    prefixIcon: const Icon(Icons.sports_volleyball),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                  items: _positions.map((pos) => DropdownMenuItem(value: pos, child: Text(pos))).toList(),
                  onChanged: (value) => setState(() => _selectedPosition = value),
                  validator: (value) => value == null ? 'Выберите позицию' : null,
                ),
              const SizedBox(height: 16),
              if (role == 'игрок')
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(labelText: 'Название команды', hintText: 'Введите название вашей команды', prefixIcon: Icon(Icons.groups), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8F9FA)),
                  textInputAction: TextInputAction.next,
                ),
              const SizedBox(height: 16),
              if (role == 'игрок' || role == 'любитель')
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'Краткая история игр (опыт)',
                    hintText: 'Например: играю 3 года, любительская лига',
                    prefixIcon: Icon(Icons.history),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFF8F9FA),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон', hintText: '+7 (999) 123-45-67', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFF8F9FA)),
                keyboardType: TextInputType.phone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите телефон';
                  if (_getCleanPhoneNumber().length < 12) return 'Введите полный номер телефона';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/authorization'),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade700),
                      children: const [
                        TextSpan(text: 'Уже есть аккаунт? '),
                        TextSpan(text: 'Авторизоваться', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/role'),
                  child: Text('Вернуться к выбору роли', style: TextStyle(color: Colors.grey.shade600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        setState(() => _errorMessage = 'Выберите дату рождения');
        return;
      }
      final role = Provider.of<AuthProvider>(context, listen: false).selectedRole ?? 'игрок';
      if ((role == 'игрок' || role == 'любитель') && (_selectedPosition == null || _selectedPosition!.isEmpty)) {
        setState(() => _errorMessage = 'Выберите позицию');
        return;
      }
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phone: _getCleanPhoneNumber(),
          role: role,
          birthDate: _selectedDate!,
          position: role == 'игрок' || role == 'любитель' ? _selectedPosition : null,
          teamName: role == 'игрок' ? _teamNameController.text.trim() : null,
          experience: role == 'игрок' || role == 'любитель' ? _experienceController.text.trim() : null,
        );
        await AuthStorage.saveCredentials(_emailController.text.trim(), _passwordController.text);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text('Регистрация успешна!')]),
              content: const Column(mainAxisSize: MainAxisSize.min, children: [Text('Добро пожаловать!'), SizedBox(height: 10), Text('Теперь войдите в систему.')]),
              actions: [TextButton(onPressed: () { Navigator.pop(context); context.go('/authorization'); }, child: const Text('Войти'))],
            ),
          );
        }
      } catch (e) {
        setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'игрок': return 'Игрок';
      case 'любитель': return 'Любитель';
      case 'болельщик': return 'Болельщик';
      default: return 'Игрок';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'игрок': return Icons.sports_volleyball;
      case 'любитель': return Icons.person;
      case 'болельщик': return Icons.people;
      default: return Icons.person;
    }
  }
}