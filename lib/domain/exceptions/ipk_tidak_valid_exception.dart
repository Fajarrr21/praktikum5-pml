class IpkTidakValidException implements Exception {
  final String message;

  IpkTidakValidException([
    this.message = 'IPK harus di antara 0.0 sampai 4.0',
  ]);

  @override
  String toString() => message;
}
