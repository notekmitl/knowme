class AstrologyInputs {
  final String? phoneNumber;
  final String? licensePlate;
  final List<int>? luckyNumbers;

  AstrologyInputs({this.phoneNumber, this.licensePlate, this.luckyNumbers});

  Map<String, dynamic> toMap() {
    return {
      "phoneNumber": phoneNumber,
      "licensePlate": licensePlate,
      "luckyNumbers": luckyNumbers,
    };
  }

  factory AstrologyInputs.fromMap(Map<String, dynamic> map) {
    return AstrologyInputs(
      phoneNumber: map["phoneNumber"],
      licensePlate: map["licensePlate"],
      luckyNumbers: map["luckyNumbers"] != null
          ? List<int>.from(map["luckyNumbers"])
          : null,
    );
  }
}
