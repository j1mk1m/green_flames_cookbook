import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:kookbook_app/models/IngredientModel.dart';
import 'package:kookbook_app/models/RecipeModel.dart';

import 'package:kookbook_app/utils/recipeUtils.dart';

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Icon(CupertinoIcons.flame_fill),
        middle: Text('Recipe'),
      ),
      child: SafeArea(
        child: Scaffold(
          // backgroundColor: Color.fromARGB(255, 228, 244, 222),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 62, 140, 33),
            child: Icon(CupertinoIcons.plus, size: 35.0),
            onPressed: () {
              int recipeID = Provider.of<RecipeModel>(context, listen: false).add();
              RecipeItem item = Provider.of<RecipeModel>(context, listen: false).getByID(recipeID);
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return RecipeItemPage(item: item);
                  }
                )
              );
            },
          ),
          body: RecipePageMain()
        ),
      )
    );
  }
}

class RecipePageMain extends StatefulWidget {
  const RecipePageMain({super.key});

  @override
  State<RecipePageMain> createState() => _RecipePageMainState();
}

class _RecipePageMainState extends State<RecipePageMain> {
  late TextEditingController textController;
  SortModeRec _sortMode = SortModeRec.Default;
  String _query = '';
  bool makeFilter = false;
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
      mainAxisAlignment: MainAxisAlignment.start,
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
                  onValueChanged: (SortModeRec? value) {
                    if (value != null) {
                      setState(() {
                        _sortMode = value;
                      });
                    }
                  },
                  children: <SortModeRec, Widget>{
                    SortModeRec.Default: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Default'),
                    ),
                    SortModeRec.Name: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Name'),
                    ),
                    SortModeRec.Type: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Type'),
                    ),
                  },
                ),
                CupertinoSwitch(
                  value: makeFilter, 
                  onChanged: (value) {
                    setState(() {
                      makeFilter = value;
                    });
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
            child: Consumer<RecipeModel>(
              builder:(context, recipes, child) {
                var filteredRecipes = filterRecipeList(context, recipes.items, _query, makeFilter);
                filteredRecipes = sort(filteredRecipes, _sortMode, reversed: _reversed);
                return filteredRecipes.isNotEmpty ?
                ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) => RecipeListItem(filteredRecipes[index])
                )
                :
                (_query.isNotEmpty ?
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No search results...', textAlign: TextAlign.center,),
                      Text('Click the + icon to add recipes!')
                    ],
                  ),
                )
                :
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No recipes yet...', textAlign: TextAlign.center,),
                      Text('Click the + icon to add recipes!')
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

class RecipeListItem extends StatelessWidget {
  final RecipeItem item;
  const RecipeListItem(this.item);

  @override
  Widget build(BuildContext context) {
    var ingredients = context.watch<IngredientModel>();
    String ingredientList = item.requiredIng.map((id) => ingredients.getByID(id).name).toList().toString();
    return CupertinoListTile(
      title: Text(item.name),
      additionalInfo: Text(item.type),
      subtitle: Text(item.requiredIng.isEmpty ? 'No ingredients' : ingredientList.substring(1, ingredientList.length-1)),
      trailing: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: ingredients.haveAll(item.requiredIng) ? 
          Icon(CupertinoIcons.checkmark_square_fill) 
          : Icon(CupertinoIcons.xmark_square_fill, color: Color.fromARGB(255, 185, 24, 24)),
        ),
      onTap: () {
        Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (BuildContext context) {
                return RecipeItemPage(item: item);
              }
            )
          );
      },
    );
  }
}

class RecipeItemPage extends StatefulWidget {
  final RecipeItem item;
  const RecipeItemPage({super.key, required this.item});

  @override
  State<RecipeItemPage> createState() => _RecipeItemPageState(item);
}

class _RecipeItemPageState extends State<RecipeItemPage> {
  final RecipeItem item;
  _RecipeItemPageState(this.item);

  bool typeList = false;
  int _selectedType = 0;
  List<int> _requiredIng = [];
  List<int> _optionalIng = [];
  IngOrInst ingOrInst = IngOrInst.ingredients;

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _instructionController;

