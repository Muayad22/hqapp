import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class EmailService {
  /// Send OTP email using Firebase Cloud Functions with SMTP
  /// This will send the OTP to the user's personal email address
  /// The email is sent via SMTP configured in Firebase Cloud Functions
  static Future<void> sendOTPEmail({
    required String toEmail,
    required String otp,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sendOTPEmail');
      
      final result = await callable.call({
        'toEmail': toEmail,
        'otp': otp,
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Email sending timeout. Please try again.');
        },
      );

      if (kDebugMode) {
        print('✅ OTP email sent successfully to $toEmail');
        print('Result: ${result.data}');
      }
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Functions Error: ${e.code} - ${e.message}');
        // Still print OTP for debugging if email fails
        print('📧 OTP for $toEmail: $otp');
      }
      
      // Re-throw with user-friendly message
      switch (e.code) {
        case 'unauthenticated':
          throw Exception('Email service authentication failed. Please contact support.');
        case 'unavailable':
          throw Exception('Email service is currently unavailable. Please try again later.');
        case 'invalid-argument':
          throw Exception('Invalid email address. Please check and try again.');
        default:
          throw Exception('Failed to send email: ${e.message ?? "Please try again."}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending email: $e');
        // Still print OTP for debugging if email fails
        print('📧 OTP for $toEmail: $otp');
      }
      // Re-throw other errors
      rethrow;
    }
  }
}

