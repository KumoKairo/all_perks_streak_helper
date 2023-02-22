import 'dart:io';
import 'package:all_perks_streak_helper/addonsDownloadHelper.dart';
import 'package:all_perks_streak_helper/main.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class AddonsTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddonsTabState();
}

class AddonsController extends GetxController {
  Map<String, List<Widget>> addons = {};
  RxMap<String, String> addonColors = RxMap();

  @override
  void onInit() {
    super.onInit();
  }

  void save() {
    print("save");
  }

  void load() {
    print("load");
  }

  void reset() {
    print("reset");
  }

  void menuPressed(int menuItem) {
    // save
    if (menuItem == 0) {
      save();
    }
    // load
    else if (menuItem == 1) {
      load();
      refresh();
    }
    // reset
    else if (menuItem == 2) {
      reset();
      refresh();
    }
  }
}

class AddonsTabState extends State<AddonsTab> {
  final AddonsController controller = Get.find<AddonsController>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: ScrollController(),
      children: getAllAddonRows(),
    );
  }

  List<Widget> getAllAddonRows() {
    var killerAddons = List<Widget>.empty(growable: true);
    var addonsRootFolder = AddonsDownloadHelper.addonsRootFolder;

    var addonsRootDirectory =
        Directory(addonsRootFolder).listSync().whereType<Directory>().toList();

    for (var killerAddonsDir in addonsRootDirectory) {
      var dirPath = Directory(killerAddonsDir.path.toString());

      var killerName = dirPath.path.split('\\').last;

      var addonImages = dirPath
          .listSync()
          .toList()
          .map((img) => img.path)
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
                  child: Image.file(File(img))))))
          .toList();

      controller.addons[killerName] = addonImages;

      var addonsWrap = ReorderableWrap(
        needsLongPressDraggable: false,
        controller: ScrollController(),
        onReorder: (int oldIndex, int newIndex) {
          var addons = controller.addons[killerName]!;
          addons.insert(newIndex, addons.removeAt(oldIndex));
        },
        children: addonImages,
      );

      killerAddons.add(Container(
          margin: EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              SizedBox(
                  width: 88, child: Image.file(File("${dirPath.path}.png"))),
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
