class FormValidators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username can\'t be empty';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    /*if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Full name cannot be just numbers';
    }*/
    return null;
  }

  static String? validateContactNumber(String? value) {
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
  }

  static String? validateEmail(String? value) {
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
  }

  static String? validatePassword(String? value) {
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
  }

  static String? validateEmailLogin(String? value) {
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
  }

  static String? validatePasswordLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';

    }

    return null;
  }


  static String? validateEmailOTP(String? value) {
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
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 4) {
      return 'OTP must be 4 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  static String? validatePasswordOTP(String? value,String? value2) {
    if (value == null || value.isEmpty || value2 == null || value2.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';

    }
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetters || !hasNumbers) {
      return 'Password must contain letters and numbers.';
    }
    if (value != value2){
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateUsernameProfile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';

    }

    return null;
  }

  static String? validateProfileContactNumber(String? value) {
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
  }

  static String? validateProfilePassword(String? value,String? value2,String? value3) {
    if (value == null || value.isEmpty || value2 == null || value2.isEmpty || value3 == null || value3.isEmpty) {
      return 'fields cannot be empty.';
    }
    if (value2.length < 8) {
      return 'Password must be at least 8 characters.';

    }
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value2);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(value2);
    if (!hasLetters || !hasNumbers) {
      return 'Password must contain letters and numbers.';
    }
    if (value2 != value3){
      return 'Passwords do not match';
    }

    return null;
  }



  /*
  static String? validateServiceRequest(
    bool normalService,
    bool majorService,
    bool repair,
    bool others,
  ) {
    if (!normalService && !majorService && !repair && !others) {
      return 'Please select at least one service';
    }
    return null;
  }

   */
}
