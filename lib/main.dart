import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'perksSearchDelegate.dart';

void main() => runApp(MaterialApp(home: AllPerksStreakHelper()));

class CustomColors {
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
  static const actionsPadding = EdgeInsets.only(right: 16.0);
  final perksKey = GlobalKey<_KillersPerksViewWidgetState>();

  Color pickerColor = CustomColors.itemsBackground;

  void changeColor(Color color) {
    pickerColor = color;
  }

  void applyChangeColor() {
    perksKey.currentState?.changeColors(pickerColor);
    setState(() {});
  }

  void onColorLoaded(Color color) {
    pickerColor = color;
    applyChangeColor();
  }

  void onSearchPicked(int? perkIndex) {
    print(perkIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
          scaffoldBackgroundColor: CustomColors.appBackground,
          appBarTheme:
              AppBarTheme(backgroundColor: CustomColors.appBackground)),
      title: 'All perks streak helper',
      home: Scaffold(
        backgroundColor: CustomColors.appBackground,
        appBar: AppBar(
          backgroundColor: pickerColor,
          leading: PopupMenuButton(
              color: CustomColors.appBackground,
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
                  ),
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
        body:
            KillersPerksViewWidget(onColorLoaded: onColorLoaded, key: perksKey),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
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
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            availableColors: CustomColors.accentColors,
          )),
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                  foregroundColor:
                      MaterialStatePropertyAll<Color>(CustomColors.fontColor),
                  backgroundColor: MaterialStatePropertyAll<Color>(
                      CustomColors.buttonsColor)),
              child: const Text('Got it'),
              onPressed: () {
                applyChangeColor();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ImagePathsData {
  List<String> killersImagePaths;
  List<String> perksImagePaths;

  ImagePathsData(this.killersImagePaths, this.perksImagePaths);
}

class KillersPerksViewWidget extends StatefulWidget {
  final Function(Color) onColorLoaded;

  const KillersPerksViewWidget({required this.onColorLoaded, Key? key})
      : super(key: key);

  @override
  State<KillersPerksViewWidget> createState() => _KillersPerksViewWidgetState();
}

class _KillersPerksViewWidgetState extends State<KillersPerksViewWidget> {
  Color _accentColor = CustomColors.itemsBackground;

  List<String>? _killers;
  List<String>? _perks;
  Map<String, List<String>>? _killerPerks;

  List<String>? _storedKillers;
  List<String>? _storedPerks;
  Map<String, List<String>>? _storedKillerPerks;

  void changeColors(Color newColor) {
    _accentColor = newColor;
    refresh();
  }

  void menuPressed(int menuItem) {
    if (menuItem == 0) {
      save();
    } else if (menuItem == 1) {
      load();
    } else if (menuItem == 2) {
      reset();
    }
  }

  Future<void> save() async {
    var appDir = await getApplicationDocumentsDirectory();

    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: appDir.path,
      dialogTitle: 'Please select an output file:',
      fileName: 'perks.save',
    );

    if (outputFile != null) {
      var killers = _killers!.join(" ");
      var perks = _perks!.join(" ");
      String killerPerks = "";
      for (var killerPerk in _killerPerks!.entries) {
        if (killerPerk.value.isNotEmpty) {
          killerPerks += "${killerPerk.key}:${killerPerk.value.join(",")}-";
        }
      }
      var file = File(outputFile);
      await file.writeAsString("$killers;$perks;$killerPerks;$_accentColor");
    }
  }

  Future<String?> load() async {
    FilePickerResult? loadFrom = await FilePicker.platform.pickFiles();
    if (loadFrom != null) {
      var file = File(loadFrom.files.single.path!);
      var contents = await file.readAsString();
      var split = contents.split(";");
      if (split.length != 4) {
        return null;
      }

      _storedKillers = split[0].split(" ");
      _storedPerks = split[1].split(" ");
      _storedKillerPerks = {};

      var killerPerksRaw = split[2];
      for (var killerPerkRaw in killerPerksRaw.split("-")) {
        if (killerPerkRaw.isNotEmpty) {
          var killerPerks = killerPerkRaw.split(":");
          var killer = killerPerks[0];
          var perks = killerPerks[1].split(',');
          if (perks.isNotEmpty) {
            for (var actualPerk in perks) {
              if (_storedKillerPerks![killer] == null) {
                _storedKillerPerks![killer] = List.empty(growable: true);
              }
              _storedKillerPerks![killer]!.add(actualPerk);
            }
          }
        }
      }

      var accentColor = split[3]
          .replaceAll("Color(", "")
          .replaceAll(")", "")
          .replaceAll("0x", "");
      var intAccentColor = int.parse(accentColor, radix: 16);
      _accentColor = Color(intAccentColor);
      widget.onColorLoaded(_accentColor);

      refresh();
    } else {
      return null;
    }
  }

  void reset() async {
    initializePerksAndKillers();
    widget.onColorLoaded(CustomColors.itemsBackground);
    refresh();
  }

  Future refresh() async {
    setState(() {});
  }

  Future<ImagePathsData> _getAllImagePaths() async {
    if (_killers != null && _perks != null && _storedKillers == null) {
      return ImagePathsData(_killers!, _perks!);
    }

    await initializePerksAndKillers();

    if (_storedKillers != null && _storedPerks != null) {
      final newKillers =
          _killers!.where((element) => !_storedKillers!.contains(element));

      final newPerks =
          _perks!.where((element) => !_storedPerks!.contains(element));

      _killers = _storedKillers;
      _killers!.addAll(newKillers);
      _perks = _storedPerks;
      _perks!.addAll(newPerks);
    }

    for (var killer in _killers!) {
      if (_storedKillerPerks != null) {
        var storedKillerPerks = _storedKillerPerks![killer];
        if (storedKillerPerks != null && storedKillerPerks.isNotEmpty) {
          for (var storedKillerPerk in storedKillerPerks) {
            if (_perks!.contains(storedKillerPerk)) {
              _perks!.remove(storedKillerPerk);
            }
            if (!_killerPerks![killer]!.contains(storedKillerPerk)) {
              _killerPerks![killer]!.add(storedKillerPerk);
            }
          }
        }
      }
    }

    _storedKillers = null;
    _storedPerks = null;
    _storedKillerPerks = null;

    return ImagePathsData(_killers!, _perks!);
  }

  Future<void> initializePerksAndKillers() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    _killers = manifestMap.keys
        .where((key) => key.contains('killers/') && !key.contains('.DS_Store'))
        .toList();
    _perks = manifestMap.keys
        .where((key) => key.contains('perks/') && !key.contains('.DS_Store'))
        .toList();

    _killerPerks = {};
    for (int i = 0; i < _killers!.length; i++) {
      _killerPerks![_killers![i]] = List.empty(growable: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getAllImagePaths(),
        builder: ((context, snapshot) {
          List<Widget> killerPortraits = List<Widget>.empty(growable: true);
          List<Widget> perkIcons = List<Widget>.empty(growable: true);
          if (snapshot.hasData) {
            var paths = snapshot.data as ImagePathsData;
            for (int index = 0;
                index < paths.killersImagePaths.length;
                index++) {
              var killer = paths.killersImagePaths[index];
              var killerPerks = _killerPerks![killer]!;
              var killerPerkWidgets = List<Widget>.empty(growable: true);
              for (var killerPerk in killerPerks) {
                var killerPerkWidget = Container(
                  width: 88.0,
                  height: 88.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accentColor,
                      border: Border.all(
                          color: CustomColors.itemsBorderColor, width: 2)),
                  margin: const EdgeInsets.all(1.0),
                  child: Image(image: AssetImage(killerPerk)),
                );
                killerPerkWidgets.add(Draggable<String>(
                    data: '$killer $killerPerk',
                    feedback: killerPerkWidget,
                    childWhenDragging: const SizedBox.shrink(),
                    child: killerPerkWidget));
              }

              killerPortraits.add(DragTarget(
                key: Key(killer),
                onWillAccept: (perk) => _killerPerks![killer]!.length < 4,
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
                      _killerPerks![killerName]!.remove(perkName);
                    }

                    _killerPerks![killer]!.add(perkName);
                    _perks!.remove(perkName);
                    refresh();
                  }
                },
                builder: (context, _, __) => Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      color: _accentColor),
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
            for (var perk in paths.perksImagePaths) {
              var perkIcon = Container(
                width: 88.0,
                height: 88.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentColor,
                    border: Border.all(
                        color: CustomColors.itemsBorderColor, width: 2)),
                margin: const EdgeInsets.all(1.0),
                child: Image(image: AssetImage(perk)),
              );
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
                    proxyDecorator: proxyDecorator,
                    buildDefaultDragHandles: false,
                    onReorder: ((oldIndex, newIndex) {
                      // moving down
                      if (oldIndex < newIndex) {
                        newIndex--;
                      }
                      _killers!.insert(newIndex, _killers!.removeAt(oldIndex));
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
                        _killerPerks![killerName]!.remove(perkName);
                      }

                      if (!_perks!.contains(perkName)) {
                        _perks!.add(perkName);
                        _perks!.sort((a, b) => a.compareTo(b));
                        refresh();
                      }
                    },
                    builder: (context, _, __) => GridView.count(
                          controller: ScrollController(),
                          crossAxisCount: 8,
                          children: perkIcons,
                        )))
          ]);
        }));
  }
}
