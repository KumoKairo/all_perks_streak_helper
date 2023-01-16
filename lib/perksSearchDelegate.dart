import 'package:flutter/material.dart';
import 'main.dart';
import 'package:get/get.dart';
import 'dataController.dart';

class PerkSearchDelegate extends SearchDelegate {
  final data = Get.find<DataController>();

  final Function(int?) onSearchDone;

  PerkSearchDelegate({required this.onSearchDone});

  void onDone(BuildContext context, int? index) {
    onSearchDone(index);
    close(context, index);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
        scaffoldBackgroundColor: CustomColors.appBackground,
        textTheme: const TextTheme(
          headline6: TextStyle(
            color: CustomColors.fontColor,
            fontSize: 18.0,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          hintStyle: TextStyle(color: CustomColors.buttonsColor),
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: CustomColors.fontColor,
          backgroundColor: CustomColors.appBackground,
        ));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => onDone(context, null),
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in data.allAvailablePerks!) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () => onDone(context, index),
          textColor: CustomColors.fontColor,
          tileColor: CustomColors.appBackground,
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in data.allAvailablePerks!) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () => onDone(context, index),
          textColor: CustomColors.fontColor,
          tileColor: CustomColors.appBackground,
          title: Text(result),
        );
      },
    );
  }
}
