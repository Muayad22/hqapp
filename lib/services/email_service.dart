import 'dart:io';
import 'dart:convert';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/foundation.dart';

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

      // Also print to console for immediate visibility
      print(
        '🔍 [DEBUG] $location: $message | Data: $data | Hypothesis: $hypothesisId',
      );
    } catch (e) {
      // Print error if logging fails
      print('❌ Debug log write failed: $e');
    }
  }
}

class EmailService {
  /// Send OTP email using email_otp package with SMTP
  /// This uses direct SMTP connection similar to the working example
  /// Returns the generated OTP so it can be stored in Firebase
  static Future<String> sendOTPEmail({
    required String toEmail,
    required String
    otp, // This parameter is kept for compatibility but won't be used
    String languageCode = 'en',
  }) async {
    // #region agent log
    _debugLog('email_service.dart:8', 'EmailService.sendOTPEmail called', {
      'toEmail': toEmail,
      'otp': otp,
    }, 'E');
    // #endregion

    try {
      if (kDebugMode) {
        print('📧 Attempting to send OTP email via email_otp package');
        print('📧 To: $toEmail');
      }

      // Configure EmailOTP with SMTP settings (matching working example)
      EmailOTP.config(
        appEmail: "noreply@hqapp.com",
        appName: languageCode == 'ar' ? "Heritage Quest" : "Heritage Quest",
        otpLength: 4,
        emailTheme: EmailTheme.v4,
        otpType: OTPType.numeric,
      );

      // Localized email template (English / Arabic)
      if (languageCode == 'ar') {
        EmailOTP.setTemplate(
          template: '''
          <div dir="rtl" style="background:#f5f5f5;padding:24px;font-family:Arial,Helvetica,sans-serif;">
            <div style="max-width:520px;margin:0 auto;background:#ffffff;border-radius:12px;padding:24px;border:1px solid #eee;">
              <h2 style="margin:0 0 12px 0;color:#6B4423;">{{appName}}</h2>
              <p style="margin:0 0 16px 0;color:#333;font-size:15px;line-height:1.6;">
                رمز التحقق الخاص بك هو:
              </p>
              <div style="font-size:28px;font-weight:700;letter-spacing:6px;color:#111;background:#faf7f3;border:1px solid #e8ddd2;border-radius:10px;padding:14px;text-align:center;">
                {{otp}}
              </div>
              <p style="margin:16px 0 0 0;color:#666;font-size:13px;line-height:1.6;">
                إذا لم تطلب هذا الرمز، يمكنك تجاهل هذه الرسالة.
              </p>
            </div>
          </div>
          ''',
        );
      } else {
        EmailOTP.setTemplate(
          template: '''
          <div style="background:#f5f5f5;padding:24px;font-family:Arial,Helvetica,sans-serif;">
            <div style="max-width:520px;margin:0 auto;background:#ffffff;border-radius:12px;padding:24px;border:1px solid #eee;">
              <h2 style="margin:0 0 12px 0;color:#6B4423;">{{appName}}</h2>
              <p style="margin:0 0 16px 0;color:#333;font-size:15px;line-height:1.6;">
                Your verification code is:
              </p>
              <div style="font-size:28px;font-weight:700;letter-spacing:6px;color:#111;background:#faf7f3;border:1px solid #e8ddd2;border-radius:10px;padding:14px;text-align:center;">
                {{otp}}
              </div>
              <p style="margin:16px 0 0 0;color:#666;font-size:13px;line-height:1.6;">
                If you didn’t request this code, you can ignore this email.
              </p>
            </div>
          </div>
          ''',
        );
      }

      // Configure SMTP settings (matching working example)
      EmailOTP.setSMTP(
        host: 'smtp.gmail.com',
        emailPort: EmailPort.port465,
        secureType: SecureType.ssl,
        username: '16S211644@gmail.com',
        password: 'ylsp oghj pwjl qrvi',
      );

      // #region agent log
      _debugLog('email_service.dart:30', 'EmailOTP configured', {
        'toEmail': toEmail,
        'smtpHost': 'smtp.gmail.com',
      }, 'E');
      // #endregion

      // #region agent log
      _debugLog('email_service.dart:60', 'Calling EmailOTP.sendOTP', {
        'toEmail': toEmail,
      }, 'E');
      // #endregion

      // Send OTP using static method (matching working example)
      final emailSent = await EmailOTP.sendOTP(email: toEmail);

      if (!emailSent) {
        // #region agent log
        _debugLog('email_service.dart:70', 'EmailOTP.sendOTP returned false', {
          'toEmail': toEmail,
        }, 'E');
        // #endregion

        throw Exception(
          'Failed to send OTP email. Please check SMTP configuration.',
        );
      }

      // Get the generated OTP using static method
      final generatedOtp = EmailOTP.getOTP();

      if (generatedOtp == null || generatedOtp.isEmpty) {
        throw Exception(
          'Failed to retrieve generated OTP from email_otp package.',
        );
      }

      // #region agent log
      _debugLog('email_service.dart:85', 'Email sent successfully', {
        'toEmail': toEmail,
        'generatedOtp': generatedOtp,
        'result': emailSent.toString(),
      }, 'E');
      // #endregion

      if (kDebugMode) {
        print('✅ OTP email sent successfully to $toEmail');
        print('✅ Generated OTP: $generatedOtp');
      }

      // Return the generated OTP so it can be stored in Firebase
      return generatedOtp;
    } catch (e) {
      // #region agent log
      _debugLog('email_service.dart:100', 'Exception in sendOTPEmail', {
        'toEmail': toEmail,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      }, 'E');
      // #endregion

      if (kDebugMode) {
        print('═══════════════════════════════════════');
        print('❌ ERROR SENDING EMAIL');
        print('═══════════════════════════════════════');
        print('📧 To Email: $toEmail');
        print('❌ Error Type: ${e.runtimeType}');
        print('❌ Full Error: $e');
        print('═══════════════════════════════════════');
      }

      // Re-throw the exception
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Failed to send email: $e');
      }
    }
  }
}
