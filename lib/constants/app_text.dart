class AppText {
  static const appTitle = 'Heritage Quest';
  static const appSubtitle = 'Discover and explore cultural heritage sites';
  static const email = 'Email';
  static const password = 'Password';
  static const forgotPassword = 'Forgot Password?';
  static const login = 'Login';
  static const orContinueAs = 'or continue as';
  static const continueAsGuest = 'Continue as Guest';
  static const dontHaveAccount = "Don't have an account?";
  static const createOne = 'Create one';
  static const backToLogin = 'Back to Login';
  static const welcomeGuest = 'Welcome, Guest Explorer 👋';
  static const welcomeUserTemplate = 'Welcome, {username}';
  static const scanExploreEarn = 'Explore, track, earn points';
  static const scanQRCode = 'Scan QR Code';
  static const scanQRSubtitle = 'Scan a code to unlock story of this location';
  static const yourPointsRank = 'Your Points / Rank';
  static const pointsRankSubtitle = 'View your progress and ranking';
  static const achievements = 'Achievements';
  static const achievementsSubtitle = 'Unlock badges and earn rewards';
  static const home = 'Home';
  static const scan = 'Scan';
  static const profile = 'Profile';
  static const nizwaCastleQuiz = 'Nizwa Castle Quiz';

  static String welcomeUser(String username) {
    return welcomeUserTemplate.replaceAll('{username}', username);
  }
}
