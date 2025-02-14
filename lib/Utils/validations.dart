// ignore_for_file: file_names, non_constant_identifier_names


String? PasswordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "* ${'Required'}";
  } else if (value.length < 6) {
    return 'Password too short';
  } else if (value.length > 32) {
    return 'Password too long';
  } else {
    return null;
  }
}

String? EmailValidator(String? value) {
  return (value == null || !CheckEmail(value))
      ? 'Please enter a valid email'
      : null;
}

bool CheckEmail(String email) {
  return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
      .hasMatch(email);
}

String? NameValidator(String? value) {
  final trimmed = (value == null) ? '' : value.trim();
  return (trimmed.length < 3) ? 'Name must be more than 3 characters' : null;
}

String? RequiredFieldValidator(String? value) {
  final trimmed = (value == null) ? '' : value.trim();
  return (trimmed.isEmpty) ? 'This field is required' : null;
}