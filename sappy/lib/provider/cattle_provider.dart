import 'package:flutter/foundation.dart';

class CattleProvider with ChangeNotifier {
  List<CattleProviderClass>? _cattleList;

  List<CattleProviderClass>? get cattleList => _cattleList;

  void setCattleList(List<CattleProviderClass> newCattleList) {
    _cattleList = newCattleList;
    notifyListeners();
  }

  void printCattleList() {
    if (_cattleList != null)
    {
      for (var cattle in _cattleList!) {
        print(cattle.id);
        print(cattle.weight);
        print(cattle.age);
      }
    }
  }
}


class CattleProviderClass {
  final String id;
  final double weight;
  final int age;
  final String gender;
  final String healthStatus;
  final bool isProductive;
  final bool isConnectedToNFCTag;

  CattleProviderClass({
    required this.id,
    required this.weight,
    required this.age,
    required this.gender,
    required this.healthStatus,
    required this.isProductive,
    required this.isConnectedToNFCTag,
  });

  factory CattleProviderClass.fromJson(Map<String, dynamic> json) {
    return CattleProviderClass(
      id: json['id']?.toString() ?? 'Unknown ID',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0,
      age: int.tryParse(json['age']?.toString() ?? '0') ?? -1,
      gender: json['gender']?.toString() ?? 'Unknown',
      healthStatus: json['healthStatus'].toString(),
      isProductive: json['isProductive'] ?? false,
      isConnectedToNFCTag: json['is_connected_to_nfc_tag'] ?? false,
    );
  }
}
