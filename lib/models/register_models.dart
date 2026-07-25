class RegistrationResult {
  final String idUser;
  final String idAnak;

  RegistrationResult({required this.idUser, required this.idAnak});
}

class RegisterException implements Exception {
  final String message;
  RegisterException(this.message);

  @override
  String toString() => message;
}
