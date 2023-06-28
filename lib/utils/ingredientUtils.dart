import '../models/IngredientModel.dart';

enum SortModeIng { Default, Name, Type, Have }

List<IngredientItem> sort (List<IngredientItem> ingList, SortModeIng mode, {bool reversed = false}) {
  switch (mode) {
    case SortModeIng.Default:
      return sortByDefault(ingList, reversed: reversed);
    case SortModeIng.Name:
      return sortByName(ingList, reversed: reversed);
    case SortModeIng.Type:
      return sortByType(ingList, reversed: reversed);
    case SortModeIng.Have:
      return sortByHave(ingList, reversed: reversed);
    default:
      return sortByDefault(ingList, reversed: reversed);
  }
}

List<IngredientItem> sortByDefault (List<IngredientItem> ingList, {bool reversed = false}) {
  ingList.sort((a,b) => a.ingredientID.compareTo(b.ingredientID));
  if (reversed) {
    ingList = ingList.reversed.toList();
  }
  return ingList;
}

List<IngredientItem> sortByName (List<IngredientItem> ingList, {bool reversed = false}) {
  ingList.sort((a, b) => a.name.compareTo(b.name));
  if (reversed) {
    ingList = ingList.reversed.toList();
  }
  return ingList;
}

List<IngredientItem> sortByType (List<IngredientItem> ingList, {bool reversed = false}) {
  ingList.sort((a, b) => a.type.compareTo(b.type));
  if (reversed) {
    ingList = ingList.reversed.toList();
  }
  return ingList;
}

List<IngredientItem> sortByHave (List<IngredientItem> ingList, {bool reversed = false}) {
  ingList.sort((a, b) {
      if (a.have) {
        return b.have ? 0 : 1;
      } else {
        return b.have ? -1 : 0;
      }
    });
  if (reversed) {
    ingList = ingList.reversed.toList();
  }
  return ingList;
}

List<IngredientItem> filterIngredientList (List<IngredientItem> originalList, String query) {
    return originalList
      .where((item) => item.name.toLowerCase().contains(query.toLowerCase()) || item.type.toLowerCase().contains(query.toLowerCase()))
      .toList();
}