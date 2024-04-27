
enum VehicleType { motorcycle, car, unknown }

VehicleType _vehicleTypeToEnum(int type) {
  switch (type) {
    case 1:
      return VehicleType.motorcycle;
    case 2:
      return VehicleType.car;
    default:
      return VehicleType.unknown;
  }
}

class Vehicle {
  VehicleType type;
  String plate;
  String model;
  String brand;
  String color;
  String? picture;

  Vehicle(
      {required this.type,
      required this.plate,
      required this.model,
      required this.brand,
      required this.color,
      this.picture});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
        type: _vehicleTypeToEnum(map['type']['tipo']),
        plate: map['plate'],
        model: map['model'],
        brand: map['brand'],
        color: map['color']);
  }
}
