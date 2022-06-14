import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class CustomColors {
  static const Color background = Color.fromARGB(255, 47, 53, 66);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: Scaffold(
        body: MyStatefulWidget(),
      ),
    );
  }
}

class ImagePathsData {
  List<String> killersImagePaths;
  List<String> perksImagePaths;

  ImagePathsData(this.killersImagePaths, this.perksImagePaths);
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int acceptedData = 0;

  Future<ImagePathsData> _getAllImagePaths() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final killers =
        manifestMap.keys.where((key) => key.contains('killers/')).toList();
    final perks =
        manifestMap.keys.where((key) => key.contains('perks/')).toList();

    return (ImagePathsData(killers, perks));
  }

  Map<String, String>? _killerPerks;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getAllImagePaths(),
        builder: ((context, snapshot) {
          List<Widget> killerPortraits = List<Widget>.empty(growable: true);
          List<Widget> perkIcons = List<Widget>.empty(growable: true);
          if (snapshot.hasData) {
            var paths = snapshot.data as ImagePathsData;
            for (var killer in paths.killersImagePaths) {
              killerPortraits.add(DragTarget(
                key: Key(killer),
                builder: (context, _, __) => Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: CustomColors.background),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Row(children: [Image(image: AssetImage(killer))]),
                ),
              ));
            }
            for (var perk in paths.perksImagePaths) {
              var perkIcon = Container(
                width: 88.0,
                height: 88.0,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: CustomColors.background),
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
                    onReorder: ((oldIndex, newIndex) {}),
                    children: killerPortraits)),
            Expanded(
                child: GridView.count(
              controller: ScrollController(),
              crossAxisCount: 8,
              children: perkIcons,
            ))
          ]);
        }));
  }
}
