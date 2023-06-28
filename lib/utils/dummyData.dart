import 'package:kookbook_app/models/IngredientModel.dart';
import 'package:kookbook_app/models/RecipeModel.dart';
import 'package:kookbook_app/models/PlannerModel.dart';

List<IngredientItem> defaultIngredientList = [
    IngredientItem(0, 'Onions', 'Vegetables', 2.0, true),
    IngredientItem(1, 'Green onions', 'Vegetables', 3.0, true),
    IngredientItem(2, 'Potatoes', 'Vegetables', 0.0, false),
    IngredientItem(3, 'Chicken thigh', 'Meat', 1.0, true),
    IngredientItem(4, 'Ground beef', 'Meat', 2.0, true),
    IngredientItem(5, 'Pork chops', 'Meat', 0.0, false),
    IngredientItem(6, 'Ice cream', 'Unassigned', 1.0, true),
    IngredientItem(7, 'Alfredo Sauce', 'Sauce', 1.0, true),
    IngredientItem(8, 'Linguine', 'Noodles', 1.0, true),
  ];

List<int> defaultIngredientIDList = [0, 1, 2, 3, 4, 5, 7, 8];

List<RecipeItem> defaultRecipeList = [
  RecipeItem(0, 'Chicken alfredo', 'Italian', [3, 7, 8], [0], 'Cook pasta noodles. Cook chicken with alfredo sauce. Combine'),
  RecipeItem(1, 'Pork stir fry', 'Asian', [0, 1, 5], [], 'Stir fry everything'),
  RecipeItem(2, 'Ice cream', 'Ice cream', [6], [], '')
];

List<int> defaultRecipeIDList = [0, 1, 2];

List<MealEvent> defaultMealList = [
  MealEvent(0, 0, DateTime.now(), MealType.Dinner, 3, ''),
  MealEvent(1, 1, DateTime.now(), MealType.Lunch, 2, 'some notes here'),
];

List<int> defaultMealIDList = [0, 1];
