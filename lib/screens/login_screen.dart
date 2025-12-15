import 'package:flutter/material.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/screens/admin_home_screen.dart';
import 'package:hqapp/screens/forgot_password_screen.dart';
import 'package:hqapp/screens/home_screen.dart';
import 'package:hqapp/screens/register_screen.dart';
import 'package:hqapp/services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Clear previous errors first
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate form - this will trigger validators and show errors
    final isValid = _formKey.currentState!.validate();

    // If validation fails, manually check and set errors
    if (!isValid) {
      // Check email format
      final emailValue = _emailController.text.trim();
      if (emailValue.isEmpty) {
        setState(() {
          _emailError = 'Email cannot be empty.';
        });
      } else {
        final emailPattern = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailPattern.hasMatch(emailValue)) {
          setState(() {
            _emailError = 'Please enter a valid email like example@gmail.com';
          });
        } else if (!emailValue.toLowerCase().contains('.com')) {
          setState(() {
            _emailError = 'Email must contain .com';
          });
        } else if (emailValue.contains('.@') || emailValue.contains('@.')) {
          setState(() {
            _emailError = 'Please enter a valid email like example@gmail.com';
          });
        }
      }

      // Check password
      final passwordValue = _passwordController.text;
      if (passwordValue.isEmpty) {
        setState(() {
          _passwordError = 'Password cannot be empty.';
        });
      } else if (passwordValue.length < 8) {
        setState(() {
          _passwordError = 'Password must be at least 8 characters';
        });
      }

      // Re-validate to show the errors
      _formKey.currentState!.validate();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await FirestoreService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (user.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomeScreen(user: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      // Set error on both fields for authentication errors
      final errorMessage = error.message.toLowerCase();
      if (errorMessage.contains('email') ||
          errorMessage.contains('password') ||
          errorMessage.contains('invalid') ||
          errorMessage.contains('account') ||
          errorMessage.contains('not found')) {
        setState(() {
          // Set generic error message on both fields to show red glow
          _emailError = 'Email or password is incorrect';
          _passwordError = 'Email or password is incorrect';
        });
        // Trigger validation to show the error
        _formKey.currentState!.validate();
      } else {
        // General error - show on both fields
        setState(() {
          _emailError = error.message;
          _passwordError = error.message;
        });
        _formKey.currentState!.validate();
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _emailError = errorMessage.isEmpty
            ? 'An error occurred. Please try again.'
            : errorMessage;
        _passwordError = null;
      });
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: UserProfile.guest())),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
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
                            Icons.explore,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Heritage Quest',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B4423),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover Oman\'s Rich Heritage',
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
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    validator: (value) {
                      // First check if there's a state error from login attempt
                      if (_emailError != null) {
                        return _emailError;
                      }
                      // Only validate when form is submitted (when login button is pressed)
                      // Don't validate while typing
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty.';
                      }
                      // Better email validation - check format properly
                      final emailPattern = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailPattern.hasMatch(value)) {
                        return 'Please enter a valid email like example@gmail.com';
                      }
                      // Ensure it contains .com
                      if (!value.toLowerCase().contains('.com')) {
                        return 'Email must contain .com';
                      }
                      // Check that @ is not immediately before or after a dot
                      if (value.contains('.@') || value.contains('@.')) {
                        return 'Please enter a valid email like example@gmail.com';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
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
                      if (_passwordError != null) {
                        return _passwordError;
                      }
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: const Color(0xFF6B4423),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildGradientButton(
                    text: _isLoading ? 'Signing In...' : 'Login',
                    onPressed: _isLoading ? null : _login,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue as',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildOutlinedButton(
                    text: 'Continue as Guest',
                    onPressed: _continueAsGuest,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      TextButton(
                        onPressed: _goToRegister,
                        child: Text(
                          'Create one',
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
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (errorText != null)
                // Red glow effect when there's an error
                BoxShadow(
                  color: Colors.red.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              BoxShadow(
                color: errorText != null
                    ? Colors.red.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: errorText != null
                      ? Colors.red
                      : const Color(0xFF6B4423),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            validator: (value) {
              final result = validator?.call(value);
              // If there's an errorText from state, use that instead
              if (controller == _emailController && _emailError != null) {
                return _emailError;
              } else if (controller == _passwordController &&
                  _passwordError != null) {
                return _passwordError;
              }
              return result;
            },
            onChanged: (value) {
              // Clear error when user starts typing
              if (controller == _emailController && _emailError != null) {
                setState(() {
                  _emailError = null;
                });
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              } else if (controller == _passwordController &&
                  _passwordError != null) {
                setState(() {
                  _passwordError = null;
                });
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              }
            },
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
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

  Widget _buildOutlinedButton({required String text, VoidCallback? onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF6B4423), width: 2),
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: const Color(0xFF6B4423),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
