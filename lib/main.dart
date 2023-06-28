import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:green_flames_cookbook_app/pages/RecipePage.dart';
import 'package:green_flames_cookbook_app/pages/IngredientsPage.dart';
import 'package:green_flames_cookbook_app/pages/PlannerPage.dart';

import 'package:green_flames_cookbook_app/models/IngredientModel.dart';
import 'package:green_flames_cookbook_app/models/RecipeModel.dart';
import 'package:green_flames_cookbook_app/models/PlannerModel.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IngredientModel>(
          create: (context) => IngredientModel(),
        ),
        ChangeNotifierProvider<RecipeModel>(
          create: (context) => RecipeModel(),
        ),
        ChangeNotifierProvider<PlannerModel>(
          create: (context) => PlannerModel()
        )
      ],
      child: CupertinoApp.router(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Color.fromARGB(255, 62, 140, 33),
          barBackgroundColor: Color.fromARGB(255, 242, 246, 223),
        ),
        routerConfig: routerConfig(),
      )
    );
  }
}

GoRouter routerConfig() {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => MainPage(),
      )
    ],
  );
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(255, 242, 246, 223),
      child: Center(
        child: Column 
        (mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.0),
            Icon(CupertinoIcons.flame_fill, size: 100.0,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Green Flames',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold
                ),
              ),
            ), 
            SizedBox(height: 50.0),
            CupertinoButton.filled(
              onPressed: () {
                context.pushReplacement('/main');
              },
              child: Text('GO'),
            ),
          ]
        )
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder_fill),
            label: 'Recipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart_fill),
            label: 'Ingredients',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: 'Planner',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        Widget page;
        switch (index) {
          case 0: 
            page = RecipePage();
            break;
          case 1:
            page = IngredientsPage();
            break;
          case 2:
            page = PlannerPage();
            break;
          default:
            throw UnimplementedError('No widget for index $index');
        }
        return CupertinoTabView(
          builder: (BuildContext context) {
            return page;
          },
        );
      },
    );
  }
}