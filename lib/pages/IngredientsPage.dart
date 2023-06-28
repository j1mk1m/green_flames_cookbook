import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../models/IngredientModel.dart';
import '../utils/ingredientUtils.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Icon(CupertinoIcons.flame_fill),
        middle: Text('Ingredients')
      ),
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 62, 140, 33),
            onPressed: () {
              int ingredientID = Provider.of<IngredientModel>(context, listen: false).add();
              IngredientItem item = Provider.of<IngredientModel>(context, listen: false).getByID(ingredientID);
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return IngredientItemPage(item: item);
                  }
                )
              );
            },
            child: Icon(CupertinoIcons.add, size: 35.0),
          ),
          body: IngredientsPageMain()
        )
      ),
    );
  }
}

class IngredientsPageMain extends StatefulWidget {
  const IngredientsPageMain({super.key});

  @override
  State<IngredientsPageMain> createState() => _IngredientsPageMainState();
}

class _IngredientsPageMainState extends State<IngredientsPageMain> {
  late TextEditingController textController;
  SortModeIng _sortMode = SortModeIng.Default;
  String _query = '';
  bool _reversed = false;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              controller: textController,
              placeholder: 'Search',
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoSlidingSegmentedControl(
                  groupValue: _sortMode,
                  onValueChanged: (SortModeIng? value) {
                    if (value != null) {
                      setState(() {
                        _sortMode = value;
                      });
                    }
                  },
                  children: <SortModeIng, Widget>{
                    SortModeIng.Default: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Default'),
                    ),
                    SortModeIng.Name: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Name'),
                    ),
                    SortModeIng.Type: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Type'),
                    ),
                    SortModeIng.Have: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Have'),
                    ),
                  },
                ),
                (_reversed ?
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(CupertinoIcons.arrow_up_arrow_down_square_fill), 
                    onPressed: () {
                      setState(() {
                        _reversed = false;
                      });
                    }
                  )
                  :
                  CupertinoButton(
                    padding: EdgeInsets.all(0.0),
                    child: Icon(CupertinoIcons.arrow_up_arrow_down_square), 
                    onPressed: () {
                      setState(() {
                        _reversed = true;
                      });
                    }
                  )
                )
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: Consumer<IngredientModel>(
              builder:(context, ingredients, child) {
                var filteredIngredients = filterIngredientList(ingredients.items, _query);
                filteredIngredients = sort(filteredIngredients, _sortMode, reversed: _reversed);
                return filteredIngredients.isNotEmpty ?
                ListView.builder(
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) => IngredientListItem(filteredIngredients[index])
                )
                : (_query.isNotEmpty ?
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No search results...', textAlign: TextAlign.center,),
                      Text('Click the + icon to add ingredients!')
                    ],
                  ),
                )
                :
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No ingredients yet...', textAlign: TextAlign.center,),
                      Text('Click the + icon to add ingredients!')
                    ],
                  ),
                ));
              },
            )
          ),
        ],
      );
  }
}

class IngredientListItem extends StatelessWidget {
  final IngredientItem item;
  const IngredientListItem(this.item);

  @override
  Widget build(BuildContext context) {
    var ingredients = context.watch<IngredientModel>();

    return Dismissible(
      key: Key(item.name),
      // direction: DismissDirection.endToStart,
      dismissThresholds: {
        DismissDirection.endToStart: 0.3,
        DismissDirection.startToEnd: 0.3
      },
      secondaryBackground: Container(
        color: Color.fromARGB(255, 62, 140, 33),
      ),
      background: Container(
        color: Color.fromARGB(255, 185, 24, 24),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          ingredients.update(item.ingredientID, item.name, item.type, item.quantity + 1.0, true);
          return false;
        } else {
          if (item.quantity <= 1.0) {
            ingredients.update(item.ingredientID, item.name, item.type, 0.0, false);
          } else {
            ingredients.update(item.ingredientID, item.name, item.type, item.quantity - 1.0, true);
          }
          return false;
        }
      },
      child: CupertinoListTile(
        title: Text(item.name),
        subtitle: Text(item.type),
        additionalInfo: Text(
          item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)
        ),
        trailing: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: item.have ? 
          Icon(CupertinoIcons.checkmark_square_fill) 
          : Icon(CupertinoIcons.square, color: Color.fromARGB(255, 153, 169, 157),),
        ),
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                return IngredientItemPage(item: item);
              }
            )
          );
        },
      ),
    );
  }
}

