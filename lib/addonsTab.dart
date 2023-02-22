import 'dart:io';
import 'package:all_perks_streak_helper/addonsDownloadHelper.dart';
import 'package:all_perks_streak_helper/main.dart';
import 'package:context_menus/context_menus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:convert';

class AddonsTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddonsTabState();
}

class AddonsController extends GetxController {
  RxMap<String, RxList<String>> addonsMapping = RxMap();
  RxMap<String, String> addonColors = RxMap();

  @override
  void onInit() {
    super.onInit();
    var addonsRootFolder = AddonsDownloadHelper.addonsRootFolder;
    var addonsRootDirectory =
        Directory(addonsRootFolder).listSync().whereType<Directory>().toList();

    for (var killerAddonsDir in addonsRootDirectory) {
      var dirPath = Directory(killerAddonsDir.path.toString());
      var killerName = dirPath.path.split('\\').last;
      var addonList =
          dirPath.listSync().toList().map((img) => img.path).toList();

      addonsMapping[killerName] = RxList(addonList);
    }
  }

  Future<void> save() async {
    var outputFile = await safeFilePicker();

    if (outputFile != null) {
      var colors = json.encode(addonColors);
      var order = json.encode(addonsMapping);

      var save = "${colors}\n\n${order}";

      var file = File(outputFile);
      file.create(recursive: true);

      await file.writeAsString(save);
    }
  }

  Future<void> load() async {
    var loadFrom = await safeLoadFilePicker();

    if (loadFrom != null) {
      var file = File(loadFrom);
      var contents = file.readAsStringSync().split("\n\n");
      var colors = json.decode(contents[0]) as Map<String, dynamic>;
      var order = json.decode(contents[1]) as Map<String, dynamic>;

      for (var entry in colors.entries) {
        addonColors[entry.key] = entry.value as String;
      }

      for (var entry in order.entries) {
        var killer = entry.key;
        var addons = entry.value as List<dynamic>;

        if (addonsMapping.containsKey(killer)) {
          addonsMapping[killer] = RxList();
        }

        for (var addon in addons) {
          addonsMapping[killer]!.add(addon as String);
        }
      }
    }
  }

  void reset() {
    print("reset");
  }

  void menuPressed(int menuItem) async {
    // save
    if (menuItem == 0) {
      await save();
    }
    // load
    else if (menuItem == 1) {
      await load();
      refresh();
    }
    // reset
    else if (menuItem == 2) {
      reset();
      refresh();
    }
  }

  Future<String?> safeLoadFilePicker() async {
    var tempCurDir = Directory.current;
    FilePickerResult? loadFrom = await FilePicker.platform.pickFiles();
    Directory.current = tempCurDir;

    if (loadFrom != null) {
      return loadFrom.files.single.path;
    }

    return null;
  }

  Future<String?> safeFilePicker() async {
    var tempCurDir = Directory.current;
    var appDir = await getApplicationDocumentsDirectory();

    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: appDir.path,
      dialogTitle: 'Please select an output file:',
      fileName: 'addons.save',
    );

    Directory.current = tempCurDir;

    return outputFile;
  }
}

class AddonsTabState extends State<AddonsTab> {
  final AddonsController controller = Get.find<AddonsController>();

  AddonsTabState() {
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: ScrollController(),
      children: getAllAddonRows(),
    );
  }

  List<Widget> getAllAddonRows() {
    var killerAddons = List<Widget>.empty(growable: true);

    for (var killers in controller.addonsMapping.entries) {
      var killerName = killers.key;

      var addonImages = killers.value
          .map((img) => ContextMenuRegion(
              contextMenu: GenericContextMenu(
                autoClose: true,
                buttonConfigs: [
                  ContextMenuButtonConfig(
                    "S",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierSColor,
                    ),
                    onPressed: () => changeAddonColor(img, "S"),
                  ),
                  ContextMenuButtonConfig(
                    "A",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierAColor,
                    ),
                    onPressed: () => changeAddonColor(img, "A"),
                  ),
                  ContextMenuButtonConfig(
                    "B",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierBColor,
                    ),
                    onPressed: () => changeAddonColor(img, "B"),
                  ),
                  ContextMenuButtonConfig(
                    "C",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierCColor,
                    ),
                    onPressed: () => changeAddonColor(img, "C"),
                  ),
                  ContextMenuButtonConfig(
                    "D",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierDColor,
                    ),
                    onPressed: () => changeAddonColor(img, "D"),
                  )
                ],
              ),
              child: Obx(() => Container(
                  color: controller.addonColors.containsKey(img)
                      ? tierToColor(controller.addonColors[img]!)
                      : Colors.transparent,
                  key: ValueKey(img),
                  height: 88.0,
                  padding: const EdgeInsets.all(4.0),
                  child: Image.file(File(img))))))
          .toList();

      var addonsWrap = ReorderableWrap(
        needsLongPressDraggable: false,
        controller: ScrollController(),
        onReorder: (int oldIndex, int newIndex) {
          killers.value.insert(newIndex, killers.value.removeAt(oldIndex));
          addonImages.insert(newIndex, addonImages.removeAt(oldIndex));
        },
        children: addonImages,
      );

      killerAddons.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              SizedBox(
                  width: 88,
                  child: Image.file(File(
                      "${AddonsDownloadHelper.addonsRootFolder}\\${killerName}.png"))),
              Expanded(flex: 10, child: addonsWrap)
            ],
          )));
    }

    return killerAddons;
  }

  Color tierToColor(String tier) {
    switch (tier) {
      case "S":
        return CustomColors.tierSColor;
      case "A":
        return CustomColors.tierAColor;
      case "B":
        return CustomColors.tierBColor;
      case "C":
        return CustomColors.tierCColor;
      case "D":
        return CustomColors.tierDColor;
    }

    return Colors.transparent;
  }

  void changeAddonColor(String img, String colorTier) {
    controller.addonColors[img] = colorTier;
  }
}
