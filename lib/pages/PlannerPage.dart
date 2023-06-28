import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:green_flames_cookbook_app/models/PlannerModel.dart';
import 'package:green_flames_cookbook_app/models/RecipeModel.dart';
import 'package:green_flames_cookbook_app/utils/plannerUtils.dart';

class PlannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
      CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Icon(CupertinoIcons.flame_fill),
          middle: Text('Planner'),
        ),
        child: SafeArea(
          child: MealCalendar()
        ),
      );
  }
}

class MealCalendar extends StatefulWidget {
  @override
  State<MealCalendar> createState() => _MealCalendarState();
}

class _MealCalendarState extends State<MealCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<MealEvent> _getEventsForDay(DateTime day) {
    return Provider.of<PlannerModel>(context, listen: false).mealEventMap[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<MealEvent>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
              rangeHighlightColor: Color.fromARGB(100, 151, 173, 41),
              selectedDecoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 62, 140, 33)),
              todayDecoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(100, 62, 140, 33)),
              rangeStartDecoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 151, 173, 41)),
              rangeEndDecoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 151, 173, 41)),
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<PlannerModel>(
              builder: (context, model, child) {
                var map = model.mealEventMap;
                var eventList = <MealEvent>[];
                if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
                  if (_rangeStart != null && _rangeEnd != null) {
                    var days = daysInRange(_rangeStart!, _rangeEnd!);
                    eventList = [for (final d in days) ...(map[d] ?? [])];
                  } else if (_rangeStart != null) {
                    eventList = map[_rangeStart] ?? [];
                  } else if (_rangeEnd != null) {
                    eventList = map[_rangeEnd] ?? [];
                  }
                } else {
                  eventList = map[_selectedDay] ?? [];
                }
                return Scaffold(
                  floatingActionButton: _selectedDay != null ? FloatingActionButton(
                    backgroundColor: Color.fromARGB(255, 62, 140, 33),
                    child: Icon(CupertinoIcons.add, size: 35.0),
                    onPressed: () {
                      int mealID = Provider.of<PlannerModel>(context, listen: false).add(_selectedDay ?? DateTime.now(),
                                  Provider.of<RecipeModel>(context, listen: false).recipeIDList[0]);
                      MealEvent item = Provider.of<PlannerModel>(context, listen: false).getByID(mealID);
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return MealItemPage(item: item);
                          }
                        )
                      );
                    },
                  ) : null,
                  body: ListView.builder(
                    itemCount: eventList.length,
                    itemBuilder: (context, index) {
                      return PlannerListItem(eventList[index]);
                    },
                  ),
                );
              }
            ),
          ),
          
        ],
      ),
    );
  }
}

class PlannerListItem extends StatelessWidget {
  final MealEvent event;
  const PlannerListItem(this.event);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 242, 246, 223),
        border: Border.all(),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: CupertinoListTile(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) {
                return MealItemPage(item: event);
              }
            )
          );
        },
        title: Text(Provider.of<RecipeModel>(context, listen: false).getByID(event.recipeID).name),
        subtitle: Text(event.toString()),
        additionalInfo: Row(children: List.generate(event.rating, (index) => Icon(CupertinoIcons.flame_fill))),
      ),
    );
  }
}

class MealItemPage extends StatefulWidget {
  final MealEvent item;
  const MealItemPage({super.key, required this.item});
  @override
  State<MealItemPage> createState() => _MealItemPageState(item);
}

class _MealItemPageState extends State<MealItemPage> {
  final MealEvent item;
  _MealItemPageState(this.item);

  int _recipeIDIndex = 0;
  int _recipeID = 0;
  int _mealTypeIndex = 0;
  int _rating = 0;

  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _recipeIDIndex = max(0, Provider.of<RecipeModel>(context, listen: false).recipeIDList.indexOf(item.recipeID));
        _recipeID = item.recipeID;
        _mealTypeIndex = mealTypeList.indexOf(item.mealType);
        _rating = item.rating;
      });
    });
    _notesController = TextEditingController(text: item.notes);
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup(
      context: context, 
      builder: (BuildContext context) => SafeArea(
        child: Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: child
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    var mealModel = context.watch<PlannerModel>();
    var recipeModel = context.watch<RecipeModel>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(CupertinoIcons.chevron_back),
        ),
        middle: Text(item.toString()),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.delete, color: Color.fromARGB(255, 185, 24, 24)),
          onPressed: () {
            mealModel.remove(item.mealID);
            Navigator.of(context).pop();
          },
        )
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoFormRow(
              prefix: Text('Menu: '),
              child: CupertinoButton(
                padding: EdgeInsets.all(7.0),
                onPressed: () => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 30.0, 
                    scrollController: FixedExtentScrollController(
                      initialItem: _recipeIDIndex,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      setState(() {
                        _recipeIDIndex = selectedItem;
                        _recipeID = recipeModel.items[selectedItem].recipeID;
                      });
                    }, 
                    children: List<Widget>.generate(recipeModel.items.length, (int index) {
                      return Center(child: Text(recipeModel.items[index].name));
                    })
                  )
                ),
                child: Text(recipeModel.items[_recipeIDIndex].name)
              ),
            ),
            CupertinoFormRow(
              prefix: Text('Day: '),
              child: Text(DateFormat.yMMMEd().format(item.day)),
            ),
            CupertinoFormRow(
              prefix: Text('Meal Type: '),
              child: CupertinoButton(
                padding: EdgeInsets.all(7.0),
                onPressed: () => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 30.0, 
                    scrollController: FixedExtentScrollController(
                      initialItem: _mealTypeIndex,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      setState(() {
                        _mealTypeIndex = selectedItem;
                      });
                    }, 
                    children: [
                      Center(child: Text('Breakfast')),
                      Center(child: Text('Brunch')),
                      Center(child: Text('Lunch')),
                      Center(child: Text('Dinner')),
                      Center(child: Text('Snack')),
                    ]
                  )
                ),
                child: Text(mealTypeList[_mealTypeIndex].toString())
              ),
            ),
            CupertinoFormRow(
              prefix: Text('Rating: '),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(_rating >= 1 ? CupertinoIcons.flame_fill : CupertinoIcons.flame), 
                    onPressed: () {
                      setState(() {
                        _rating = 1;
                      });
                    }
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(_rating >= 2 ? CupertinoIcons.flame_fill : CupertinoIcons.flame), 
                    onPressed: () {
                      setState(() {
                        _rating = 2;
                      });
                    }
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(_rating >= 3 ? CupertinoIcons.flame_fill : CupertinoIcons.flame), 
                    onPressed: () {
                      setState(() {
                        _rating = 3;
                      });
                    }
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(_rating >= 4 ? CupertinoIcons.flame_fill : CupertinoIcons.flame), 
                    onPressed: () {
                      setState(() {
                        _rating = 4;
                      });
                    }
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(_rating >= 5 ? CupertinoIcons.flame_fill : CupertinoIcons.flame), 
                    onPressed: () {
                      setState(() {
                        _rating = 5;
                      });
                    }
                  ),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoTextField(
                minLines: 10,
                maxLines: 10,
                placeholder: 'Write down how your meal was!',
                controller: _notesController,
              ),
            ),
            CupertinoButton(
              child: Text('Save'), 
              onPressed: () {
                mealModel.update(item.mealID, _recipeID, mealTypeList[_mealTypeIndex], _rating, _notesController.text);
                Navigator.of(context).pop();
              }
            ),
          ],
        ),
      )
    );
  }
}