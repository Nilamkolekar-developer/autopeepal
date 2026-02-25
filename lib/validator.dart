String? commonValidator(String value) {
  if (value.isEmpty) {
    return 'This field is required';
  }

  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? commonValidatornootrequired(String value) {
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  if (value.isNotEmpty && !emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }

  return null;
}

String? requiredValidator(String value) {
  if (value.isEmpty) {
    return 'This field is required';
  }

  return null;
}

String? requiredValidatorPostCode(String value) {
  if (value.isEmpty) {
    return 'This field is required';
  }
  // else if (value.replaceAll(' ', '').length != 6) {
  //     return 'Post code must be exactly 6 digits';
  //   }

  return null;
}

String? monthYearValidator(String value) {
  if (value.isEmpty) {
    return 'This field is required';
  }

  String monthString = value.split('/')[0];

  int month;
  try {
    month = int.parse(monthString);
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
  } catch (e) {
    return 'Invalid month';
  }

  return null;
}

String? requiredValidatorforCityDropdown(dynamic value) {
  if (value == null) {
    return 'This field is required';
  }

  return null;
}

String? mobileNoValidator(String value) {
  if (value.isEmpty) {
    return 'This field is required';
  }

  RegExp regex = RegExp(r'^[6-9]\d{9}$');
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid mobile number';
  }
  return null;
}

String? passwordValidator(String value) {
  if (value.isEmpty) {
    return 'Please enter your password.';
  }
  if (value.length < 8) {
    return 'Password must be – minimum 8 & maximum 15 characters long, with at least 1 uppercase alphabet, 1 number and 1 special character (!, @, #,  %, ^, &, *, -, _)';
  }
  if (!value.contains(new RegExp(r'[A-Z]'))) {
    return 'Password must be – minimum 8 & maximum 15 characters long, with at least 1 uppercase alphabet, 1 number and 1 special character (!, @, #,  %, ^, &, *, -, _)';
  }
  if (!value.contains(new RegExp(r'[0-9]'))) {
    return 'Password must be – minimum 8 & maximum 15 characters long, with at least 1 uppercase alphabet, 1 number and 1 special character (!, @, #,  %, ^, &, *, -, _)';
  }
  if (!value.contains(new RegExp(r'[!@#\$%^&*-_]'))) {
    return 'Password must be – minimum 8 & maximum 15 characters long, with at least 1 uppercase alphabet, 1 number and 1 special character (!, @, #,  %, ^, &, *, -, _)';
  }

  return null;
}

String? confirmPasswordValidator(String? value, String originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Confirm password is required';
  }
  if (value != originalPassword) {
    return 'Passwords do not match';
  }
  return null;
}

String? aadharValidator(String value) {
  if (value.isEmpty) return 'This field is required';
  final regex = RegExp(r'^\d{12}$');
  if (!regex.hasMatch(value))
    return 'Please enter a valid 12-digit Aadhar number';
  return null;
}

/// PAN Number Validator (5 letters + 4 digits + 1 letter)
String? panValidator(String value) {
  if (value.isEmpty) return 'This field is required';
  final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
  if (!regex.hasMatch(value.toUpperCase()))
    return 'Please enter a valid PAN number';
  return null;
}

/// Voter ID Validator (3 letters + 7 digits, common format)
String? voterIdValidator(String value) {
  if (value.isEmpty) return 'This field is required';
  final regex = RegExp(r'^[A-Z]{3}[0-9]{7}$'); // 3 letters + 7 digits
  if (!regex.hasMatch(value)) return 'Please enter a valid Voter ID';
  return null;
}

String? pincodeValidator(String value) {
  if (value.isEmpty) return 'This field is required';
  final regex = RegExp(r'^\d{6}$'); 
  if (!regex.hasMatch(value)) return 'Please enter a valid 6-digit pincode';
  return null;
}


