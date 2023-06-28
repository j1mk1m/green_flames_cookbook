import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/RecipeModel.dart';
import '../models/IngredientModel.dart';

enum SortModeRec { Default, Name, Type }
enum IngOrInst { ingredients, instructions }

List<RecipeItem> sort (List<RecipeItem> recList, SortModeRec mode, {bool reversed = false}) {
  switch (mode) {
    case SortModeRec.Default:
      return sortByDefault(recList, reversed: reversed);
    case SortModeRec.Name:
      return sortByName(recList, reversed: reversed);
    case SortModeRec.Type:
      return sortByType(recList, reversed: reversed);
    default:
      return sortByDefault(recList, reversed: reversed);
  }
}

List<RecipeItem> sortByDefault (List<RecipeItem> recList, {bool reversed = false}) {
  recList.sort((a,b) => a.recipeID.compareTo(b.recipeID));
  if (reversed) {
    recList = recList.reversed.toList();
  }
  return recList;
}

List<RecipeItem> sortByName (List<RecipeItem> recList, {bool reversed = false}) {
  recList.sort((a, b) => a.name.compareTo(b.name));
  if (reversed) {
    recList = recList.reversed.toList();
  }
  return recList;
}

List<RecipeItem> sortByType (List<RecipeItem> recList, {bool reversed = false}) {
  recList.sort((a, b) => a.type.compareTo(b.type));
  if (reversed) {
    recList = recList.reversed.toList();
  }
  return recList;
}

List<RecipeItem> filterRecipeList (BuildContext context, List<RecipeItem> originalList, String query, bool makeFilter) {
    List<RecipeItem> queryFilter = originalList
      .where((item) => item.name.toLowerCase().contains(query.toLowerCase()) || item.type.toLowerCase().contains(query.toLowerCase())).toList();
    if (makeFilter) {
      return queryFilter.where((item) => Provider.of<IngredientModel>(context, listen: false).haveAll(item.requiredIng)).toList();
    }
    return queryFilter;
}