class Vehicle {
  String plate;
  String model;
  String brand;
  String color;
  String? picture;

  Vehicle(
      {required this.plate,
      required this.model,
      required this.brand,
      required this.color,
      this.picture});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
        plate: map['plate'],
        model: map['model'],
        brand: map['brand'],
        color: map['color']);
  }
}
