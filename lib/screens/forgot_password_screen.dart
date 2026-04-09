import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:email_otp/email_otp.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/services/email_service.dart';
import 'package:hqapp/localization/app_localizations.dart';

// Debug logging helper
void _debugLog(
  String location,
  String message,
  Map<String, dynamic> data,
  String hypothesisId,
) {
  if (kDebugMode) {
    try {
      final logEntry = {
        'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': location,
        'message': message,
        'data': data,
        'sessionId': 'debug-session',
        'runId': 'run1',
        'hypothesisId': hypothesisId,
      };
      final logPath = r'c:\FlutterApps\hq\.cursor\debug.log';
      final logFile = File(logPath);

      // Create directory if it doesn't exist
      final logDir = logFile.parent;
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      // Write log entry
      logFile.writeAsStringSync(
        '${jsonEncode(logEntry)}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Error logging failed silently
    }
  }
}

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
  EmailOTP? myauth;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final l = AppLocalizations.of(context);
    // #region agent log
    _debugLog('forgot_password_screen.dart:41', 'Function _sendOTP called', {
      'email': _emailController.text.trim(),
    }, 'A');
    // #endregion

    // Clear previous errors first
    setState(() {
      _emailError = null;
    });

    // Validate form - this will trigger validators and show errors
    final isValid = _formKey.currentState!.validate();

    // #region agent log
    _debugLog('forgot_password_screen.dart:48', 'Form validation result', {
      'isValid': isValid,
      'email': _emailController.text.trim(),
    }, 'A');
    // #endregion

    // If validation fails, manually check and set errors
    if (!isValid) {
      // Check email format
      final emailValue = _emailController.text.trim();
      if (emailValue.isEmpty) {
        setState(() {
          _emailError = l.t('register_email_required');
        });
      } else {
        final emailPattern = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        if (!emailPattern.hasMatch(emailValue)) {
          setState(() {
            _emailError = l.t('register_email_invalid');
          });
        } else if (!emailValue.toLowerCase().contains('.com')) {
          setState(() {
            _emailError = l.t('register_email_invalid');
          });
        } else if (emailValue.contains('.@') || emailValue.contains('@.')) {
          setState(() {
            _emailError = l.t('register_email_invalid');
          });
        }
      }

      // Re-validate to show the errors
      _formKey.currentState!.validate();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // Check if user exists and get userId
      String userId;
      try {
        // This will throw AuthException if email doesn't exist, or return userId
        userId = await FirestoreService.generateOTPForPasswordReset(
          email: email,
        );
      } on AuthException catch (e) {
        if (!mounted) return;
        setState(() {
          _emailError = e.message;
          _isLoading = false;
        });
        _formKey.currentState!.validate();
        return;
      }

      // Generate and send 4-digit OTP via EmailService
      // EmailService will generate a 4-digit OTP and send it via email
      String generatedOtp;
      try {
        generatedOtp = await EmailService.sendOTPEmail(
          toEmail: email,
          otp: '',
          languageCode: AppLocalizations.currentLanguageCode,
        );

        // Verify the OTP is 4 digits
        if (generatedOtp.length != 4) {
          throw Exception('Generated OTP is not 4 digits. Please try again.');
        }

        if (kDebugMode) {
          print('OTP email sent successfully to $email');
        }
      } catch (emailError) {
        // If email sending fails, show error
        if (!mounted) return;
        setState(() {
          _emailError = l.t('forgot_password_failed_send_otp');
          _isLoading = false;
        });
        _formKey.currentState!.validate();
        return;
      }

      // Store the 4-digit OTP in Firebase (the one that was sent via email)
      try {
        await FirestoreService.storeOTPForPasswordReset(
          email: email,
          userId: userId,
          otp: generatedOtp,
        );
      } catch (e) {
        // If storing fails, log but continue (OTP was already sent)
        if (kDebugMode) {
          print('Warning: Failed to store OTP in Firebase: $e');
        }
      }

      if (!mounted) return;

      // Move to next step if OTP was generated and sent successfully
      setState(() {
        _userEmail = email;
        _currentStep = 1; // Move to OTP step
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('forgot_password_otp_sent')),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
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
          _emailError = AppLocalizations.localizeError(context, e.message);
        });
      } else {
        setState(() {
          _emailError = AppLocalizations.localizeError(context, e.message);
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
            ? l.t('register_generic_error')
            : errorMessage;
        _isLoading = false;
      });
      _formKey.currentState!.validate();
    }
  }

  Future<void> _resendOTP() async {
    final l = AppLocalizations.of(context);
    // Clear previous errors and OTP input
    setState(() {
      _otpError = null;
      _otpController.clear();
      _isLoading = true;
    });

    if (_userEmail == null || _userEmail!.isEmpty) {
      setState(() {
        _otpError = l.t('forgot_password_email_not_found');
        _isLoading = false;
      });
      return;
    }

    try {
      final email = _userEmail!;

      // #region agent log
      _debugLog('forgot_password_screen.dart:393', 'Resending OTP', {
        'email': email,
      }, 'B');
      // #endregion

      // Step 1: Verify email exists and get userId
      String userId;
      try {
        userId = await FirestoreService.verifyEmailExists(email);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _otpError = l.t('forgot_password_failed_verify_email');
          _isLoading = false;
        });
        return;
      }

      // Step 2: Generate and send 4-digit OTP via EmailService
      String generatedOtp;
      try {
        generatedOtp = await EmailService.sendOTPEmail(
          toEmail: email,
          otp: '',
          languageCode: AppLocalizations.currentLanguageCode,
        );

        // Verify the OTP is 4 digits
        if (generatedOtp.length != 4) {
          if (!mounted) return;
          setState(() {
            _otpError = l.t('forgot_password_failed_generate_otp');
            _isLoading = false;
          });
          return;
        }

        if (kDebugMode) {
          print('✅ New OTP email sent successfully to $email');
          print('✅ New Generated OTP: $generatedOtp');
        }
      } catch (emailError) {
        if (!mounted) return;
        setState(() {
          _otpError = l.t('forgot_password_failed_send_otp');
          _isLoading = false;
        });
        return;
      }

      // Step 3: Store the new OTP in Firebase (the one that was sent via email)
      try {
        await FirestoreService.storeOTPForPasswordReset(
          email: email,
          userId: userId,
          otp: generatedOtp,
        );
      } catch (e) {
        // If storing fails, log but continue (OTP was already sent)
        if (kDebugMode) {
          print('Warning: Failed to store OTP in Firebase: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _otpError = null;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('forgot_password_otp_sent')),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _otpError = l.t('forgot_password_failed_resend_otp');
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _otpError = null;
    });

    final otpValue = _otpController.text.trim();

    if (otpValue.isEmpty) {
      setState(() {
        _otpError = l.t('forgot_password_enter_otp_error');
      });
      _formKey.currentState?.validate();
      return;
    }

    if (otpValue.length != 4) {
      setState(() {
        _otpError = l.t('forgot_password_otp_4_digits');
      });
      _formKey.currentState?.validate();
      return;
    }

    // Check if OTP contains only numbers
    if (!RegExp(r'^[0-9]+$').hasMatch(otpValue)) {
      setState(() {
        _otpError = l.t('forgot_password_otp_numbers_only');
      });
      _formKey.currentState?.validate();
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        print('🔍 Verifying OTP: $otpValue for email: ${_userEmail}');
      }

      final userId = await FirestoreService.verifyOTPForPasswordReset(
        email: _userEmail!,
        otp: otpValue,
      );

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _currentStep = 2; // Move to password reset step
        _isLoading = false;
        _otpError = null; // Clear any previous errors
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('forgot_password_otp_verified')),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _otpError = AppLocalizations.localizeError(context, e.message);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Handle different types of exceptions with clear error messages
      String errorMessage;
      final errorString = e.toString().toLowerCase();

      // Check for specific error types
      if (errorString.contains('failed to verify otp') ||
          errorString.contains('verify otp')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else if (errorString.contains('connection timeout') ||
          errorString.contains('timeout')) {
        errorMessage = l.t('forgot_password_timeout');
      } else if (errorString.contains('permission')) {
        errorMessage = l.t('forgot_password_permission_error');
      } else if (errorString.contains('unavailable') ||
          errorString.contains('unreachable')) {
        errorMessage = l.t('forgot_password_cannot_connect_db');
      } else if (errorString.contains('failed to send') ||
          errorString.contains('email')) {
        // Don't show email sending errors during OTP verification
        errorMessage = l.t('forgot_password_failed_verify_otp');
      } else {
        // Generic error - make it clear it's about OTP verification
        final cleanError = e.toString().replaceFirst('Exception: ', '');
        if (cleanError.isEmpty || cleanError == e.toString()) {
          errorMessage = l.t('forgot_password_failed_verify_otp');
        } else {
          // Only show the error if it doesn't mention email sending
          if (cleanError.toLowerCase().contains('send') &&
              cleanError.toLowerCase().contains('email')) {
            errorMessage =
                l.t('forgot_password_failed_verify_otp');
          } else {
            errorMessage = l.t(
              'forgot_password_failed_verify_otp_with_error',
              params: {'error': cleanError},
            );
          }
        }
      }

      setState(() {
        _otpError = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final l = AppLocalizations.of(context);
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
          _passwordError = l.t('register_confirm_password_required');
        });
      } else if (newPassword.length < 8) {
        setState(() {
          _passwordError = l.t('register_password_min');
        });
      } else {
        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(newPassword);
        final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);
        if (!hasLetter || !hasNumber) {
          setState(() {
            _passwordError = l.t('register_password_pattern');
          });
        } else if (newPassword != _confirmPasswordController.text) {
          setState(() {
            _passwordError = l.t('register_confirm_password_mismatch');
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
        _passwordError = l.t('register_confirm_password_required');
      });
      return;
    }

    if (newPassword.length < 8) {
      setState(() {
        _passwordError = l.t('register_password_min');
      });
      return;
    }

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(newPassword);
    final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);

    if (!hasLetter || !hasNumber) {
      setState(() {
        _passwordError = l.t('register_password_pattern');
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordError = l.t('register_confirm_password_mismatch');
      });
      return;
    }

    // Validate userId is available
    if (_userId == null || _userId!.isEmpty) {
      setState(() {
        _passwordError = l.t('forgot_password_session_expired');
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService.resetPasswordWithOTP(
        userId: _userId!,
        newPassword: newPassword,
        email: _userEmail, // Pass email as fallback
      );

      if (!mounted) return;

      Navigator.pop(context); // Close forgot password screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('forgot_password_reset_success')),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordError = AppLocalizations.localizeError(context, e.message);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _passwordError = errorMessage.isEmpty
            ? l.t('forgot_password_failed_reset')
            : errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLangChip(
                            label: 'EN',
                            isSelected:
                                AppLocalizations.currentLanguageCode == 'en',
                            onTap: () {
                              setState(() {
                                AppLocalizations.setLanguage('en');
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildLangChip(
                            label: 'ع',
                            isSelected:
                                AppLocalizations.currentLanguageCode == 'ar',
                            onTap: () {
                              setState(() {
                                AppLocalizations.setLanguage('ar');
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                                const Color(0xFF6B4423),
                                const Color(0xFF8B4513),
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
                        Text(
                          l.t('forgot_password_title'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B4423),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentStep == 0
                              ? l.t('forgot_password_hint_email')
                              : _currentStep == 1
                              ? l.t('forgot_password_hint_otp')
                              : l.t('forgot_password_hint_password'),
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
                      _buildStepIndicator(0, l.t('forgot_password_step_email')),
                      _buildStepConnector(),
                      _buildStepIndicator(1, l.t('forgot_password_step_otp')),
                      _buildStepConnector(),
                      _buildStepIndicator(
                        2,
                        l.t('forgot_password_step_password'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Step 0: Email input
                  if (_currentStep == 0) ...[
                    _buildModernTextField(
                      controller: _emailController,
                      labelText: l.t('email'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      validator: (value) {
                        // First check if there's a state error from send OTP attempt
                        if (_emailError != null) {
                          return _emailError;
                        }
                        if (value == null || value.isEmpty) {
                          return l.t('register_email_required');
                        }
                        final emailPattern = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailPattern.hasMatch(value)) {
                          return l.t('register_email_invalid');
                        }
                        if (!value.toLowerCase().contains('.com')) {
                          return l.t('register_email_invalid');
                        }
                        if (value.contains('.@') || value.contains('@.')) {
                          return l.t('register_email_invalid');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildGradientButton(
                      text: _isLoading
                          ? l.t('forgot_password_sending_otp')
                          : l.t('forgot_password_send_otp'),
                      onPressed: _isLoading ? null : _sendOTP,
                    ),
                  ],

                  // Step 1: OTP input
                  if (_currentStep == 1) ...[
                    Text(
                      l.t(
                        'forgot_password_otp_sent_to',
                        params: {'email': _userEmail ?? ''},
                      ),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _otpController,
                      labelText: l.t('forgot_password_enter_otp'),
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                      errorText: _otpError,
                      maxLength: 4,
                      validator: (value) {
                        if (_otpError != null) {
                          return _otpError;
                        }
                        if (value == null || value.isEmpty) {
                          return l.t('forgot_password_enter_otp_error');
                        }
                        if (value.length != 4) {
                          return l.t('forgot_password_otp_4_digits');
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return l.t('forgot_password_otp_numbers_only');
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
                          child: Text(l.t('forgot_password_change_email')),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: _isLoading ? null : _resendOTP,
                          child: Text(l.t('forgot_password_resend_otp')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildGradientButton(
                      text: _isLoading
                          ? l.t('forgot_password_verifying')
                          : l.t('forgot_password_verify_otp'),
                      onPressed: _isLoading ? null : _verifyOTP,
                    ),
                  ],

                  // Step 2: New password input
                  if (_currentStep == 2) ...[
                    _buildModernTextField(
                      controller: _newPasswordController,
                      labelText: l.t('new_password'),
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
                          return l.t('register_confirm_password_required');
                        }
                        if (value.length < 8) {
                          return l.t('register_password_min');
                        }
                        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                        final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                        if (!hasLetter || !hasNumber) {
                          return l.t('register_password_pattern');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildModernTextField(
                      controller: _confirmPasswordController,
                      labelText: l.t('confirm_new_password'),
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
                          return l.t('register_confirm_password_required');
                        }
                        if (value != _newPasswordController.text) {
                          return l.t('register_confirm_password_mismatch');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildGradientButton(
                      text: _isLoading
                          ? l.t('forgot_password_resetting')
                          : l.t('forgot_password_reset_password'),
                      onPressed: _isLoading ? null : _resetPassword,
                    ),
                  ],

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l.t('forgot_password_back_to_login'),
                      style: const TextStyle(
                        color: Color(0xFF6B4423),
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
                ? const Color(0xFF6B4423)
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
                ? const Color(0xFF6B4423)
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
      color: _currentStep > 0 ? const Color(0xFF6B4423) : Colors.grey[300],
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
            inputFormatters: controller == _otpController
                ? [LengthLimitingTextInputFormatter(4)]
                : maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : null,
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
                // Clear error when user starts typing, but don't validate in real-time
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

  Widget _buildLangChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B4423) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B4423),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
