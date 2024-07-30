class Address {
  double? latitude;
  double? longitude;
  String? zipCode;
  String? street;
  String? number;
  String? neighborhood;
  String? complement;
  String? country;
  String? state;
  String? city;

  Address(
      {this.latitude,
      this.longitude,
      this.street,
      this.zipCode,
      this.number,
      this.neighborhood,
      this.complement,
      this.country,
      this.state,
      this.city});

  factory Address.fromJson(Map<String, dynamic> map) {
    return Address(
        latitude: double.parse(map['latitude']),
        longitude: double.parse(map['longitude']),
        zipCode: map['zipCode'],
        street: map['street'],
        number: map['number'],
        neighborhood: map['neighborhood'],
        complement: map['complement'],
        country: map['country'],
        state: map['state'],
        city: map['city']);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zipCode'] = zipCode;
    data['street'] = street;
    data['number'] = number;
    data['neighborhood'] = neighborhood;
    data['complement'] = complement;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    return data;
  }

  String get formattedAddress {
    if(number != null){
      return "$street, $Number - $city/$state";
    }else{
      return "$street - $city/$state";
    }
  }
  
  String get Number => number ?? 'S/N';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && formattedAddress == other.formattedAddress;

  @override
  String toString() {
    return formattedAddress;
  }

}
