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
  RxMap<String, Color> addonColors = RxMap();

  @override
  void onInit() {
    super.onInit();
  }
}

class AddonsTabState extends State<AddonsTab> {
  AddonsController controller = Get.put(AddonsController());

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
                    onPressed: () =>
                        changeAddonColor(img, CustomColors.tierSColor),
                  ),
                  ContextMenuButtonConfig(
                    "A",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierAColor,
                    ),
                    onPressed: () =>
                        changeAddonColor(img, CustomColors.tierAColor),
                  ),
                  ContextMenuButtonConfig(
                    "B",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierBColor,
                    ),
                    onPressed: () =>
                        changeAddonColor(img, CustomColors.tierBColor),
                  ),
                  ContextMenuButtonConfig(
                    "C",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierCColor,
                    ),
                    onPressed: () =>
                        changeAddonColor(img, CustomColors.tierCColor),
                  ),
                  ContextMenuButtonConfig(
                    "D",
                    icon: const Icon(
                      Icons.circle,
                      color: CustomColors.tierDColor,
                    ),
                    onPressed: () =>
                        changeAddonColor(img, CustomColors.tierDColor),
                  )
                ],
              ),
              child: Obx(() => Container(
                  color: controller.addonColors.containsKey(img)
                      ? controller.addonColors[img]
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

  void changeAddonColor(String img, Color color) {
    controller.addonColors[img] = color;
  }
}
