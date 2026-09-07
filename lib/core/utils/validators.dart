import 'package:form_field_validator/form_field_validator.dart';

class Validators {
  /// Email Validator
  static final email = EmailValidator(errorText: 'Enter a valid email address');

  /// Password Validator
  static final password = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(8, errorText: 'Password must be at least 8 characters'),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])',
        errorText: 'Password must have at least one special character'),
  ]);

  /// Phone Number Validator (Kenyan format)
  static final phone = MultiValidator([
    RequiredValidator(errorText: 'Phone number is required'),
    PatternValidator(r'^\+?[0-9]{10,15}$',
        errorText: 'Enter a valid phone number'),
  ]);

  /// Required Validator with Optional Field Name
  static RequiredValidator requiredWithFieldName(String? fieldName) =>
      RequiredValidator(errorText: '${fieldName ?? 'Field'} is required');

  /// Plain Required Validator
  static final required = RequiredValidator(errorText: 'Field is required');
}
