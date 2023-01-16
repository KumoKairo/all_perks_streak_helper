import 'package:flutter/material.dart';
import 'main.dart';
import 'package:get/get.dart';
import 'dataController.dart';

class PerkSearchDelegate extends SearchDelegate {
  final data = Get.find<DataController>();

  final Function(String?) onSearchDone;

  PerkSearchDelegate({required this.onSearchDone});

  void onDone(BuildContext context, String? perk) {
    onSearchDone(perk);
    close(context, perk);
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
    for (var perk in data.allAvailablePerks!) {
      if (perk.readableName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(perk.readableName);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () => onDone(context, result),
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
    for (var perk in data.allAvailablePerks!) {
      if (perk.readableName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(perk.readableName);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () => onDone(context, result),
          textColor: CustomColors.fontColor,
          tileColor: CustomColors.appBackground,
          title: Text(result),
        );
      },
    );
  }
}
