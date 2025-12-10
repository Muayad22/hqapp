import 'package:flutter/material.dart';
import 'package:hqapp/constants/app_text.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/services/email_service.dart';
import 'package:hqapp/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  bool _isLoading = false;
  String? _emailError;
  String? _otpError;
  String? _passwordError;
  String? _userEmail;
  String? _userId;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    // Clear previous errors first
    setState(() {
      _emailError = null;
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

      // Re-validate to show the errors
      _formKey.currentState!.validate();
      return;
    }

    setState(() => _isLoading = true);

    // DESIGN MODE: Skip email sending for design testing
    // Simulate a delay to show loading state
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _userEmail = _emailController.text.trim();
      _currentStep = 1; // Move to OTP step
      _isLoading = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP has been sent to ${_emailController.text.trim()}. Please check your email inbox.',
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }

    /* ORIGINAL CODE - Uncomment when ready to use real email
    try {
      // Generate and store OTP
      final otp = await FirestoreService.generateOTPForPasswordReset(
        email: _emailController.text.trim(),
      );

      // Send OTP via email
      await EmailService.sendOTPEmail(
        toEmail: _emailController.text.trim(),
        otp: otp,
      );

      if (!mounted) return;

      setState(() {
        _userEmail = _emailController.text.trim();
        _currentStep = 1; // Move to OTP step
        _isLoading = false;
      });

      // Show success message - OTP has been sent via email
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP has been sent to ${_emailController.text.trim()}. Please check your email inbox.'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      // Set error similar to login screen
      final errorMessage = e.message.toLowerCase();
      if (errorMessage.contains('email') || 
          errorMessage.contains('account') ||
          errorMessage.contains('not found')) {
        setState(() {
          _emailError = e.message;
        });
      } else {
        setState(() {
          _emailError = e.message;
        });
      }
      // Trigger validation to show the error
      _formKey.currentState!.validate();
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _emailError = errorMessage.isEmpty
            ? 'An error occurred. Please try again.'
            : errorMessage;
        _isLoading = false;
      });
      _formKey.currentState!.validate();
    }
    */
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _otpError = null;
    });

    final otpValue = _otpController.text.trim();

    if (otpValue.isEmpty) {
      setState(() {
        _otpError = 'Please enter the OTP';
      });
      return;
    }

    if (otpValue.length != 6) {
      setState(() {
        _otpError = 'OTP must be 6 digits';
      });
      return;
    }

    // Check if OTP contains only numbers
    if (!RegExp(r'^[0-9]+$').hasMatch(otpValue)) {
      setState(() {
        _otpError = 'OTP must contain only numbers';
      });
      return;
    }

    setState(() => _isLoading = true);

    // DESIGN MODE: Skip OTP verification for design testing
    // Simulate a delay to show loading state
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _userId = 'design-test-user-id'; // Dummy user ID for design testing
      _currentStep = 2; // Move to password reset step
      _isLoading = false;
    });

    /* ORIGINAL CODE - Uncomment when ready to use real OTP verification
    try {
      final userId = await FirestoreService.verifyOTPForPasswordReset(
        email: _userEmail!,
        otp: otpValue,
      );

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _currentStep = 2; // Move to password reset step
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _otpError = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _otpError = errorMessage.isEmpty
            ? 'An error occurred. Please try again.'
            : errorMessage;
        _isLoading = false;
      });
    }
    */
  }

  Future<void> _resetPassword() async {
    setState(() {
      _passwordError = null;
    });

    // Validate form
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // Check password requirements
      final newPassword = _newPasswordController.text;
      if (newPassword.isEmpty) {
        setState(() {
          _passwordError = 'Cannot be empty';
        });
      } else if (newPassword.length < 8) {
        setState(() {
          _passwordError = 'Password must be at least 8 characters';
        });
      } else {
        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(newPassword);
        final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);
        if (!hasLetter || !hasNumber) {
          setState(() {
            _passwordError = 'Password must contain letters and numbers';
          });
        } else if (newPassword != _confirmPasswordController.text) {
          setState(() {
            _passwordError = 'Passwords do not match';
          });
        }
      }
      return;
    }

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Additional validation
    if (newPassword.isEmpty) {
      setState(() {
        _passwordError = 'Cannot be empty';
      });
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
      return;
    }

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(newPassword);
    final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);

    if (!hasLetter || !hasNumber) {
      setState(() {
        _passwordError = 'Password must contain letters and numbers';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordError = 'Passwords do not match';
      });
      return;
    }

    setState(() => _isLoading = true);

    // DESIGN MODE: Skip password reset for design testing
    // Simulate a delay to show loading state
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pop(context); // Close forgot password screen

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset successfully! You can now login with your new password.',
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );

    /* ORIGINAL CODE - Uncomment when ready to use real password reset
    try {
      await FirestoreService.resetPasswordWithOTP(
        userId: _userId!,
        newPassword: newPassword,
      );

      if (!mounted) return;

      Navigator.pop(context); // Close forgot password screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! You can now login with your new password.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordError = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _passwordError = errorMessage.isEmpty
            ? 'Failed to reset password. Please try again.'
            : errorMessage;
        _isLoading = false;
      });
    }
    */
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
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.05),
              AppTheme.accentColor.withOpacity(0.1),
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
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
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentStep == 0
                              ? 'Enter your email address to receive an OTP code.'
                              : _currentStep == 1
                              ? 'Enter the 6-digit OTP sent to your email.'
                              : 'Enter your new password.',
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

                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(0, 'Email'),
                      _buildStepConnector(),
                      _buildStepIndicator(1, 'OTP'),
                      _buildStepConnector(),
                      _buildStepIndicator(2, 'Password'),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Step 0: Email input
                  if (_currentStep == 0) ...[
                    _buildModernTextField(
                      controller: _emailController,
                      labelText: AppText.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      validator: (value) {
                        // First check if there's a state error from send OTP attempt
                        if (_emailError != null) {
                          return _emailError;
                        }
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
                          return 'Email must contain .com';
                        }
                        if (value.contains('.@') || value.contains('@.')) {
                          return 'Please enter a valid email like example@gmail.com';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildGradientButton(
                      text: _isLoading ? 'Sending OTP...' : 'Send OTP',
                      onPressed: _isLoading ? null : _sendOTP,
                    ),
                  ],

                  // Step 1: OTP input
                  if (_currentStep == 1) ...[
                    Text(
                      'OTP sent to: ${_userEmail ?? ""}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _otpController,
                      labelText: 'Enter OTP',
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                      errorText: _otpError,
                      maxLength: 6,
                      validator: (value) {
                        if (_otpError != null) {
                          return _otpError;
                        }
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        if (value.length != 6) {
                          return 'OTP must be 6 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'OTP must contain only numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _currentStep = 0;
                                    _otpController.clear();
                                    _otpError = null;
                                  });
                                },
                          child: const Text('Change Email'),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          child: const Text('Resend OTP'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildGradientButton(
                      text: _isLoading ? 'Verifying...' : 'Verify OTP',
                      onPressed: _isLoading ? null : _verifyOTP,
                    ),
                  ],

                  // Step 2: New password input
                  if (_currentStep == 2) ...[
                    _buildModernTextField(
                      controller: _newPasswordController,
                      labelText: 'New Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureNewPassword,
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (_passwordError != null) {
                          return _passwordError;
                        }
                        if (value == null || value.isEmpty) {
                          return 'Cannot be empty';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                        final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                        if (!hasLetter || !hasNumber) {
                          return 'Password must contain letters and numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm New Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      errorText: null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildGradientButton(
                      text: _isLoading ? 'Resetting...' : 'Reset Password',
                      onPressed: _isLoading ? null : _resetPassword,
                    ),
                  ],

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      AppText.backToLogin,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? AppTheme.primaryColor
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive || isCompleted
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted
                ? AppTheme.primaryColor
                : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: _currentStep > 0 ? AppTheme.primaryColor : Colors.grey[300],
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
    int? maxLength,
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
                // Red glow effect when there's an error (like login screen)
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
            maxLength: maxLength,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.grey[700]),
              prefixIcon: Icon(icon, color: AppTheme.primaryColor),
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
                  color: errorText != null ? Colors.red : AppTheme.primaryColor,
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
              counterText: '',
            ),
            validator: validator,
            onChanged: (value) {
              // Clear error when user starts typing
              if (controller == _emailController && _emailError != null) {
                setState(() {
                  _emailError = null;
                });
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              } else if (controller == _otpController && _otpError != null) {
                setState(() {
                  _otpError = null;
                });
                if (_formKey.currentState != null) {
                  _formKey.currentState!.validate();
                }
              } else if ((controller == _newPasswordController ||
                      controller == _confirmPasswordController) &&
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
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
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
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
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
}
