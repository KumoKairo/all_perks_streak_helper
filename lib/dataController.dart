import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PerkPathToReadableName {
  String path;
  String readableName;

  PerkPathToReadableName({required this.path, required this.readableName});
}

class DataController extends GetxController {
  final beforeCapitalLetterSplit = RegExp(r"(?=[A-Z])");

  BuildContext? lastContext;
  Timer? _lastHighlightTimer;

  // no RxColor unfortunately
  Color accentColor = CustomColors.appBackground;
  var highlightedPerkPath = "".obs;
  final portraitsScrollController = ScrollController();
  final perksGridScrollController = ScrollController();

  List<String>? killers;
  List<String>? perks;
  Map<String, List<String>>? killerPerks;

  List<PerkPathToReadableName>? allAvailablePerks;

  Future<void> initializePerksAndKillers({bool force = false}) async {
    if (!force && perks != null && killers != null) {
      return;
    }

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    killers = manifestMap.keys
        .where((key) => key.contains('killers/') && !key.contains('.DS_Store'))
        .toList();

    perks = manifestMap.keys
        .where((key) => key.contains('perks/') && !key.contains('.DS_Store'))
        .toList();

    allAvailablePerks = List.empty(growable: true);

    for (int i = 0; i < perks!.length; i++) {
      var perkPathName = perks![i];
      var readableName = perkPathName
          .replaceAll("assets/images/perks/", "")
          .replaceAll("IconPerks_", "")
          .replaceAll(".webp", "");
      readableName = readableName.split(beforeCapitalLetterSplit).join(" ");
      readableName = readableName[0].toUpperCase() + readableName.substring(1);

      allAvailablePerks!.add(PerkPathToReadableName(
          path: perkPathName, readableName: readableName));
    }

    killerPerks = {};
    for (int i = 0; i < killers!.length; i++) {
      killerPerks![killers![i]] = List.empty(growable: true);
    }
  }

  Future<void> getAllImagePaths() async {
    await initializePerksAndKillers();
  }

  Future<void> save() async {
    var appDir = await getApplicationDocumentsDirectory();

    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: appDir.path,
      dialogTitle: 'Please select an output file:',
      fileName: 'perks.save',
    );

    if (outputFile != null) {
      var killers = this.killers!.join(" ");
      var perks = this.perks!.join(" ");
      String killerPerks = "";
      for (var killerPerk in this.killerPerks!.entries) {
        if (killerPerk.value.isNotEmpty) {
          killerPerks += "${killerPerk.key}:${killerPerk.value.join(",")}-";
        }
      }
      var file = File(outputFile);
      await file.writeAsString("$killers;$perks;$killerPerks;$accentColor");
    }
  }

  Future<void> load() async {
    FilePickerResult? loadFrom = await FilePicker.platform.pickFiles();
    if (loadFrom != null) {
      reset();
      var file = File(loadFrom.files.single.path!);
      var contents = await file.readAsString();
      var split = contents.split(";");
      if (split.length != 4) {
        return;
      }

      var storedKillers = split[0].split(" ");
      var storedPerks = split[1].split(" ");
      var storedKillerPerks = {};

      killers = storedKillers;
      perks = storedPerks;

      var killerPerksRaw = split[2];
      for (var killerPerkRaw in killerPerksRaw.split("-")) {
        if (killerPerkRaw.isNotEmpty) {
          var killerPerks = killerPerkRaw.split(":");
          var killer = killerPerks[0];
          var specificKillerPerks = killerPerks[1].split(',');
          if (specificKillerPerks.isNotEmpty) {
            for (var actualPerk in specificKillerPerks) {
              if (storedKillerPerks[killer] == null) {
                storedKillerPerks[killer] = List.empty(growable: true);
              }
              storedKillerPerks[killer]!.add(actualPerk);
            }
          }
        }
      }

      for (var killer in killers!) {
        if (storedKillerPerks.isNotEmpty == true) {
          var specificKillerPerks = storedKillerPerks[killer];
          if (specificKillerPerks != null) {
            for (var storedKillerPerk in specificKillerPerks) {
              if (perks!.contains(storedKillerPerk)) {
                perks!.remove(storedKillerPerk);
              }
              if (!killerPerks![killer]!.contains(storedKillerPerk)) {
                killerPerks![killer]!.add(storedKillerPerk);
              }
            }
          }
        }
      }

      var accentColor = split[3]
          .replaceAll("Color(", "")
          .replaceAll(")", "")
          .replaceAll("0x", "");
      var intAccentColor = int.parse(accentColor, radix: 16);
      this.accentColor = Color(intAccentColor);
    }
  }

  void reset() async {
    initializePerksAndKillers(force: true);
    accentColor = CustomColors.appBackground;
  }

  void selectSearchedPerk(String readablePerk) {
    for (var perk in allAvailablePerks!) {
      if (perk.readableName == readablePerk) {
        highlightedPerkPath.value = perk.path;
      }
    }

    for (int i = 0; i < perks!.length; i++) {
      if (perks![i] == highlightedPerkPath.value) {
        var roundedPosition = i - (i % 8);
        var offset = perksGridScrollController.position.maxScrollExtent *
            (roundedPosition / perks!.length);
        perksGridScrollController.animateTo(offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutSine);
      }
    }

    var selectedKillerIndex = 0;
    for (var currentKillerPerks in killerPerks!.entries) {
      selectedKillerIndex++;
      if (currentKillerPerks.value.contains(highlightedPerkPath.value)) {
        var offset = portraitsScrollController.position.maxScrollExtent *
            (selectedKillerIndex / killers!.length);

        portraitsScrollController.animateTo(offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutSine);
      }
    }

    _lastHighlightTimer?.cancel();
    _lastHighlightTimer = Timer(
        const Duration(seconds: 8),
        () => {
              highlightedPerkPath.value = "",
              // centerPerkGridOn = -1,
              // centerKillersColumnOn = -1
            });
  }
}
