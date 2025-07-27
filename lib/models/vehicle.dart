class Vehicle {
  final int? id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String? vin;
  final int? mileage;
  final double? price;
  final String status;
  final List<String> mediaFiles;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vin,
    this.mileage,
    this.price,
    required this.status,
    required this.mediaFiles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      licensePlate: map['license_plate'] as String,
      vin: map['vin'] as String?,
      mileage: map['mileage'] as int?,
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      status: map['status'] as String,
      mediaFiles: map['media_files'] != null 
          ? (map['media_files'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : <String>[],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'vin': vin,
      'mileage': mileage,
      'price': price,
      'status': status,
      'media_files': mediaFiles.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Vehicle copyWith({
    int? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? vin,
    int? mileage,
    double? price,
    String? status,
    List<String>? mediaFiles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      price: price ?? this.price,
      status: status ?? this.status,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => '$year $make $model';
  
  bool get hasMedia => mediaFiles.isNotEmpty;
  
  String get primaryImage => mediaFiles.isNotEmpty ? mediaFiles.first : '';
  
  List<String> get imageFiles => mediaFiles.where((file) => 
    file.toLowerCase().endsWith('.jpg') ||
    file.toLowerCase().endsWith('.jpeg') ||
    file.toLowerCase().endsWith('.png') ||
    file.toLowerCase().endsWith('.gif')
  ).toList();
  
  List<String> get videoFiles => mediaFiles.where((file) => 
    file.toLowerCase().endsWith('.mp4') ||
    file.toLowerCase().endsWith('.mov') ||
    file.toLowerCase().endsWith('.avi') ||
    file.toLowerCase().endsWith('.mkv')
  ).toList();
}