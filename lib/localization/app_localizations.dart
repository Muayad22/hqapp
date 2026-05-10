import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.languageCode);

  final String languageCode;

  static String _currentLanguageCode = 'en';
// save the currentLanguageCode to know what language is currently selected
  static String get currentLanguageCode => _currentLanguageCode;

  static void setLanguage(String code) {
    if (code == 'en' || code == 'ar') {
      _currentLanguageCode = code;
    }
  }

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(_currentLanguageCode);
  }

  
  // translator for error messages.
  static String localizeError(BuildContext context, String rawMessage) {
    final l = AppLocalizations.of(context);
    final msg = rawMessage.trim();  // removes extra spaces.
    final lower = msg.toLowerCase();

    
    if (lower.contains('the email is not registered')) {
      return l.t('auth_email_not_registered');
    }
    if (lower.contains('invalid email or password')) {
      return l.t('login_invalid_credentials');
    }
    if (lower.contains('account has been disabled')) {
      return l.t('auth_account_disabled');
    }
    if (lower.contains('user not found')) {
      return l.t('auth_user_not_found');
    }
    if (lower.contains('current password is incorrect')) {
      return l.t('auth_current_password_incorrect');
    }
    if (lower.contains('wrong otp')) {
      return l.t('auth_wrong_otp');
    }
    if (lower.contains('otp has expired')) {
      return l.t('auth_otp_expired');
    }
    if (lower.contains('account is not disabled')) {
      return l.t('auth_appeal_account_not_disabled');
    }
    if (lower.contains('please enter a message for the administrator')) {
      return l.t('auth_appeal_message_required');
    }
    if (lower.contains('message is too long')) {
      return l.t('auth_appeal_message_too_long');
    }

    if (lower.contains('connection timeout')) {
      return l.t('forgot_password_timeout');
    }
    if (lower.contains('database permission error')) {
      return l.t('forgot_password_permission_error');
    }
    if (lower.contains('cannot connect to database')) {
      return l.t('forgot_password_cannot_connect_db');
    }

    return msg;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Heritage Quest',
      'login_title': 'Login',
      'login_subtitle': "Discover Oman's Rich Heritage",
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'login_button': 'Login',
      'signing_in': 'Signing In...',
      'login_password_required': 'Please enter your password',
      'login_invalid_credentials': 'Email or password is incorrect',
      'auth_email_not_registered': 'The email is not registered.',
      'auth_user_not_found': 'User not found.',
      'auth_current_password_incorrect': 'Current password is incorrect.',
      'auth_wrong_otp': 'Wrong OTP, please try again.',
      'auth_otp_expired': 'OTP has expired. Please request a new one.',
      'auth_account_disabled':
          'This account has been disabled. Please contact support.',
      'login_disabled_support_title': 'Need help with a disabled account?',
      'login_disabled_appeal_section_title': 'Message to administrators',
      'login_disabled_appeal_field_hint':
          'Explain why you need your account re-enabled…',
      'login_disabled_appeal_submit': 'Send to administrators',
      'login_disabled_appeal_submitting': 'Sending…',
      'login_disabled_appeal_sent':
          'Your message was sent. An administrator will review it.',
      'login_disabled_appeal_empty': 'Please enter a message before sending.',
      'auth_appeal_account_not_disabled':
          'This account is not disabled. You can sign in normally.',
      'auth_appeal_message_required':
          'Please enter a message for the administrator.',
      'auth_appeal_message_too_long':
          'Message is too long. Use at most 2000 characters.',
      'admin_user_support_title': 'Support for disabled accounts',
      'admin_user_support_card_title': 'User support',
      'admin_user_support_card_subtitle':
          'Messages from disabled accounts; super admins can enable sign-in',
      'admin_user_support_empty': 'No messages yet.',
      'admin_user_support_message_label': 'User message',
      'admin_user_support_enable_account': 'Enable account',
      'admin_user_support_enable_confirm':
          'Allow {name} to sign in again?',
      'or_continue_as': 'or continue as',
      'continue_as_guest': 'Continue as Guest',
      'no_account': "Don't have an account? ",
      'create_one': 'Create one',
      'welcome_guest': 'Welcome, Guest!',
      'welcome_user': 'Welcome, {name}!',
      'scan_explore_earn': 'Scan, Explore, Earn',
      'mobile': 'Mobile',
      'edit_account': 'Edit Account',
      'tutorial':'Tutorial',
      'skip':'Skip',
      'next':'Next',
      'finish':'Finish',
      'feedback': 'Feedback',
      'feedback_title': 'Feedback',
      'feedback_prompt': 'Share your suggestions to improve the experience.',
      'feedback_label': 'Your Feedback',
      'feedback_empty_error': 'Feedback cannot be empty',
      'feedback_submitting': 'Submitting...',
      'feedback_submit': 'Submit',
      'feedback_submitted': 'Feedback submitted. Thank you!',
      'feedback_submit_failed': 'Unable to submit feedback right now.',
      'feedback_rating_label': 'Your rating',
      'feedback_rating_required': 'Please tap the stars to rate your experience.',
      'logout': 'Logout',
      'save': 'Save',
      'cancel': 'Cancel',
      'full_name': 'Full Name',
      'mobile_number': 'Mobile Number',
      'profile_updated_success': 'Profile updated successfully',
      'change_password': 'Change Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'password_changed_success': 'Password changed successfully',
      'change_password_error': 'Error changing password: {error}',
      'password_requirements_min8': 'Password must be at least 8 characters',
      'password_requirements_min6': 'Password must be at least 6 characters',
      'password_requirements_letter':
          'Password must contain at least one letter',
      'password_requirements_number':
          'Password must contain at least one number',
      'passwords_do_not_match': 'Passwords do not match',
      'enter_current_password': 'Please enter your current password',
      'enter_new_password': 'Please enter your new password',
      'confirm_new_password_prompt': 'Please confirm your new password',
      'achievements_points_suffix': 'pts',
      'achievements_refresh': 'Refresh',
      'quiz_completed_notification_title': 'Quiz Completed!',
      'quiz_completed_notification_message':
          'You scored {score} out of {total}. {suffix}',
      'quiz_completed_suffix_perfect': 'Perfect score!',
      'quiz_completed_suffix_great': 'Great job!',
      'achievement_unlocked_first_quiz_title':
          '🎯 Achievement Unlocked: First Quiz!',
      'achievement_unlocked_first_quiz_message':
          'You completed your first quiz! Keep exploring to unlock more achievements.',
      'achievement_unlocked_perfect_score_title':
          '🏆 Achievement Unlocked: Perfect Score!',
      'achievement_unlocked_perfect_score_message':
          'Amazing! You got full marks in the quiz!',
      'achievement_unlocked_quiz_master_title':
          '📚 Achievement Unlocked: Quiz Master!',
      'achievement_unlocked_quiz_master_message':
          "Congratulations! You've completed 3 quizzes. You're becoming a quiz master!",
      'achievement_unlocked_flawless_victory_title':
          '⭐ Achievement Unlocked: Flawless Victory!',
      'achievement_unlocked_flawless_victory_message':
          'Incredible! You got a perfect score on a quiz with 3 or more questions!',
      'achievement_unlocked_first_scan_title':
          '📷 Achievement Unlocked: First Scan!',
      'achievement_unlocked_first_scan_message':
          'You opened your first heritage location from a QR code. Keep scanning!',
      'achievement_unlocked_keen_scanner_title':
          '🧭 Achievement Unlocked: Keen Scanner!',
      'achievement_unlocked_keen_scanner_message':
          'You scanned 5 heritage locations. Great exploring!',
      // Achievements details (titles/descriptions)
      'achievement_1_title': 'First Quiz',
      'achievement_1_desc': 'Complete your first quiz',
      'achievement_2_title': 'Perfect Score',
      'achievement_2_desc': 'Get full marks in a quiz',
      'achievement_3_title': 'Quiz Master',
      'achievement_3_desc': 'Complete 3 quizzes',
      'achievement_4_title': 'History Expert',
      'achievement_4_desc': 'Complete 5 quizzes',
      'achievement_5_title': 'Flawless Victory',
      'achievement_5_desc': 'Perfect score on a quiz with 3+ questions',
      'achievement_6_title': 'Dedicated Learner',
      'achievement_6_desc': 'Complete 10 quizzes',
      'achievement_7_title': 'Speed Demon',
      'achievement_7_desc': 'Complete 2 quizzes on the same day',
      'achievement_8_title': 'Heritage Scholar',
      'achievement_8_desc': 'Complete 15 quizzes',
      'achievement_9_title': 'Perfect Streak',
      'achievement_9_desc': 'Get 2 perfect scores (any time)',
      'achievement_10_title': 'Master Explorer',
      'achievement_10_desc': 'Complete 25 quizzes',
      'achievement_11_title': 'Quick Thinker',
      'achievement_11_desc': 'Complete 8 quizzes in total',
      'achievement_12_title': 'Consistent Performer',
      'achievement_12_desc': 'Complete 3 quizzes within 7 days',
      'achievement_13_title': 'First Scan',
      'achievement_13_desc': 'Scan a QR code and open a heritage location',
      'achievement_14_title': 'Keen Scanner',
      'achievement_14_desc': 'Scan 5 different heritage QR codes',
      'quiz_save_error': 'Error saving quiz result: {error}',
      // Home
      'home_tab_home': 'Home',
      'home_tab_scan': 'Scan',
      'home_tab_profile': 'Profile',
      'home_leaderboard_stats': 'Stats',
      'home_points': 'Points',
      'home_earn_points': 'Earn points!',
      'home_rank': 'Rank',
      'home_start_playing': 'Start playing!',
      'home_quiz_title': 'Nizwa Castle Quiz',
      'home_quiz_subtitle': 'Test your knowledge about Nizwa Castle',
      'home_map_title': 'Map',
      'home_map_subtitle': 'Track your location',
      'home_leaderboard_title': 'Leaderboard',
      'home_leaderboard_subtitle': 'Track your progress and compete',
      'home_achievements_title': 'Achievements',
      'home_achievements_subtitle': 'Unlock badges and earn rewards',
      'home_stats_hint':
          'Keep playing quizzes to unlock more achievements and improve your ranking!',
      'notifications_title': 'Notifications',
      'notifications_login_required': 'Login Required',
      'notifications_login_message':
          'You need to login to view notifications!',
      'notifications_mark_all_read': 'Mark all read',
      'notifications_empty_title': 'No Notifications',
      'notifications_empty_message':
          "You'll see achievement and quiz notifications here!",
      'notifications_deleted': 'Notification deleted',
      'time_just_now': 'Just now',
      'time_minutes_ago': '{value}m ago',
      'time_hours_ago': '{value}h ago',
      'time_yesterday': 'Yesterday',
      'time_days_ago': '{value}d ago',
      'achievements_title': 'Achievements',
      'achievements_login_required_message':
          'You need to login to access the achievement page.',
      'achievements_your_achievements': 'Your Achievements',
      'achievements_header_message':
          'Complete quizzes and scan heritage QR codes to unlock badges and earn points!',
      'achievements_unlocked': 'Unlocked',
      'achievements_total_points': 'Total Points',
      'achievements_start_playing': 'Start playing!',
      'achievements_earn_points': 'Earn points!',
      'leaderboard_title': 'Leaderboard',
      'leaderboard_search_hint': 'Search player...',
      'leaderboard_error_title': 'Error loading leaderboard',
      'leaderboard_retry': 'Retry',
      'leaderboard_empty_title': 'No players on leaderboard yet',
      'leaderboard_empty_message':
          'Complete quizzes to earn points and appear here!',
      'leaderboard_points_label': '{value} points',
      'quiz_title': 'Nizwa Castle Quiz',
      'quiz_login_required_message':
          'You need to login to access the quiz page.',
      'quiz_login_button': 'Login',
      'quiz_next_question': 'Next Question',
      'quiz_finish_quiz': 'Finish Quiz',
      'quiz_explanation': 'Explanation:',
      'quiz_try_again': 'Try Again',
      'quiz_back_home': 'Back to Home',
      'quiz_score_label': 'Score: {value}',
      'quiz_completed_title': 'Quiz Completed!',
      'quiz_score_message_excellent':
          'Excellent! You are a Nizwa Castle expert! 🏆',
      'quiz_score_message_very_good':
          'Very Good! You have good knowledge about Nizwa Castle! 👍',
      'quiz_score_message_ok':
          'Not bad! Learn more about Nizwa Castle! 📚',
      'quiz_score_message_try_again':
          "Try again! Discover more about Oman's heritage! 🏰",
      // Register / create account
      'register_title': 'Create Account',
      'register_subtitle': 'Join the heritage exploration journey',
      'register_username_label': 'Username / Display Name',
      'register_username_required': 'Please enter your username',
      'register_username_min':
          'Username must be at least 3 characters',
      'register_mobile_label': 'Mobile Number',
      'register_mobile_required': 'Mobile number cannot be empty.',
      'register_mobile_digits':
          'Mobile number must contain only numbers.',
      'register_mobile_length':
          'Mobile number must be exactly 8 digits',
      'register_email_label': 'Email',
      'register_email_required': 'Email cannot be empty.',
      'register_email_invalid':
          'Please enter a valid email like example@gmail.com',
      'register_visitor_type': 'Visitor Type',
      'register_visitor_local': 'Local Visitor',
      'register_visitor_foreign': 'Foreign Visitor',
      'register_password_label': 'Password',
      'register_password_required': 'Password cannot be empty.',
      'register_password_min':
          'Password must be at least 8 characters.',
      'register_password_pattern':
          'Password must contain letters and numbers.',
      'register_confirm_password_label': 'Confirm Password',
      'register_confirm_password_required': 'Cannot be empty',
      'register_confirm_password_mismatch': 'Passwords do not match',
      'register_button_creating': 'Creating Account...',
      'register_button_create': 'Create Account',
      'register_have_account': 'Already have an account? ',
      'register_login': 'Login',
      'register_generic_error':
          'An error occurred. Please try again.',
      // Map / QR
      'map_title': 'Map',
      'map_find_location_button': 'Find your current location',
      'map_image_not_found': 'Image not found: fullMap.png',
      'qr_title': 'QR Scanner',
      'qr_scan_again': 'Scan Again',
      'qr_location_title': 'Your Location',
      'qr_location_image_not_found': 'Location image not found',
      'qr_no_location_image': 'No location image found',
      // Admin
      'admin_title': '{app} Admin',
      'admin_welcome': 'Welcome, {name}',
      'admin_subtitle': 'Keep the heritage community engaged',
      'admin_manage_users': 'Manage Users',
      'admin_manage_users_subtitle':
          'View all users; super admins can disable accounts and change roles',
      'admin_check_feedback': 'Check Feedback',
      'admin_check_feedback_subtitle': 'Review suggestions from visitors',
      'admin_check_leaderboard': 'Check Leaderboard',
      'admin_check_leaderboard_subtitle': 'Monitor quiz performances',
      'admin_feedback_title': 'Feedback',
      'admin_feedback_error_title': 'Error loading feedback',
      'admin_feedback_empty_title': 'No feedback yet',
      'admin_feedback_empty_message': 'Feedback from visitors will appear here',
      'admin_feedback_anonymous': 'Anonymous',
      'admin_feedback_guest_badge': 'Guest',
      'admin_feedback_no_rating': 'No star rating (older entry)',
      'admin_users_title': 'Manage Users',
      'admin_users_error_title': 'Error loading users',
      'admin_retry': 'Retry',
      'admin_no_users': 'No users found.',
      'admin_contact': 'Contact',
      'admin_admin': 'Admin',
      'admin_role': 'Role',
      'admin_role_user': 'User',
      'admin_role_admin': 'Admin',
      'admin_role_super_admin': 'Super Admin',
      'yes': 'Yes',
      'no': 'No',
      'admin_make_admin_q': 'Make Admin?',
      'admin_remove_admin_q': 'Remove Admin?',
      'admin_make_admin_msg': 'Make {name} an administrator?',
      'admin_remove_admin_msg': 'Remove administrator privileges from {name}?',
      'admin_make_admin_btn': 'Make Admin',
      'admin_remove_admin_btn': 'Remove Admin',
      'admin_disable_user_q': 'Disable account?',
      'admin_disable_user_msg':
          '{name} will not be able to sign in until the account is enabled again.',
      'admin_enable_user_q': 'Enable account?',
      'admin_enable_user_msg': 'Allow {name} to sign in again?',
      'admin_disable': 'Disable',
      'admin_enable': 'Enable',
      'admin_user_disabled': 'Account disabled for {name}',
      'admin_user_enabled': 'Account enabled for {name}',
      'admin_status_disabled': 'Account disabled (cannot sign in)',
      'admin_now_admin': '{name} is now an admin',
      'admin_admin_removed': 'Admin privileges removed from {name}',
      'admin_update_user_error': 'Error updating user: {error}',
      // Admin analytics (charts)
      'admin_analytics_title': 'Analytics',
      'admin_analytics_subtitle': 'Charts for users and quizzes',
      'admin_analytics_error': 'Error loading analytics',
      'admin_analytics_empty_users': 'No users found to analyze.',
      'admin_analytics_empty_quiz': 'No quiz results yet.',
      'admin_analytics_users_section': 'Users',
      'admin_analytics_total_users': 'Total users',
      'admin_analytics_local': 'Local',
      'admin_analytics_foreign': 'Foreign',
      'admin_analytics_visitor_split': 'Visitor Type Split',
      'admin_analytics_quiz_section': 'Quiz Activity',
      'admin_analytics_attempts': 'Attempts',
      'admin_analytics_avg_score': 'Avg score',
      'admin_analytics_perfect_scores': 'Perfect scores',
      'admin_analytics_quiz_overview_chart': 'Quiz Overview (Chart)',
      'admin_analytics_accuracy_detail': '{correct} correct out of {total}',
      'admin_analytics_top_users': 'Top users (by attempts)',
      'admin_analytics_attempts_label': '{value} attempts',
      'admin_analytics_feedback_section': 'Feedback & ratings',
      'admin_analytics_feedback_total': 'Feedback items',
      'admin_analytics_feedback_avg_rating': 'Avg rating (all)',
      'admin_analytics_feedback_guest_pct': 'Guest share',
      'admin_analytics_feedback_user_pct': 'Registered share',
      'admin_analytics_feedback_avg_guest': 'Avg rating (guests)',
      'admin_analytics_feedback_avg_user': 'Avg rating (members)',
      'admin_analytics_feedback_empty': 'No feedback submitted yet.',
      'admin_analytics_feedback_source_split': 'Feedback by account',
      'admin_analytics_feedback_guest_legend': 'Guest',
      'admin_analytics_feedback_user_legend': 'Registered',
      // Forgot password
      'forgot_password_title': 'Forgot Password?',
      'forgot_password_step_email': 'Email',
      'forgot_password_step_otp': 'OTP',
      'forgot_password_step_password': 'Password',
      'forgot_password_hint_email':
          'Enter your email address to receive an OTP code.',
      'forgot_password_hint_otp': 'Enter the 4-digit OTP sent to your email.',
      'forgot_password_hint_password': 'Enter your new password.',
      'forgot_password_send_otp': 'Send OTP',
      'forgot_password_sending_otp': 'Sending OTP...',
      'forgot_password_otp_sent':
          'OTP has been sent. Please check your email inbox.',
      'forgot_password_otp_sent_to': 'OTP sent to: {email}',
      'forgot_password_enter_otp': 'Enter OTP',
      'forgot_password_change_email': 'Change Email',
      'forgot_password_resend_otp': 'Resend OTP',
      'forgot_password_verify_otp': 'Verify OTP',
      'forgot_password_verifying': 'Verifying...',
      'forgot_password_otp_verified':
          'OTP verified successfully! Please enter your new password.',
      'forgot_password_reset_password': 'Reset Password',
      'forgot_password_resetting': 'Resetting...',
      'forgot_password_back_to_login': 'Back to Login',
      'forgot_password_email_not_found':
          'Email not found. Please go back and enter your email again.',
      'forgot_password_failed_verify_email':
          'Failed to verify email. Please try again.',
      'forgot_password_failed_generate_otp':
          'Failed to generate OTP. Please try again.',
      'forgot_password_failed_send_otp':
          'Failed to send OTP email. Please try again.',
      'forgot_password_failed_resend_otp':
          'Failed to resend OTP. Please try again.',
      'forgot_password_enter_otp_error': 'Please enter the OTP',
      'forgot_password_otp_4_digits': 'OTP must be 4 digits',
      'forgot_password_otp_numbers_only': 'OTP must contain only numbers',
      'forgot_password_timeout':
          'Connection timeout. Please check your internet connection and try again.',
      'forgot_password_permission_error':
          'Database permission error. Please contact support.',
      'forgot_password_cannot_connect_db':
          'Cannot connect to database. Please check your internet connection and try again.',
      'forgot_password_failed_verify_otp':
          'Failed to verify OTP. Please check the code and try again.',
      'forgot_password_failed_verify_otp_with_error':
          'Failed to verify OTP: {error}',
      'forgot_password_session_expired':
          'Session expired. Please start the password reset process again.',
      'forgot_password_reset_success':
          'Password reset successfully! You can now login with your new password.',
      'forgot_password_failed_reset':
          'Failed to reset password. Please try again.',
      'video_player':'Video Player',
      'audio_player':'Audio Player',
    },
    'ar': {
      'app_title': 'Heritage Quest', //  title
      'login_title': 'تسجيل الدخول',
      'login_subtitle': 'اكتشف تراث عُمان الغني',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'هل نسيت كلمة المرور؟',
      'login_button': 'تسجيل الدخول',
      'signing_in': 'جاري تسجيل الدخول...',
      'login_password_required': 'يرجى إدخال كلمة المرور',
      'login_invalid_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'auth_email_not_registered': 'البريد الإلكتروني غير مسجّل.',
      'auth_user_not_found': 'المستخدم غير موجود.',
      'auth_current_password_incorrect': 'كلمة المرور الحالية غير صحيحة.',
      'auth_wrong_otp': 'رمز التحقق غير صحيح، حاول مرة أخرى.',
      'auth_otp_expired': 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد.',
      'auth_account_disabled': 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم.',
      'login_disabled_support_title': 'تحتاج مساعدة بخصوص حساب معطّل؟',
      'login_disabled_appeal_section_title': 'رسالة للمشرفين',
      'login_disabled_appeal_field_hint': 'اشرح سبب طلب إعادة تفعيل حسابك…',
      'login_disabled_appeal_submit': 'إرسال للمشرفين',
      'login_disabled_appeal_submitting': 'جاري الإرسال…',
      'login_disabled_appeal_sent':
          'تم إرسال رسالتك. سيقوم المشرف بمراجعتها.',
      'login_disabled_appeal_empty': 'يرجى كتابة رسالة قبل الإرسال.',
      'auth_appeal_account_not_disabled':
          'هذا الحساب غير معطّل. يمكنك تسجيل الدخول بشكل طبيعي.',
      'auth_appeal_message_required':
          'يرجى إدخال رسالة للمشرف.',
      'auth_appeal_message_too_long':
          'الرسالة طويلة جداً. الحد الأقصى 2000 حرف.',
      'admin_user_support_title': 'دعم الحسابات المعطّلة',
      'admin_user_support_card_title': 'دعم المستخدمين',
      'admin_user_support_card_subtitle':
          'رسائل من حسابات معطّلة؛ المشرف الأعلى يمكنه تفعيل تسجيل الدخول',
      'admin_user_support_empty': 'لا توجد رسائل بعد.',
      'admin_user_support_message_label': 'رسالة المستخدم',
      'admin_user_support_enable_account': 'تفعيل الحساب',
      'admin_user_support_enable_confirm':
          'السماح لـ {name} بتسجيل الدخول مرة أخرى؟',
      'or_continue_as': 'أو المتابعة كـ',
      'continue_as_guest': 'المتابعة كضيف',
      'no_account': 'ليس لديك حساب؟ ',
      'create_one': 'إنشاء حساب',
      'welcome_guest': 'مرحباً، ضيف!',
      'welcome_user': 'مرحباً، {name}!',
      'scan_explore_earn': 'امسح، استكشف، اربح',
      'mobile': 'الجوال',
      'edit_account': 'تعديل الحساب',
      'tutorial': 'درس تعليمي',
      'skip':'تخطي',
      'next':'التالي',
      'finish':'إنتهاء',
      'feedback': 'ملاحظات',
      'feedback_title': 'الملاحظات',
      'feedback_prompt': 'شارك اقتراحاتك لتحسين التجربة.',
      'feedback_label': 'ملاحظاتك',
      'feedback_empty_error': 'لا يمكن ترك الملاحظات فارغة',
      'feedback_submitting': 'جاري الإرسال...',
      'feedback_submit': 'إرسال',
      'feedback_submitted': 'تم إرسال ملاحظاتك. شكراً لك!',
      'feedback_submit_failed': 'تعذر إرسال الملاحظات حالياً.',
      'feedback_rating_label': 'تقييمك',
      'feedback_rating_required': 'يرجى النقر على النجوم لتقييم التجربة.',
      'logout': 'تسجيل الخروج',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'full_name': 'الاسم الكامل',
      'mobile_number': 'رقم الجوال',
      'profile_updated_success': 'تم تحديث الملف الشخصي بنجاح',
      'change_password': 'تغيير كلمة المرور',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_new_password': 'تأكيد كلمة المرور الجديدة',
      'password_changed_success': 'تم تغيير كلمة المرور بنجاح',
      'change_password_error': 'حدث خطأ أثناء تغيير كلمة المرور: {error}',
      'password_requirements_min6':'يجب ألا تقل كلمة المرور عن 8 أحرف',
      'password_requirements_letter':
          'يجب أن تحتوي كلمة المرور على حرف واحد على الأقل',
      'password_requirements_number':
          'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل',
      'passwords_do_not_match': 'كلمتا المرور غير متطابقتين',
      'enter_current_password': 'يرجى إدخال كلمة المرور الحالية',
      'enter_new_password': 'يرجى إدخال كلمة المرور الجديدة',
      'confirm_new_password_prompt': 'يرجى تأكيد كلمة المرور الجديدة',
      'achievements_points_suffix': 'نقطة',
      'achievements_refresh': 'تحديث',
      'quiz_completed_notification_title': 'تم إنهاء الاختبار!',
      'quiz_completed_notification_message':
          'لقد حصلت على {score} من {total}. {suffix}',
      'quiz_completed_suffix_perfect': 'نتيجة كاملة!',
      'quiz_completed_suffix_great': 'عمل رائع!',
      'achievement_unlocked_first_quiz_title':
          '🎯 تم فتح إنجاز: أول اختبار!',
      'achievement_unlocked_first_quiz_message':
          'لقد أكملت أول اختبار لك! استمر في الاستكشاف لفتح المزيد من الإنجازات.',
      'achievement_unlocked_perfect_score_title':
          '🏆 تم فتح إنجاز: نتيجة كاملة!',
      'achievement_unlocked_perfect_score_message':
          'مذهل! لقد حصلت على العلامة الكاملة في الاختبار!',
      'achievement_unlocked_quiz_master_title':
          '📚 تم فتح إنجاز: خبير الاختبارات!',
      'achievement_unlocked_quiz_master_message':
          'تهانينا! لقد أكملت 3 اختبارات. أنت تصبح خبيراً في الاختبارات!',
      'achievement_unlocked_flawless_victory_title':
          '⭐ تم فتح إنجاز: انتصار مثالي!',
      'achievement_unlocked_flawless_victory_message':
          'رائع! لقد حققت نتيجة كاملة في اختبار من 3 أسئلة فأكثر!',
      'achievement_unlocked_first_scan_title':
          '📷 تم فتح إنجاز: أول مسح!',
      'achievement_unlocked_first_scan_message':
          'لقد فتحت أول موقع تراثي من رمز QR. واصل المسح!',
      'achievement_unlocked_keen_scanner_title':
          '🧭 تم فتح إنجاز: مساح نشيط!',
      'achievement_unlocked_keen_scanner_message':
          'لقد فتحت 5 مواقع تراثية بالمسح. استكشاف رائع!',
      // Achievements details (titles/descriptions)
      'achievement_1_title': 'أول اختبار',
      'achievement_1_desc': 'أكمل أول اختبار لك',
      'achievement_2_title': 'نتيجة كاملة',
      'achievement_2_desc': 'احصل على العلامة الكاملة في اختبار',
      'achievement_3_title': 'خبير الاختبارات',
      'achievement_3_desc': 'أكمل 3 اختبارات',
      'achievement_4_title': 'خبير التاريخ',
      'achievement_4_desc': 'أكمل 5 اختبارات',
      'achievement_5_title': 'انتصار مثالي',
      'achievement_5_desc': 'نتيجة كاملة في اختبار من 3 أسئلة فأكثر',
      'achievement_6_title': 'متعلم ملتزم',
      'achievement_6_desc': 'أكمل 10 اختبارات',
      'achievement_7_title': 'سريع الإنجاز',
      'achievement_7_desc': 'أكمل اختبارين في نفس اليوم',
      'achievement_8_title': 'باحث في التراث',
      'achievement_8_desc': 'أكمل 15 اختباراً',
      'achievement_9_title': 'سلسلة كاملة',
      'achievement_9_desc': 'حقق نتيجتين كاملتين (في أي وقت)',
      'achievement_10_title': 'مستكشف محترف',
      'achievement_10_desc': 'أكمل 25 اختباراً',
      'achievement_11_title': 'مفكر سريع',
      'achievement_11_desc': 'أكمل 8 اختبارات إجمالاً',
      'achievement_12_title': 'أداء ثابت',
      'achievement_12_desc': 'أكمل 3 اختبارات خلال 7 أيام',
      'achievement_13_title': 'أول مسح',
      'achievement_13_desc': 'امسح رمز QR وافتح موقعاً تراثياً',
      'achievement_14_title': 'مساح نشيط',
      'achievement_14_desc': 'امسح 5 رموز QR تراثية',
      'quiz_save_error': 'حدث خطأ أثناء حفظ نتيجة الاختبار: {error}',
      // Home
      'home_tab_home': 'الرئيسية',
      'home_tab_scan': 'مسح',
      'home_tab_profile': 'الملف الشخصي',
      'home_leaderboard_stats': 'الإحصائيات',
      'home_points': 'النقاط',
      'home_earn_points': 'اكسب النقاط!',
      'home_rank': 'الترتيب',
      'home_start_playing': 'ابدأ اللعب!',
      'home_quiz_title': 'اختبار قلعة نزوى',
      'home_quiz_subtitle': 'اختبر معرفتك حول قلعة نزوى',
      'home_map_title': 'الخريطة',
      'home_map_subtitle': 'تتبع موقعك',
      'home_leaderboard_title': 'لوحة الصدارة',
      'home_leaderboard_subtitle': 'تابع تقدمك وتنافس مع الآخرين',
      'home_achievements_title': 'الإنجازات',
      'home_achievements_subtitle': 'افتح الشارات واربح المكافآت',
      'home_stats_hint':
          'استمر في لعب الاختبارات لفتح مزيد من الإنجازات وتحسين ترتيبك!',
      'notifications_title': 'الإشعارات',
      'notifications_login_required': 'يتطلب تسجيل الدخول',
      'notifications_login_message':
          'يجب تسجيل الدخول لعرض الإشعارات!',
      'notifications_mark_all_read': 'تحديد الكل كمقروء',
      'notifications_empty_title': 'لا توجد إشعارات',
      'notifications_empty_message':
          'ستظهر هنا إشعارات الإنجازات والاختبارات!',
      'notifications_deleted': 'تم حذف الإشعار',
      'time_just_now': 'الآن',
      'time_minutes_ago': 'قبل {value} دقيقة',
      'time_hours_ago': 'قبل {value} ساعة',
      'time_yesterday': 'أمس',
      'time_days_ago': 'قبل {value} يوم',
      'achievements_title': 'الإنجازات',
      'achievements_login_required_message':
          'يجب تسجيل الدخول للوصول إلى صفحة الإنجازات.',
      'achievements_your_achievements': 'إنجازاتك',
      'achievements_header_message':
          'أكمل الاختبارات وامسح رموز QR التراثية لفتح الشارات وكسب النقاط!',
      'achievements_unlocked': 'تم فتحها',
      'achievements_total_points': 'إجمالي النقاط',
      'achievements_start_playing': 'ابدأ اللعب!',
      'achievements_earn_points': 'اكسب النقاط!',
      'leaderboard_title': 'لوحة الصدارة',
      'leaderboard_search_hint': 'ابحث عن لاعب...',
      'leaderboard_error_title': 'حدث خطأ أثناء تحميل لوحة الصدارة',
      'leaderboard_retry': 'إعادة المحاولة',
      'leaderboard_empty_title': 'لا يوجد لاعبون في لوحة الصدارة بعد',
      'leaderboard_empty_message':
          'أكمل الاختبارات لكسب النقاط والظهور هنا!',
      'leaderboard_points_label': '{value} نقطة',
      'quiz_title': 'اختبار قلعة نزوى',
      'quiz_login_required_message':
          'يجب تسجيل الدخول للوصول إلى صفحة الاختبار.',
      'quiz_login_button': 'تسجيل الدخول',
      'quiz_next_question': 'السؤال التالي',
      'quiz_finish_quiz': 'إنهاء الاختبار',
      'quiz_explanation': 'التفسير:',
      'quiz_try_again': 'حاول مرة أخرى',
      'quiz_back_home': 'العودة إلى الرئيسية',
      'quiz_score_label': 'النتيجة: {value}',
      'quiz_completed_title': 'تم إنهاء الاختبار!',
      'quiz_score_message_excellent':
          'رائع! أنت خبير في قلعة نزوى! 🏆',
      'quiz_score_message_very_good':
          'جيد جداً! لديك معرفة جيدة بقلعة نزوى! 👍',
      'quiz_score_message_ok':
          'ليس سيئاً! تعرّف أكثر على قلعة نزوى! 📚',
      'quiz_score_message_try_again':
          'حاول مرة أخرى! اكتشف المزيد عن تراث عُمان! 🏰',
      // Register / create account
      'register_title': 'إنشاء حساب',
      'register_subtitle': 'انضم إلى رحلة استكشاف التراث',
      'register_username_label': 'اسم المستخدم / الاسم المعروض',
      'register_username_required': 'يرجى إدخال اسم المستخدم',
      'register_username_min':
          'يجب أن يكون اسم المستخدم 3 أحرف على الأقل',
      'register_mobile_label': 'رقم الجوال',
      'register_mobile_required': 'لا يمكن أن يكون رقم الجوال فارغاً.',
      'register_mobile_digits':
          'يجب أن يحتوي رقم الجوال على أرقام فقط.',
      'register_mobile_length':
          'يجب أن يكون رقم الجوال 8 أرقام بالضبط',
      'register_email_label': 'البريد الإلكتروني',
      'register_email_required': 'لا يمكن أن يكون البريد الإلكتروني فارغاً.',
      'register_email_invalid':
          'يرجى إدخال بريد إلكتروني صحيح مثل example@gmail.com',
      'register_visitor_type': 'نوع الزائر',
      'register_visitor_local': 'زائر محلي',
      'register_visitor_foreign': 'زائر أجنبي',
      'register_password_label': 'كلمة المرور',
      'register_password_required': 'لا يمكن أن تكون كلمة المرور فارغة.',
      'register_password_min':
          'يجب أن تكون كلمة المرور 8 أحرف على الأقل.',
      'register_password_pattern':
          'يجب أن تحتوي كلمة المرور على حروف وأرقام.',
      'register_confirm_password_label': 'تأكيد كلمة المرور',
      'register_confirm_password_required': 'لا يمكن أن يكون الحقل فارغاً',
      'register_confirm_password_mismatch':
          'كلمتا المرور غير متطابقتين',
      'register_button_creating': 'جاري إنشاء الحساب...',
      'register_button_create': 'إنشاء حساب',
      'register_have_account': 'لديك حساب بالفعل؟ ',
      'register_login': 'تسجيل الدخول',
      'register_generic_error':
          'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
      // Map / QR
      'map_title': 'الخريطة',
      'map_find_location_button': 'اعثر على موقعك الحالي',
      'map_image_not_found': 'لم يتم العثور على الصورة: fullMap.png',
      'qr_title': 'قارئ QR',
      'qr_scan_again': 'امسح مرة أخرى',
      'qr_location_title': 'موقعك',
      'qr_location_image_not_found': 'لم يتم العثور على صورة الموقع',
      'qr_no_location_image': 'لا توجد صورة للموقع',
      // Admin
      'admin_title': '{app} - الإدارة',
      'admin_welcome': 'مرحباً، {name}',
      'admin_subtitle': 'حافظ على تفاعل مجتمع التراث',
      'admin_manage_users': 'إدارة المستخدمين',
      'admin_manage_users_subtitle':
          'عرض جميع المستخدمين؛ المشرف الأعلى فقط يمكنه تعطيل الحسابات وتغيير الأدوار',
      'admin_check_feedback': 'عرض الملاحظات',
      'admin_check_feedback_subtitle': 'مراجعة اقتراحات الزوار',
      'admin_check_leaderboard': 'عرض لوحة الصدارة',
      'admin_check_leaderboard_subtitle': 'مراقبة أداء الاختبارات',
      'admin_feedback_title': 'الملاحظات',
      'admin_feedback_error_title': 'حدث خطأ أثناء تحميل الملاحظات',
      'admin_feedback_empty_title': 'لا توجد ملاحظات بعد',
      'admin_feedback_empty_message': 'ستظهر هنا ملاحظات الزوار',
      'admin_feedback_anonymous': 'مجهول',
      'admin_feedback_guest_badge': 'ضيف',
      'admin_feedback_no_rating': 'لا يوجد تقييم بالنجوم (إدخال قديم)',
      'admin_users_title': 'إدارة المستخدمين',
      'admin_users_error_title': 'حدث خطأ أثناء تحميل المستخدمين',
      'admin_retry': 'إعادة المحاولة',
      'admin_no_users': 'لا يوجد مستخدمون.',
      'admin_contact': 'التواصل',
      'admin_admin': 'مشرف',
      'admin_role': 'الدور',
      'admin_role_user': 'مستخدم',
      'admin_role_admin': 'مشرف',
      'admin_role_super_admin': 'مشرف أعلى',
      'yes': 'نعم',
      'no': 'لا',
      'admin_make_admin_q': 'تعيين كمشرف؟',
      'admin_remove_admin_q': 'إزالة الإشراف؟',
      'admin_make_admin_msg': 'هل تريد تعيين {name} كمشرف؟',
      'admin_remove_admin_msg': 'هل تريد إزالة صلاحيات الإشراف من {name}؟',
      'admin_make_admin_btn': 'تعيين كمشرف',
      'admin_remove_admin_btn': 'إزالة الإشراف',
      'admin_disable_user_q': 'تعطيل الحساب؟',
      'admin_disable_user_msg':
          'لن يتمكن {name} من تسجيل الدخول حتى يتم تفعيل الحساب مرة أخرى.',
      'admin_enable_user_q': 'تفعيل الحساب؟',
      'admin_enable_user_msg': 'السماح لـ {name} بتسجيل الدخول مرة أخرى؟',
      'admin_disable': 'تعطيل',
      'admin_enable': 'تفعيل',
      'admin_user_disabled': 'تم تعطيل حساب {name}',
      'admin_user_enabled': 'تم تفعيل حساب {name}',
      'admin_status_disabled': 'الحساب معطّل (لا يمكنه تسجيل الدخول)',
      'admin_now_admin': 'تم تعيين {name} كمشرف',
      'admin_admin_removed': 'تمت إزالة صلاحيات الإشراف من {name}',
      'admin_update_user_error': 'حدث خطأ أثناء تحديث المستخدم: {error}',
      // Admin analytics (charts)
      'admin_analytics_title': 'التحليلات',
      'admin_analytics_subtitle': 'مخططات للمستخدمين والاختبارات',
      'admin_analytics_error': 'حدث خطأ أثناء تحميل التحليلات',
      'admin_analytics_empty_users': 'لا يوجد مستخدمون لتحليلهم.',
      'admin_analytics_empty_quiz': 'لا توجد نتائج اختبارات بعد.',
      'admin_analytics_users_section': 'المستخدمون',
      'admin_analytics_total_users': 'إجمالي المستخدمين',
      'admin_analytics_local': 'محلي',
      'admin_analytics_foreign': 'أجنبي',
      'admin_analytics_visitor_split': 'توزيع نوع الزائر',
      'admin_analytics_quiz_section': 'نشاط الاختبارات',
      'admin_analytics_attempts': 'المحاولات',
      'admin_analytics_avg_score': 'متوسط النتيجة',
      'admin_analytics_perfect_scores': 'نتائج كاملة',
      'admin_analytics_quiz_overview_chart': 'ملخص الاختبار (مخطط)',
      'admin_analytics_accuracy_detail': '{correct} إجابة صحيحة من {total}',
      'admin_analytics_top_users': 'أفضل المستخدمين (حسب المحاولات)',
      'admin_analytics_attempts_label': '{value} محاولة',
      'admin_analytics_feedback_section': 'الملاحظات والتقييم',
      'admin_analytics_feedback_total': 'عدد الملاحظات',
      'admin_analytics_feedback_avg_rating': 'متوسط التقييم (الكل)',
      'admin_analytics_feedback_guest_pct': 'نسبة الضيوف',
      'admin_analytics_feedback_user_pct': 'نسبة المسجّلين',
      'admin_analytics_feedback_avg_guest': 'متوسط تقييم الضيوف',
      'admin_analytics_feedback_avg_user': 'متوسط تقييم الأعضاء',
      'admin_analytics_feedback_empty': 'لا توجد ملاحظات بعد.',
      'admin_analytics_feedback_source_split': 'الملاحظات حسب الحساب',
      'admin_analytics_feedback_guest_legend': 'ضيف',
      'admin_analytics_feedback_user_legend': 'مسجّل',
      // Forgot password
      'forgot_password_title': 'هل نسيت كلمة المرور؟',
      'forgot_password_step_email': 'البريد',
      'forgot_password_step_otp': 'رمز التحقق',
      'forgot_password_step_password': 'كلمة المرور',
      'forgot_password_hint_email':
          'أدخل بريدك الإلكتروني لاستلام رمز تحقق (OTP).',
      'forgot_password_hint_otp':
          'أدخل رمز التحقق المكوّن من 4 أرقام المرسل إلى بريدك.',
      'forgot_password_hint_password': 'أدخل كلمة المرور الجديدة.',
      'forgot_password_send_otp': 'إرسال رمز التحقق',
      'forgot_password_sending_otp': 'جاري إرسال رمز التحقق...',
      'forgot_password_otp_sent':
          'تم إرسال رمز التحقق. يرجى التحقق من صندوق الوارد.',
      'forgot_password_otp_sent_to': 'تم إرسال الرمز إلى: {email}',
      'forgot_password_enter_otp': 'أدخل رمز التحقق',
      'forgot_password_change_email': 'تغيير البريد',
      'forgot_password_resend_otp': 'إعادة إرسال الرمز',
      'forgot_password_verify_otp': 'تأكيد الرمز',
      'forgot_password_verifying': 'جاري التحقق...',
      'forgot_password_otp_verified':
          'تم التحقق من الرمز بنجاح! يرجى إدخال كلمة المرور الجديدة.',
      'forgot_password_reset_password': 'إعادة تعيين كلمة المرور',
      'forgot_password_resetting': 'جاري إعادة التعيين...',
      'forgot_password_back_to_login': 'العودة لتسجيل الدخول',
      'forgot_password_email_not_found':
          'لم يتم العثور على البريد. يرجى العودة وإدخال بريدك مرة أخرى.',
      'forgot_password_failed_verify_email':
          'فشل التحقق من البريد. يرجى المحاولة مرة أخرى.',
      'forgot_password_failed_generate_otp':
          'فشل إنشاء رمز التحقق. يرجى المحاولة مرة أخرى.',
      'forgot_password_failed_send_otp':
          'فشل إرسال رمز التحقق عبر البريد. يرجى المحاولة مرة أخرى.',
      'forgot_password_failed_resend_otp':
          'فشل إعادة إرسال الرمز. يرجى المحاولة مرة أخرى.',
      'forgot_password_enter_otp_error': 'يرجى إدخال رمز التحقق',
      'forgot_password_otp_4_digits': 'يجب أن يكون الرمز 4 أرقام',
      'forgot_password_otp_numbers_only': 'يجب أن يحتوي الرمز على أرقام فقط',
      'forgot_password_timeout':
          'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى.',
      'forgot_password_permission_error':
          'خطأ في صلاحيات قاعدة البيانات. يرجى التواصل مع الدعم.',
      'forgot_password_cannot_connect_db':
          'لا يمكن الاتصال بقاعدة البيانات. تحقق من الإنترنت وحاول مرة أخرى.',
      'forgot_password_failed_verify_otp':
          'فشل التحقق من الرمز. تأكد من الكود وحاول مرة أخرى.',
      'forgot_password_failed_verify_otp_with_error':
          'فشل التحقق من الرمز: {error}',
      'forgot_password_session_expired':
          'انتهت الجلسة. يرجى بدء عملية إعادة التعيين من جديد.',
      'forgot_password_reset_success':
          'تمت إعادة تعيين كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.',
      'forgot_password_failed_reset':
          'فشل إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى.',
      'video_player':'مشغل الفيديو',
      'audio_player':'مشغل الصوت',
    },
  };

  String t(String key, {Map<String, String>? params}) {
    final values = _localizedValues[languageCode] ?? _localizedValues['en']!;
    String text = values[key] ?? _localizedValues['en']![key] ?? key;

    if (params != null) {
      params.forEach((paramKey, value) {
        text = text.replaceAll('{$paramKey}', value);
      });
    }

    return text;
  }

  TextDirection get textDirection =>
      languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}

