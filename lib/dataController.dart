import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main.dart';

class DataController extends GetxController {
  Color accentColor = CustomColors.appBackground;
  List<String>? killers;
  List<String>? perks;
  Map<String, List<String>>? killerPerks;
}
