// TODO Implement this library.

String? validateName(String? name) {
  if (name == null || name.isEmpty || name.length < 6 || name.contains(' ')) {
    return 'Name must be at least 6 characters long and without spaces';
  }
  return null;
}

String? validateEmail(String? Email) {
  RegExp emailREgex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
  final isEmailValid = emailREgex.hasMatch(Email ?? '');
  if (!isEmailValid) {
    return 'please Enter a valid Email';
  }
  return null;
}

String? validateConfirmPassword(String? confirmPassword, String? password) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Confirm password is required';
  } else if (confirmPassword != password) {
    return 'Passwords do not match';
  }
  return null; // If the passwords match, return null (no error)
}

String? validatepass(String? pass) {
  if (pass == null || pass.isEmpty || pass.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? validateDOB(String? dob) {
  if (dob == null || dob.isEmpty) {
    return 'Date of birth is required';
  }

  DateTime? date;
  try {
    date = DateTime.parse(dob);
  } catch (e) {
    return 'Invalid date format. Use YYYY-MM-DD';
  }

  if (date == null) {
    return 'Invalid date';
  }

  DateTime today = DateTime.now();
  DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);

  if (date.isAfter(eighteenYearsAgo)) {
    return 'You must be at least 18 years old';
  }

  return null; 
}

String? validateMobileNumber(String? number) {
  RegExp mobileRegex = RegExp(r'^\+?1?\d{9,15}$');
  if (number == null || number.isEmpty || !mobileRegex.hasMatch(number)) {
    return 'Please enter a valid mobile number';
  }
  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty || password.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}
