bool isValidEmail(String email) {
  return RegExp(
    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
  ).hasMatch(email);
}

String? validatePassword(String value) {
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Must include an uppercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Must include a number';
  }
  return null;
}