  @override
  void initState() {
    super.initState();
    _requiredIng = item.requiredIng;
    _optionalIng = item.optionalIng;
    _nameController = TextEditingController(text: item.name);
    _typeController = TextEditingController(text: item.type);
    _instructionController = TextEditingController(text: item.instructions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _instructionController.dispose();
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

  void _showRequiredIngSelect(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (context) {
        var items = Provider.of<IngredientModel>(context, listen: false).items.map((item) => MultiSelectItem(item.ingredientID, item.name)).toList();
        return  SafeArea(
          child: MultiSelectBottomSheet(
            items: items,
            initialValue: _requiredIng,
            onConfirm: (values) {
              setState(() {
                _requiredIng = values;
              });
              // Provider.of<RecipeModel>(context, listen: false).updateRequiredIng(item.recipeID, values);
            },
            searchable: true,
            listType: MultiSelectListType.CHIP,
            initialChildSize: 0.4,
            maxChildSize: 0.4,
            minChildSize: 0.4,
          ),
        );
      },
    );
  }

  void _showOptionalIngSelect(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,
      builder: (context) {
        var items = Provider.of<IngredientModel>(context, listen: false).items.map((item) => MultiSelectItem(item.ingredientID, item.name)).toList();
        return  SafeArea(
          child: MultiSelectBottomSheet(
            items: items,
            initialValue: _optionalIng,
            onConfirm: (values) {
              setState(() {
                _optionalIng = values;
              });
              // Provider.of<RecipeModel>(context, listen: false).updateOptionalIng(item.recipeID, values);
            },
            searchable: true,
            listType: MultiSelectListType.CHIP,
            initialChildSize: 0.4,
            maxChildSize: 0.4,
            minChildSize: 0.4,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var recipes = context.watch<RecipeModel>();
    var types = recipes.getAllTypes();
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
            recipes.remove(item.recipeID);
            Navigator.of(context).pop();
          },
        )
      ),
      child: SafeArea(
        child: 
        ingOrInst == IngOrInst.ingredients ? Column(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSlidingSegmentedControl(
                    groupValue: ingOrInst,
                    onValueChanged: (IngOrInst? value) {
                      if (value != null) {
                        setState(() {
                          ingOrInst = value;
                        });
                      }
                    },
                    children: <IngOrInst, Widget>{
                      IngOrInst.ingredients: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Ingredients'),
                      ),
                      IngOrInst.instructions: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Instructions'),
                      ),
                    },
                  ),
            ),
            CupertinoButton(
              child: Text('Required'),
              onPressed: () {
                _showRequiredIngSelect(context);
              },
            ),
            Expanded(
              child: _requiredIng.isNotEmpty ? ListView.builder(
                itemCount: _requiredIng.length,
                itemBuilder: (context, index) {
                  var ingID = _requiredIng[index];
                  var item = Provider.of<IngredientModel>(context, listen: false).getByID(ingID);
                  return CupertinoListTile(
                    title: Text(item.name),
                    subtitle: Text(item.type),
                    trailing: item.have? 
                      Icon(CupertinoIcons.checkmark_square_fill) 
                    : Icon(CupertinoIcons.xmark_square_fill, color: Color.fromARGB(255, 185, 24, 24)),
                  );
                },
              ) : Center(child: Text('No required ingredients.'))
            ),
            CupertinoButton(
              child: Text('Optional'),
              onPressed: () {
                _showOptionalIngSelect(context);
              },
            ),
            _optionalIng.isNotEmpty ? Expanded(
              child:
                ListView.builder(
                  itemCount: _optionalIng.length,
                  itemBuilder: (context, index) {
                    var ingID = _optionalIng[index];
                    var item = Provider.of<IngredientModel>(context, listen: false).getByID(ingID);
                    return CupertinoListTile(
                      title: Text(item.name),
                      subtitle: Text(item.type),
                      trailing: item.have? 
                        Icon(CupertinoIcons.checkmark_square_fill) 
                        : Icon(CupertinoIcons.xmark_square_fill, color: Color.fromARGB(255, 185, 24, 24)),
                    );
                  },
                ) 
            ) : Center(child: Text('No optional ingredients.')),
            CupertinoButton(
              child: Text('Save'), 
              onPressed: () {
                recipes.update(item.recipeID, _nameController.text, _typeController.text, _requiredIng, _optionalIng, _instructionController.text);
                Navigator.of(context).pop();
              }
            ),
          ],
        )
        :
        Column(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSlidingSegmentedControl(
                    groupValue: ingOrInst,
                    onValueChanged: (IngOrInst? value) {
                      if (value != null) {
                        setState(() {
                          ingOrInst = value;
                        });
                      }
                    },
                    children: <IngOrInst, Widget>{
                      IngOrInst.ingredients: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Ingredients'),
                      ),
                      IngOrInst.instructions: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Instructions'),
                      ),
                    },
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  controller: _instructionController,
                  maxLines: 20,
                  placeholder: 'Write recipe instructions here',
                ),
              ),
            ),
            CupertinoButton(
              child: Text('Save'), 
              onPressed: () {
                recipes.update(item.recipeID, _nameController.text, _typeController.text, _requiredIng, _optionalIng, _instructionController.text);
                Navigator.of(context).pop();
              }
            ),
          ],
        ),
      ),
    );
  }
}