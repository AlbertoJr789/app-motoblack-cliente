class Address {
  double? latitude;
  double? longitude;
  String street;
  String number;
  String neighborhood;
  String? complement;
  String? country;
  String? state;
  String? city;

  Address(
      {this.latitude,
      this.longitude,
      required this.street,
      required this.number,
      required this.neighborhood,
      this.complement,
      this.country,
      this.state,
      this.city});

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
        street: map['street'],
        number: map['number'],
        neighborhood: map['neighborhood'],
        complement: map['complement'],
        country: map['country'],
        state: map['state'],
        city: map['city']);
  }
}
