import 'package:flutter/foundation.dart';

import 'package:green_flames_cookbook_app/utils/dummyData.dart';

class RecipeItem {
  int recipeID;
  String name;
  String type;
  List<int> requiredIng;
  List<int> optionalIng;
  String instructions;

  RecipeItem(this.recipeID, this.name, this.type, this.requiredIng, this.optionalIng, this.instructions);
}

class RecipeIngredientItem {
  int ingredientID;
  int quantity;

  RecipeIngredientItem(this.ingredientID, this.quantity);
}

class RecipeModel extends ChangeNotifier {
  List<RecipeItem> recipeList = defaultRecipeList;
  List<int> recipeIDList = defaultRecipeIDList;

  List<RecipeItem> get items => recipeIDList.map((id) => getByID(id)).toList();

  RecipeItem getByID (int recipeID) {
    return recipeList[recipeID];
  }

  int add () {
    int newID = recipeList.length;
    RecipeItem newItem = RecipeItem(newID, 'New Recipe', 'Unassigned', [], [], '');
    recipeList.add(newItem);
    recipeIDList.add(newID);
    notifyListeners();
    return newID;
  }

  void update (int recipeID, String name, String type, List<int> newReq, List<int> newOpt, String instructions) {
    RecipeItem item = getByID(recipeID);
    item.name = name;
    item.type = type;
    item.requiredIng = newReq;
    item.optionalIng = newOpt;
    item.instructions = instructions;
    notifyListeners();
  }

  void updateInfo (int recipeID, String name, String type) {
    RecipeItem item = getByID(recipeID);
    item.name = name;
    item.type = type;
    notifyListeners();
  }

  void updateRequiredIng (int recipeID, List<int> newReq) {
    RecipeItem item = getByID(recipeID);
    item.requiredIng = newReq;
    notifyListeners();
  }
  void updateOptionalIng (int recipeID, List<int> newOpt) {
    RecipeItem item = getByID(recipeID);
    item.optionalIng = newOpt;
    notifyListeners();
  }

  void remove (int recipeID) {
    recipeIDList.remove(recipeID);
    if (recipeIDList.isEmpty) {
      add();
    }
    notifyListeners();
  }

  List<String> getAllTypes () {
    List<String> types = [];
    for (var id in recipeIDList) {
      RecipeItem item = getByID(id);
      String type = item.type;
      if (!types.contains(type)) {
        types.add(type);
      }
    }
    return types;
  }
}