import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class CustomColors {
  static const Color background = Color.fromARGB(255, 47, 53, 66);
  static const Color border = Color.fromARGB(255, 87, 96, 111);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: Scaffold(
        body: KillersPerksViewWidget(),
      ),
    );
  }
}

class ImagePathsData {
  List<String> killersImagePaths;
  List<String> perksImagePaths;

  ImagePathsData(this.killersImagePaths, this.perksImagePaths);
}

class KillersPerksViewWidget extends StatefulWidget {
  const KillersPerksViewWidget({Key? key}) : super(key: key);

  @override
  State<KillersPerksViewWidget> createState() => _KillersPerksViewWidgetState();
}

class _KillersPerksViewWidgetState extends State<KillersPerksViewWidget> {
  static const String killersKey = 'killers';
  static const String perksKey = 'perks';

  List<String>? _killers;
  List<String>? _perks;
  Map<String, List<String>>? _killerPerks;

  Future refresh() async {
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(killersKey, _killers!);
    await prefs.setStringList(perksKey, _perks!);

    for (var killer in _killerPerks!.keys) {
      if (_killerPerks![killer]!.isNotEmpty) {
        await prefs.setStringList(killer, _killerPerks![killer]!);
      }
    }
  }

  Future<ImagePathsData> _getAllImagePaths() async {
    if (_killers != null && _perks != null) {
      return ImagePathsData(_killers!, _perks!);
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedKillers = prefs.getStringList(killersKey);
    final List<String>? storedPerks = prefs.getStringList(perksKey);

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

    if (storedKillers != null && storedPerks != null) {
      final newKillers =
          _killers!.where((element) => !storedKillers.contains(element));

      final newPerks =
          _perks!.where((element) => !storedPerks.contains(element));

      _killers = storedKillers;
      _killers!.addAll(newKillers);
      _perks = storedPerks;
      _perks!.addAll(newPerks);
    }

    for (var killer in _killers!) {
      final storedKillerPerks = prefs.getStringList(killer);
      if (storedKillerPerks != null) {
        for (var storedKillerPerk in storedKillerPerks) {
          _perks!.remove(storedKillerPerk);
          _killerPerks![killer]!.add(storedKillerPerk);
        }
      }
    }

    return ImagePathsData(_killers!, _perks!);
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
                      color: CustomColors.background,
                      border: Border.all(color: CustomColors.border, width: 2)),
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
                  decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: CustomColors.background),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Row(children: [
                    ReorderableDragStartListener(
                        index: index, child: Image(image: AssetImage(killer))),
                    ...killerPerkWidgets,
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
                    color: CustomColors.background,
                    border: Border.all(color: CustomColors.border, width: 2)),
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
          return Row(children: [
            Expanded(
                child: ReorderableListView(
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
                      _perks!.add(perkName);
                      _perks!.sort((a, b) => a.compareTo(b));
                      refresh();
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
