import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class AddonsDownloadHelper {
  static const String wikiRootPage = 'https://deadbydaylight.fandom.com';
  static const String rootKillersPage = '/wiki/Killers';

  static const String killersContainerClass = "mw-parser-output";
  static const String killerSpecificWikiTable = "wikitable";
  static const String killerAddonImageClass = "image";

  static void downloadToTempDir() {
    get(Uri.parse(wikiRootPage + rootKillersPage)).then(parseRootPage);
  }

  static void parseRootPage(Response response) {
    var document = parse(response.body);
    var killersContainer =
        document.getElementsByClassName(killersContainerClass);
    var killers = killersContainer[0].children[21];
    for (var killer in killers.children) {
      var killerPage = killer.children[0].attributes.entries.first.value;
      var fullUrl = wikiRootPage + killerPage;
      get(Uri.parse(wikiRootPage + killerPage)).then(parseKillerSpecificPage);
    }
  }

  static void parseKillerSpecificPage(Response response) async {
    var killer = response.request!.url.toString().split('/').last;

    var document = parse(response.body);
    var wikiTables =
        document.getElementsByClassName(killersContainerClass).first.children;

    // print(wikiTables[2].text);

    var addonsIndex = -1;
    for (var i = 0; i < wikiTables.length; i++) {
      if (wikiTables[i].text.contains("Add-ons for ")) {
        addonsIndex = i;
      }
    }

    if (addonsIndex != -1) {
      var addonRows = wikiTables[addonsIndex + 1].children.first.children;
      for (var i = 1; i < addonRows.length; i++) {
        var addonImageUrl = addonRows[i]
            .children[0]
            .getElementsByClassName(killerAddonImageClass)
            .first
            .attributes
            .entries
            .first
            .value;

        var addonUri = Uri.parse(addonImageUrl);
        var addonPathSegments = addonUri.pathSegments;
        var addonName = addonPathSegments[addonPathSegments.length - 3]
            .split("_")[1]
            .split(".")[0];

        var fileName = "assets/images/addons/${killer}/${addonName}.png";

        get(addonUri)
            .then((image) => saveAddonImage(image.bodyBytes, fileName));
      }
    }
  }

  static void saveAddonImage(image, fileName) {
    var file = File(fileName);
    file.createSync(recursive: true);
    file.writeAsBytesSync(image);
  }
}
