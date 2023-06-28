import 'package:flutter/foundation.dart';

import 'package:kookbook_app/utils/dummyData.dart';

class IngredientModel extends ChangeNotifier {
  List<IngredientItem> ingredientList = defaultIngredientList;
  List<int> ingredientIDList = defaultIngredientIDList;

  List<IngredientItem> get items => ingredientIDList.map((id) => getByID(id)).toList();

  IngredientItem getByID (int ingredientID) {
    return ingredientList[ingredientID];
  }

  int add () {
    int newID = ingredientList.length;
    IngredientItem newItem = IngredientItem(newID, 'New Ingredient', 'Unassigned', 0, false);
    ingredientList.add(newItem);
    ingredientIDList.add(newID);
    notifyListeners();
    return newID;
  }

  void update (int ingredientID, String name, String type, double quantity, bool have) {
    IngredientItem item = ingredientList[ingredientID];
    item.name = name;
    item.type = type;
    item.have = have;
    item.quantity = quantity;
    notifyListeners();
  }

  void remove (int ingredientID) {
    ingredientIDList.remove(ingredientID);
    notifyListeners();
  }

  List<String> getAllTypes () {
    List<String> types = [];
    for (var id in ingredientIDList) {
      IngredientItem item = getByID(id);
      String type = item.type;
      if (!types.contains(type)) {
        types.add(type);
      }
    }
    return types;
  }

  bool haveAll (List<int> ingList) {
    for (var id in ingList) {
      if (!ingredientIDList.contains(id) || !getByID(id).have) {
        return false;
      }
    }
    return true;
  }
}

class IngredientItem {
  int ingredientID;
  String name;
  bool have;
  double quantity;
  String type;

  IngredientItem(this.ingredientID, this.name, this.type, this.quantity, this.have);

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) => other is IngredientItem && other.name == name;
}