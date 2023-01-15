import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DataController extends GetxController {
  Color accentColor = CustomColors.appBackground;
  List<String>? killers;
  List<String>? perks;
  Map<String, List<String>>? killerPerks;

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
}
