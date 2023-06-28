import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:kookbook_app/utils/plannerUtils.dart';
import 'package:kookbook_app/utils/dummyData.dart';

final List<String> dayOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

enum MealType { 
  Breakfast, Brunch, Lunch, Dinner, Snack;

  @override
  String toString() => name;
}
final List<MealType> mealTypeList = [MealType.Breakfast, MealType.Brunch, MealType.Lunch, MealType.Dinner, MealType.Snack];

class MealEvent {
  final int mealID;
  int recipeID;
  final DateTime day;
  MealType mealType;
  int rating;
  String notes;

  MealEvent(this.mealID, this.recipeID, this.day, this.mealType, this.rating, this.notes);

  @override
  String toString() => '${mealType.toString()} on ${DateFormat.yMMMEd().format(day)}';
}

class PlannerModel extends ChangeNotifier {
  List<MealEvent> mealList = defaultMealList;
  List<int> mealIDList = defaultMealIDList;

  List<MealEvent> get items => mealIDList.map((id) => getByID(id)).toList();
  LinkedHashMap<DateTime, List<MealEvent>> get mealEventMap {
    Iterable<MealEvent> allEvents = mealIDList.map((id) => getByID(id));
    LinkedHashMap<DateTime, List<MealEvent>> eventMap = LinkedHashMap<DateTime, List<MealEvent>>(
        equals: isSameDay,
        hashCode: getHashCode,
      );
    for (var event in allEvents) {
      if (eventMap[event.day] != null) {
        eventMap[event.day]?.add(event);
      } else {
        eventMap[event.day] = [event];
      }
    }
    return eventMap;
  }

  MealEvent getByID (int mealID) {
    return mealList[mealID];
  }

  int add (DateTime day, int firstRecipeID) {
    int newID = mealList.length;
    MealEvent newItem = MealEvent(newID, firstRecipeID, day, MealType.Dinner, 0, '');
    mealList.add(newItem);
    mealIDList.add(newID);
    notifyListeners();
    return newID;
  }

  void update (int mealID, int recipeID, MealType mealType, int rating, String notes) {
    MealEvent item = getByID(mealID);
    item.recipeID = recipeID;
    item.mealType = mealType;
    item.rating = rating;
    item.notes = notes;
    notifyListeners();
  }

  void remove (int mealID) {
    mealIDList.remove(mealID);
    notifyListeners();
  }
}