import 'dart:convert';

class Item {
  final String? uuid;
  final String name;
  final String type;
  final double weight;
  final double pricePerGram;
  final double makingCharge;

  Item({
    this.uuid,
    required this.name,
    required this.type,
    required this.weight,
    required this.pricePerGram,
    required this.makingCharge,
  });

  double get basicAmount => weight * pricePerGram;
  double get makingChargeAmount => basicAmount * (makingCharge / 100);
  double get total => basicAmount + makingChargeAmount;

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'type': type,
      'weight': weight,
      'pricePerGram': pricePerGram,
      'makingCharge': makingCharge,
    };
    if (uuid != null && uuid!.isNotEmpty) {
      map['uuid'] = uuid!;
    }
    return map;
  }

  factory Item.fromMap(Map<String, dynamic> map) => Item(
        uuid: map['uuid'],
        name: map['name'] ?? '',
        type: map['type'] ?? '',
        weight: (map['weight'] ?? 0).toDouble(),
        pricePerGram: (map['pricePerGram'] ?? 0).toDouble(),
        makingCharge: (map['makingCharge'] ?? 0).toDouble(),
      );

  String toJson(Item item) => json.encode(toMap());
  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));
}
