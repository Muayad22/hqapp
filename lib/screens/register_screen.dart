import 'package:flutter/material.dart';
import 'package:hqapp/screens/home_screen.dart';
import 'package:hqapp/services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitting = false;
  String _visitorType = 'Local'; // Default to 'Local' or 'Foreign'

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final user = await FirestoreService.registerUser(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        contactNo: _mobileController.text.trim(),
        password: _passwordController.text,
        visitorType: _visitorType,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showMessage(
        errorMessage.isEmpty
            ? 'An error occurred. Please try again.'
            : errorMessage,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goToLogin() {
    Navigator.pop(context);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6B4423).withOpacity(0.1),
              const Color(0xFF8B4513).withOpacity(0.05),
              const Color(0xFFB8860B).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6B4423),
                                const Color(0xFF8B4513),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B4423),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join the heritage exploration journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildModernTextField(
                    controller: _nameController,
                    labelText: 'Username / Display Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _mobileController,
                    labelText: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mobile number cannot be empty.';
                      }
                      // Check if contains only numbers
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Mobile number must contain only numbers.';
                      }
                      if (value.length != 8) {
                        return 'Mobile number must be exactly 8 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty.';
                      }
                      final emailPattern = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailPattern.hasMatch(value)) {
                        return 'Please enter a valid email like example@gmail.com';
                      }
                      if (!value.toLowerCase().contains('.com')) {
                        return 'Please enter a valid email like example@gmail.com';
                      }
                      if (value.contains('.@') || value.contains('@.')) {
                        return 'Please enter a valid email like example@gmail.com';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Visitor Type Radio Buttons
                  _buildVisitorTypeSelector(),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty.';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters.';
                      }
                      // Check if password contains both letters and numbers
                      final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
                      final hasNumbers = RegExp(r'[0-9]').hasMatch(value);
                      if (!hasLetters || !hasNumbers) {
                        return 'Password must contain letters and numbers.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cannot be empty';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildGradientButton(
                    text: _submitting
                        ? 'Creating Account...'
                        : 'Create Account',
                    onPressed: _submitting ? null : _signUp,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Login',
                          style: const TextStyle(
                            color: const Color(0xFF6B4423),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[700]),
          prefixIcon: Icon(icon, color: const Color(0xFF6B4423)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGradientButton({required String text, VoidCallback? onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B4423), const Color(0xFF8B4513)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4423).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: const Color(0xFF6B4423), size: 20),
              const SizedBox(width: 8),
              Text(
                'Visitor Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  value: 'Local',
                  label: 'Local Visitor',
                  icon: Icons.home,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  value: 'Foreign',
                  label: 'Foreign Visitor',
                  icon: Icons.flight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _visitorType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _visitorType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B4423).withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B4423) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: _visitorType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _visitorType = newValue;
                  });
                }
              },
              activeColor: const Color(0xFF6B4423),
            ),
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF6B4423) : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF6B4423)
                      : Colors.grey[700],
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
