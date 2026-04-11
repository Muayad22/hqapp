import 'package:flutter_test/flutter_test.dart';
import 'package:hqapp/validators.dart';

void main() {
  group('FormValidators', () {
    // --- Username Validation Tests ---
    group('validateUsername', () {
      test('should return error if Username is empty', () {
        expect(FormValidators.validateUsername(''),'Username can\'t be empty',);
      });

      test('should return error if Username is null', () {
        expect(FormValidators.validateUsername(null), 'Username can\'t be empty',);
      });

      test('should return error if Username is less than 3 characters long', () {
        expect(FormValidators.validateUsername('12'), 'Username must be at least 3 characters',);
      });

      test('should return null if Username is valid', () {
        expect(FormValidators.validateUsername('Ahmed'), null);
      });
    });

    // --- Contact Number Validation Tests ---
    group('validateContactNumber', () {
      test('should return error if contact number is empty', () {
        expect(FormValidators.validateContactNumber(''), 'Mobile number cannot be empty.',);
      });

      test('should return error if contact number is null', () {
        expect(FormValidators.validateContactNumber(null), 'Mobile number cannot be empty.',);
      });

      test('should return error if contact number has something other than number', () {
        expect(FormValidators.validateContactNumber('asd#'), 'Mobile number must contain only numbers.',);
      });

      test('should return error if contact number is less than 8 digits', () {
        expect(FormValidators.validateContactNumber('1234567'), 'Mobile number must be exactly 8 digits',);
      });

      test('should return null if contact number is 8 digits', () {
        expect(FormValidators.validateContactNumber('12345678'), null);
      });
    });

    // --- Email Validation Tests ---
    group('validateEmail', () {
      test('should return error if Email is empty', () {
        expect(FormValidators.validateEmail(''),'Email cannot be empty.',);
      });

      test('should return error if Email is null', () {
        expect(FormValidators.validateEmail(null), 'Email cannot be empty.',);
      });

      test('should return error if Email is not following the format', () {
        expect(FormValidators.validateEmail('asd'), 'Please enter a valid email like example@gmail.com',);
      });

      test('should return error if Email is not following the format', () {
        expect(FormValidators.validateEmail('123@'), 'Please enter a valid email like example@gmail.com',);
      });

      test('should return null if Email is following the format', () {
        expect(FormValidators.validateEmail('salim@gmail.com'), null,);
      });

    });


    // --- Password Validation Tests ---
    group('validatePassword', () {
      test('should return error if Password is empty', () {
        expect(FormValidators.validatePassword(''),'Password cannot be empty.',);
      });

      test('should return error if Password is null', () {
        expect(FormValidators.validatePassword(null), 'Password cannot be empty.',);
      });

      test('should return error if Password is less than 8 characters long', () {
        expect(FormValidators.validatePassword('asd123'), 'Password must be at least 8 characters.',);
      });

      test('should return error if Password is has only numbers', () {
        expect(FormValidators.validatePassword('12345678'), 'Password must contain letters and numbers.',);
      });

      test('should return error if Password is has only letters', () {
        expect(FormValidators.validatePassword('abcdefgh'), 'Password must contain letters and numbers.',);
      });

    });

    // --- Email Validation Login Tests ---
    group('validateEmailLogin', () {
      test('should return error if Email is empty', () {
        expect(FormValidators.validateEmailLogin(''),'Email cannot be empty.',);
      });

      test('should return error if Email is null', () {
        expect(FormValidators.validateEmailLogin(null), 'Email cannot be empty.',);
      });

      test('should return error if Email is not following the format', () {
        expect(FormValidators.validateEmailLogin('asd'), 'Please enter a valid email like example@gmail.com',);
      });

      test('should return error if Email is not following the format', () {
        expect(FormValidators.validateEmailLogin('123@'), 'Please enter a valid email like example@gmail.com',);
      });

      test('should return null if Email is following the format', () {
        expect(FormValidators.validateEmailLogin('salim@gmail.com'), null,);
      });

    });

    // --- Password Validation Login Tests ---
    group('validatePasswordLogin', () {
      test('should return error if Password is empty', () {
        expect(FormValidators.validatePassword(''),'Password cannot be empty.',);
      });

      test('should return error if Password is null', () {
        expect(FormValidators.validatePassword(null), 'Password cannot be empty.',);
      });

      test('should return error if Password is less than 8 characters long', () {
        expect(FormValidators.validatePassword('asd123'), 'Password must be at least 8 characters.',);
      });
    });

    // --- Email Validation OPT Tests ---
    group('validateEmailOTP', () {
      test('should return error if Email is empty', () {
        expect(FormValidators.validateEmailOTP(''),'Email cannot be empty.',);
      });

      test('should return error if Email is null', () {
        expect(FormValidators.validateEmailOTP(null), 'Email cannot be empty.',);
      });

      test('should return error if Email is not following the format', () {
        expect(FormValidators.validateEmailOTP('asd'), 'Please enter a valid email like example@gmail.com',);
      });

      test('should return error if Email is not following the format', () {
        expect(FormValidators.validateEmailOTP('123@'), 'Please enter a valid email like example@gmail.com',);
      });

      test('should return null if Email is following the format', () {
        expect(FormValidators.validateEmailOTP('salim@gmail.com'), null,);
      });
    });

    // --- OTP Validation Tests ---
    group('validateOTP', () {
      test('should return error if OTP is empty', () {
        expect(FormValidators.validateOTP(''),'Please enter the OTP',);
      });

      test('should return error if OTP is null', () {
        expect(FormValidators.validateOTP(null), 'Please enter the OTP',);
      });

      test('should return error if OTP is less than 4 digit', () {
        expect(FormValidators.validateOTP('12'), 'OTP must be 4 digits',);
      });

      test('should return error if OTP has letter', () {
        expect(FormValidators.validateOTP('abcd'), 'OTP must contain only numbers',);
      });
    });

    // --- OTP Password Validation Tests ---
    group('validatePasswordOTP', () {
      test('should return error if Passwords is empty', () {
        expect(FormValidators.validatePasswordOTP('',''),'Password cannot be empty.',);
      });

      test('should return error if Passwords is null', () {
        expect(FormValidators.validatePasswordOTP(null,null), 'Password cannot be empty.',);
      });

      test('should return error if Passwords is less than 8 characters long', () {
        expect(FormValidators.validatePasswordOTP('asd123','asd123'), 'Password must be at least 8 characters.',);
      });

      test('should return error if Passwords is has only numbers', () {
        expect(FormValidators.validatePasswordOTP('12345678','12345678'), 'Password must contain letters and numbers.',);
      });

      test('should return error if Passwords is has only letters', () {
        expect(FormValidators.validatePasswordOTP('abcdefgh','abcdefgh'), 'Password must contain letters and numbers.',);
      });

      test('should return error if new Password does not match confirm new password', () {
        expect(FormValidators.validatePasswordOTP('abcd1234','abcd'), 'Passwords do not match',);
      });
    });

    // --- Profile Username Validation Tests ---
    group('validateProfileUsername', () {
      test('should return error if Username is empty', () {
        expect(FormValidators.validateUsernameProfile(''),'Please enter your username',);
      });

      test('should return error if Username is null', () {
        expect(FormValidators.validateUsernameProfile(null), 'Please enter your username',);
      });

      test('should return error if Username is less than 3 characters', () {
        expect(FormValidators.validateUsernameProfile('1a'), 'Username must be at least 3 characters',);
      });
    });

    // --- Profile Contact Number Validation Tests ---
    group('validateProfileContactNumber', () {
      test('should return error if contact number is empty', () {
        expect(FormValidators.validateProfileContactNumber(''), 'Mobile number cannot be empty.',);
      });

      test('should return error if contact number is null', () {
        expect(FormValidators.validateProfileContactNumber(null), 'Mobile number cannot be empty.',);
      });

      test('should return error if contact number has something other than number', () {
        expect(FormValidators.validateProfileContactNumber('asd#'), 'Mobile number must contain only numbers.',);
      });

      test('should return error if contact number is less than 8 digits', () {
        expect(FormValidators.validateProfileContactNumber('1234567'), 'Mobile number must be exactly 8 digits',);
      });

      test('should return null if contact number is 8 digits', () {
        expect(FormValidators.validateProfileContactNumber('12345678'), null);
      });
    });

    // --- Profile Password Validation Tests ---
    group('validateProfilePassword', () {
      test('should return error if Passwords is empty', () {
        expect(FormValidators.validateProfilePassword('','',''),'fields cannot be empty.',);
      });

      test('should return error if Passwords is null', () {
        expect(FormValidators.validateProfilePassword(null,null,null), 'fields cannot be empty.',);
      });

      test('should return error if Passwords is less than 8 characters long', () {
        expect(FormValidators.validateProfilePassword('asd123','asd123','asd123'), 'Password must be at least 8 characters.',);
      });

      test('should return error if Passwords is has only numbers', () {
        expect(FormValidators.validateProfilePassword('12345678','12345678','12345678'), 'Password must contain letters and numbers.',);
      });

      test('should return error if Passwords is has only letters', () {
        expect(FormValidators.validateProfilePassword('abcdefgh','abcdefgh','abcdefgh'), 'Password must contain letters and numbers.',);
      });

      test('should return error if new Password does not match confirm new password', () {
        expect(FormValidators.validateProfilePassword('abcd1234','abcd4321','4321abcd'), 'Passwords do not match',);
      });
    });

  });
}
