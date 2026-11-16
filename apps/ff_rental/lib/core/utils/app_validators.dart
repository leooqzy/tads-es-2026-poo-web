import '../constants/app_strings.dart';

class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return AppStrings.emailRequired;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return AppStrings.emailInvalid;
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value.length < 8) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }

    if (value != password) {
      return AppStrings.passwordsDoNotMatch;
    }

    return null;
  }

  static String? validatePhone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (phone.isEmpty) {
      return AppStrings.phoneRequired;
    }

    if (phone.length != 10 && phone.length != 11) {
      return AppStrings.phoneInvalid;
    }

    return null;
  }

  static String? validateCpf(String? value) {
    final cpf = (value ?? '').replaceAll(RegExp(r'\D'), '');

    if (cpf.isEmpty) {
      return AppStrings.cpfRequired;
    }

    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return AppStrings.cpfInvalid;
    }

    for (int position = 9; position < 11; position++) {
      int sum = 0;

      for (int i = 0; i < position; i++) {
        sum += int.parse(cpf[i]) * (position + 1 - i);
      }

      int digit = (sum * 10) % 11;

      if (digit == 10) {
        digit = 0;
      }

      if (int.parse(cpf[position]) != digit) {
        return AppStrings.cpfInvalid;
      }
    }

    return null;
  }
}
