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

  });
}
