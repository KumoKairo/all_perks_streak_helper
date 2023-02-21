import 'package:all_perks_streak_helper/addonsDownloadHelper.dart';
import 'package:flutter/material.dart';
import 'package:all_perks_streak_helper/dataController.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'perksSearchDelegate.dart';
import 'package:get/get.dart';

void main() => runApp(MaterialApp(home: AllPerksStreakHelper()));

class CustomColors {
  static const Color perkHighlight = Color.fromARGB(255, 152, 48, 34);
  static const Color appBackground = Color.fromARGB(255, 32, 34, 36);
  static const Color buttonsColor = Color.fromARGB(255, 83, 91, 99);
  static const Color itemsBackground = Color.fromARGB(255, 43, 45, 48);
  static const Color itemsBorderColor = Color.fromARGB(255, 22, 23, 24);
  static const Color fontColor = Color(0xffecf0f1);

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
  final data = Get.put(DataController());

  bool isChecked = false;

  _AllPerksStreakHelperState() {
    data.addListener(() => setState(() {}));
  }

  static const actionsPadding = EdgeInsets.only(right: 16.0);
  final perksKey = GlobalKey<_KillersPerksViewWidgetState>();

  void changeColor(Color color) {
    data.changeAccentColor(color);
  }

  void applyChangeColor() {
    setState(() {});
  }

  void onColorLoaded(Color color) {
    applyChangeColor();
  }

  void onSearchPicked(String? perkIndex) {
    if (perkIndex != null) {
      data.selectSearchedPerk(perkIndex);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    data.lastContext = context;
    data.onColorUpdated = () => {setState((() => {}))};
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        scaffoldBackgroundColor: CustomColors.appBackground,
      ),
      title: 'All perks streak helper',
      home: Scaffold(
        backgroundColor: CustomColors.appBackground,
        appBar: AppBar(
          backgroundColor: data.accentColor,
          leading: PopupMenuButton(
              color: data.shouldColorEverything.value
                  ? data.accentColor
                  : CustomColors.appBackground,
              icon: const Icon(Icons.menu),
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
                  perksKey.currentState?.menuPressed(value);
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
        body: KillersPerksViewWidget(key: perksKey),
      ),
    );
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
  final data = Get.find<DataController>();

  Future<void> menuPressed(int menuItem) async {
    // save
    if (menuItem == 0) {
      data.save();
    }
    // load
    else if (menuItem == 1) {
      await data.load();
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
    return FutureBuilder(
        future: data.getAllImagePaths(),
        builder: ((context, snapshot) {
          List<Widget> killerPortraits = List<Widget>.empty(growable: true);
          List<Widget> perkIcons = List<Widget>.empty(growable: true);
          if (data.killers != null && data.perks != null) {
            for (int index = 0; index < data.killers!.length; index++) {
              var killer = data.killers![index];
              var killerPerks = data.killerPerks![killer]!;
              var killerPerkWidgets = List<Widget>.empty(growable: true);
              for (var killerPerk in killerPerks) {
                var killerPerkWidget = Obx(() => Container(
                      width: 88.0,
                      height: 88.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: data.shouldColorEverything.value
                              ? data.accentColor
                              : CustomColors.appBackground,
                          border: Border.all(
                              color:
                                  killerPerk == data.highlightedPerkPath.value
                                      ? CustomColors.perkHighlight
                                      : CustomColors.itemsBorderColor,
                              width:
                                  killerPerk == data.highlightedPerkPath.value
                                      ? 4
                                      : 2)),
                      margin: const EdgeInsets.all(1.0),
                      child: Image(image: AssetImage(killerPerk)),
                    ));
                killerPerkWidgets.add(Draggable<String>(
                    data: '$killer $killerPerk',
                    feedback: killerPerkWidget,
                    childWhenDragging: const SizedBox.shrink(),
                    child: killerPerkWidget));
              }

              killerPortraits.add(DragTarget(
                key: Key(killer),
                onWillAccept: (perk) => data.killerPerks![killer]!.length < 4,
                onAccept: (perk) {
                  {
                    var killerName = '';
                    var perkName = '';

                    if ((perk as String).contains(' ')) {
                      killerName = perk.split(' ')[0];
                      perkName = perk.split(' ')[1];
                    } else {
                      perkName = perk;
                    }

                    if (killerName != '') {
                      data.killerPerks![killerName]!.remove(perkName);
                    }

                    data.killerPerks![killer]!.add(perkName);
                    data.perks!.remove(perkName);
                    refresh();
                  }
                },
                builder: (context, _, __) => Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: CustomColors.itemsBorderColor, width: 2.0),
                      shape: BoxShape.rectangle,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      color: data.shouldColorEverything.value
                          ? data.accentColor
                          : CustomColors.appBackground),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Row(children: [
                    ReorderableDragStartListener(
                        index: index, child: Image(image: AssetImage(killer))),
                    ...killerPerkWidgets
                  ]),
                ),
              ));
            }
            for (var perk in data.perks!) {
              var perkIcon = Obx(() => Container(
                    width: 88.0,
                    height: 88.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.shouldColorEverything.value
                            ? data.accentColor
                            : CustomColors.appBackground,
                        border: Border.all(
                            color: perk == data.highlightedPerkPath.value
                                ? CustomColors.perkHighlight
                                : CustomColors.itemsBorderColor,
                            width: perk == data.highlightedPerkPath.value
                                ? 4
                                : 2)),
                    margin: const EdgeInsets.all(1.0),
                    child: Image(image: AssetImage(perk)),
                  ));
              perkIcons.add(Draggable<String>(
                  data: perk,
                  feedback: perkIcon,
                  childWhenDragging: const SizedBox.shrink(),
                  child: perkIcon));
            }
          }

          Widget proxyDecorator(
              Widget child, int index, Animation<double> animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                return Material(
                  color: Colors.transparent,
                  child: child,
                );
              },
              child: child,
            );
          }

          return Row(children: [
            Expanded(
                child: ReorderableListView(
                    scrollController: data.portraitsScrollController,
                    proxyDecorator: proxyDecorator,
                    buildDefaultDragHandles: false,
                    onReorder: ((oldIndex, newIndex) {
                      // moving down
                      if (oldIndex < newIndex) {
                        newIndex--;
                      }
                      data.killers!
                          .insert(newIndex, data.killers!.removeAt(oldIndex));
                      refresh();
                    }),
                    children: killerPortraits)),
            Expanded(
                child: DragTarget(
                    onAccept: (perk) {
                      var killerName = '';
                      var perkName = '';

                      if ((perk as String).contains(' ')) {
                        killerName = perk.split(' ')[0];
                        perkName = perk.split(' ')[1];
                      } else {
                        perkName = perk;
                      }

                      if (killerName != '') {
                        data.killerPerks![killerName]!.remove(perkName);
                      }

                      if (!data.perks!.contains(perkName)) {
                        data.perks!.add(perkName);
                        data.perks!.sort((a, b) => a.compareTo(b));
                        refresh();
                      }
                    },
                    builder: (context, _, __) => GridView.count(
                          controller: data.perksGridScrollController,
                          crossAxisCount: 8,
                          children: perkIcons,
                        )))
          ]);
        }));
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
