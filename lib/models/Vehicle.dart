
import 'package:flutter/material.dart';

enum VehicleType { motorcycle, car, unknown }

VehicleType _vehicleTypeToEnum(type) {
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

  factory Vehicle.fromJson(Map<String, dynamic> map) {
    return Vehicle(
        type: _vehicleTypeToEnum(map['type']),
        plate: map['plate'],
        model: map['model'],
        brand: map['brand'],
        color: map['color']);
  }

  String get typeName {
    switch(type){
      case VehicleType.motorcycle: return 'Moto';
      case VehicleType.car: return 'Carro';
      default: return '';
    }
  }

  IconData get icon {
    switch(type){
      case VehicleType.motorcycle: return Icons.motorcycle;
      case VehicleType.car: return Icons.car_crash;
      default: return Icons.question_mark;
    }
  }



}
