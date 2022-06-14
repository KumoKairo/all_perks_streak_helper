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
  List<String>? _killers;
  List<String>? _perks;
  Map<String, List<String>>? _killerPerks;

  void refresh() {
    print('Refresh');
    setState(() {});
  }

  Future<ImagePathsData> _getAllImagePaths() async {
    final prefs = await SharedPreferences.getInstance();

    if (_killers != null && _perks != null) {
      return ImagePathsData(_killers!, _perks!);
    }

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    _killers = manifestMap.keys
        .where((key) => key.contains('killers/') && !key.contains('.DS_Store'))
        .toList();
    _perks = manifestMap.keys
        .where((key) => key.contains('perks/') && !key.contains('.DS_Store'))
        .toList();

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
              killerPortraits.add(DragTarget(
                key: Key(killer),
                onAccept: (perk) => print('killers $perk'),
                builder: (context, _, __) => Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: CustomColors.background),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Row(children: [
                    ReorderableDragStartListener(
                        index: index, child: Image(image: AssetImage(killer)))
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
                    onAccept: (data) => print('perks: $data'),
                    builder: (context, _, __) => GridView.count(
                          controller: ScrollController(),
                          crossAxisCount: 8,
                          children: perkIcons,
                        )))
          ]);
        }));
  }
}
