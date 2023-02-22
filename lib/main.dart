import 'package:all_perks_streak_helper/addonsDownloadHelper.dart';
import 'package:all_perks_streak_helper/addonsTab.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:all_perks_streak_helper/dataController.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'perksSearchDelegate.dart';
import 'package:get/get.dart';

void main() => runApp(MaterialApp(home: AllPerksStreakHelper()));

class CustomColors {
  static const Color perkHighlight = Color(0xFF983022);
  static const Color appBackground = Color(0xFF202224);
  static const Color buttonsColor = Color(0xFF535B63);
  static const Color itemsBackground = Color(0xFF2B2D30);
  static const Color itemsBorderColor = Color(0xFF161718);
  static const Color fontColor = Color(0xFFECF0F1);

  static const Color tierSColor = Color(0xAAFF7F7F);
  static const Color tierAColor = Color(0xAAFFBF7F);
  static const Color tierBColor = Color(0xAAFFDF7F);
  static const Color tierCColor = Color(0xAAFFFF7F);
  static const Color tierDColor = Color(0xAABFFF7F);

  static const List<Color> accentColors = [
    CustomColors.itemsBackground,
    Color.fromARGB(255, 69, 35, 67),
    Color.fromARGB(255, 44, 84, 53),
    Color.fromARGB(255, 42, 84, 87),
    Color.fromARGB(255, 45, 43, 86),
    Color.fromARGB(255, 43, 57, 88),
  ];
}

class AllPerksStreakHelper extends StatefulWidget {
  AllPerksStreakHelper({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AllPerksStreakHelperState();
}

class _AllPerksStreakHelperState extends State<AllPerksStreakHelper> {
  final oldData = Get.put(DataController());
  final addonsData = Get.put(AddonsController());

  bool isChecked = false;

  _AllPerksStreakHelperState() {
    oldData.addListener(() => setState(() {}));
  }

  static const actionsPadding = EdgeInsets.only(right: 16.0);
  final perksKey = GlobalKey<_KillersPerksViewWidgetState>();

  void changeColor(Color color) {
    oldData.changeAccentColor(color);
  }

  void applyChangeColor() {
    setState(() {});
  }

  void onColorLoaded(Color color) {
    applyChangeColor();
  }

  void onSearchPicked(String? perkIndex) {
    if (perkIndex != null) {
      oldData.selectSearchedPerk(perkIndex);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    oldData.lastContext = context;
    oldData.onColorUpdated = () => {setState((() => {}))};
    return ContextMenuOverlay(
        child: MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        scaffoldBackgroundColor: CustomColors.appBackground,
      ),
      title: 'All perks streak helper',
      home: Scaffold(
        backgroundColor: CustomColors.appBackground,
        appBar: AppBar(
          backgroundColor: oldData.accentColor,
          leading: PopupMenuButton(
              color: oldData.shouldColorEverything.value
                  ? oldData.accentColor
                  : CustomColors.appBackground,
              icon: const Icon(
                Icons.menu,
                color: CustomColors.fontColor,
              ),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text(
                      "Save",
                      style: TextStyle(color: CustomColors.fontColor),
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Load",
                        style: TextStyle(color: CustomColors.fontColor)),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text("Reset",
                        style: TextStyle(color: CustomColors.fontColor)),
                  )
                ];
              },
              onSelected: (value) {
                if (value != null && value is int) {
                  addonsData.menuPressed(value);
                }
              }),
          actions: [
            Padding(
                padding: actionsPadding,
                child: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => AddonsDownloadHelper.downloadToTempDir(),
                )),
            Padding(
                padding: actionsPadding,
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => {
                    showSearch(
                        context: context,
                        delegate:
                            PerkSearchDelegate(onSearchDone: onSearchPicked))
                  },
                )),
            Padding(
                padding: actionsPadding,
                child: IconButton(
                  icon: const Icon(Icons.format_paint_rounded),
                  onPressed: () => _dialogBuilder(context),
                )),
          ],
        ),
        body: AddonsTab(),
      ),
    ));
  }

  Future<void> _dialogBuilder(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog();
      },
    );
  }
}

class KillersPerksViewWidget extends StatefulWidget {
  const KillersPerksViewWidget({Key? key}) : super(key: key);

  @override
  State<KillersPerksViewWidget> createState() => _KillersPerksViewWidgetState();
}

class _KillersPerksViewWidgetState extends State<KillersPerksViewWidget> {
  final data = Get.find<AddonsController>();

  Future<void> menuPressed(int menuItem) async {
    // save
    if (menuItem == 0) {
      data.save();
    }
    // load
    else if (menuItem == 1) {
      data.load();
      refresh();
    }
    // reset
    else if (menuItem == 2) {
      data.reset();
      refresh();
    }
  }

  Future refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text("placeholder");
  }
}

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final data = Get.find<DataController>();

  bool isChecked = false;

  void changeColor(Color color) {
    data.changeAccentColor(color);
  }

  void applyChangeColor() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color getCheckboxFillColor(Set<MaterialState> states) {
      return CustomColors.fontColor;
    }

    Color getCheckboxOverlayColor(Set<MaterialState> states) {
      return Colors.transparent;
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 50.0,
        vertical: 100.0,
      ),
      backgroundColor: CustomColors.appBackground,
      title: const Text(
        'Pick a color',
        style: TextStyle(color: CustomColors.fontColor),
      ),
      content: SingleChildScrollView(
          child: BlockPicker(
        pickerColor: data.accentColor,
        onColorChanged: changeColor,
        availableColors: CustomColors.accentColors,
      )),
      actions: [
        const Text(
          "Color everything",
          style: TextStyle(color: CustomColors.fontColor, fontSize: 16),
        ),
        Obx(() => Checkbox(
            value: data.shouldColorEverything.value,
            checkColor: CustomColors.itemsBorderColor,
            activeColor: CustomColors.appBackground,
            overlayColor:
                MaterialStateProperty.resolveWith(getCheckboxOverlayColor),
            fillColor: MaterialStateProperty.resolveWith(getCheckboxFillColor),
            onChanged: (value) => setState(() {
                  data.changeColorSettingsAndSave(value!);
                }))),
        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
        ElevatedButton(
          style: const ButtonStyle(
              foregroundColor:
                  MaterialStatePropertyAll<Color>(CustomColors.fontColor),
              backgroundColor:
                  MaterialStatePropertyAll<Color>(CustomColors.buttonsColor)),
          child: const Text('Got it'),
          onPressed: () {
            applyChangeColor();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
