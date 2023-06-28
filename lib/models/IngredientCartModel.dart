import 'package:flutter/foundation.dart';
import 'IngredientModel.dart';

class IngredientCartModel extends ChangeNotifier {
  late IngredientModel _ingredients;
  final List<int> myCart = [];

  IngredientModel get ingredients => _ingredients;

  set ingredients (IngredientModel newIngredients) {
    _ingredients = newIngredients;
    notifyListeners();
  }

  List<IngredientItem> get items => myCart.map((id) => _ingredients.getByID(id)).toList();

  void add(IngredientItem item) {
    myCart.add(item.ingredientID);
    notifyListeners();
  }

  void remove(IngredientItem item) {
    myCart.remove(item.ingredientID);
    notifyListeners();
  }
}