class IngredientItemPage extends StatefulWidget {
  final IngredientItem item;
  const IngredientItemPage({super.key, required this.item});

  @override
  State<IngredientItemPage> createState() => _IngredientItemPageState(item);
}

class _IngredientItemPageState extends State<IngredientItemPage> {
  final IngredientItem item;
  _IngredientItemPageState(this.item);

  bool have = false;
  bool typeList = false;
  int _selectedType = 0;

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _quantityController; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        have = item.have;
      });
    });
    _nameController = TextEditingController(text: item.name);
    _typeController = TextEditingController(text: item.type);
    _quantityController = TextEditingController(text: item.quantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    super.dispose();
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
    var ingredients = context.watch<IngredientModel>();
    var types = ingredients.getAllTypes();
    int encountered = types.indexOf(_typeController.text);
    _selectedType = encountered >= 0 ? encountered : _selectedType;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(CupertinoIcons.chevron_back),
        ),
        middle: Text(_nameController.text),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.delete, color: Color.fromARGB(255, 185, 24, 24)),
          onPressed: () {
            ingredients.remove(item.ingredientID);
            Navigator.of(context).pop();
          },
        )
      ),
      child: SafeArea(
        child: CupertinoFormSection(
          header: const Text('Edit Ingredient'),
          footer: Center(
              child: 
                CupertinoButton(
                  // color: CupertinoThemeData.color,
                  child: Text('Save'), 
                  onPressed: () {
                    double? temp = double.tryParse(_quantityController.text);
                    if (temp != null) {
                    double newQuantity = double.parse(temp.toStringAsFixed(1));
                    ingredients.update(item.ingredientID, _nameController.text, _typeController.text, newQuantity, newQuantity > 0.0);
                    Navigator.of(context).pop();
                    }
                  }
                ),
            ),
          children: [
            CupertinoFormRow(
              prefix: Text('Name: '),
              child: CupertinoTextField(
                controller: _nameController,
              )
            ),
            CupertinoFormRow(
              prefix: Text('Type: '),
              child: typeList ?
                CupertinoTextField(
                  readOnly: true,
                  prefix: CupertinoButton(
                      padding: EdgeInsets.all(7.0),
                      onPressed: () => _showDialog(
                        CupertinoPicker(
                          magnification: 1.22,
                          squeeze: 1.2,
                          useMagnifier: true,
                          itemExtent: 30.0, 
                          scrollController: FixedExtentScrollController(
                            initialItem: _selectedType,
                          ),
                          onSelectedItemChanged: (int selectedItem) {
                            setState(() {
                              _selectedType = selectedItem;
                              _typeController.text = types[selectedItem];
                            });
                          }, 
                          children: List<Widget>.generate(types.length, (int index) {
                            return Center(child: Text(types[index]));
                          })
                        )
                      ),
                      child: Text(types[_selectedType])
                    ),
                  suffix: CupertinoButton(
                    onPressed: () {
                      setState(() {
                        typeList = false;
                      });
                    },
                    child: Icon(CupertinoIcons.square_list),
                  ),
                  controller: TextEditingController(text: ''),
                )
              :
               CupertinoTextField(
                suffix: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      typeList = true;
                    });
                  },
                  child: Icon(CupertinoIcons.pencil),
                ),
                controller: _typeController,
              )
            ),
            CupertinoFormRow(
              prefix: Text('Quantity: '),
              child: CupertinoTextField(
                  suffix: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: () {
                          double cur = double.parse(_quantityController.text);
                          _quantityController.text = max(cur - 1.0, 0.0).toString();
                        },
                        child: Icon(CupertinoIcons.minus_circle_fill)
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: () {
                          double cur = double.parse(_quantityController.text);
                          _quantityController.text = (cur + 1.0).toString();
                        },
                        child: Icon(CupertinoIcons.plus_circle_fill),
                      )
                    ],
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]+')),
                  ],
                  controller: _quantityController,
                ),
            ),
            CupertinoFormRow(
              prefix: Text('Have?'),
              child: CupertinoSwitch(
                value: have, 
                onChanged: (bool newValue) {
                  setState(() {
                    have = newValue;
                    if (!newValue) {
                      _quantityController.text = '0';
                    } else if (double.parse(_quantityController.text) == 0.0) {
                      _quantityController.text = '1';
                    }
                  });
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class IngredientCartPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var cart = context.watch<IngredientCartModel>();

//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: Text('My Ingredient Cart'),
//       ),
//       child: child
//     )
//   }
// }
