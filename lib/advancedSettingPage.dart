import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'ui-Toolkit.dart';

class AdvancedSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdvancedSettingPage();
  }
}

class _AdvancedSettingPage extends State<AdvancedSettingPage> {
  int cacheSize = 0;

  @override
  Widget build(BuildContext context) {
    DiskCache().cacheSize().then((cacheSize) {
      cacheSize = cacheSize;
    });
    int currentSize = DiskCache().currentEntries;
    int maxEntries = DiskCache().maxEntries;
    int maxCacheSize = DiskCache().maxSizeBytes;
    log('Current Image Cache Size: ' + ImageCache().currentSize.toString());
    log('Image Cache Max Size: ' + ImageCache().maximumSize.toString());
    log('Current Cache Size (Bytes): ' +
        ImageCache().currentSizeBytes.toString());
    log('Image Cache Max Size (Bytes): ' +
        ImageCache().maximumSizeBytes.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("N.E.R.D."),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.syncAlt),
            onPressed: () {
              setState(() {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        child: ListView(
          children: <Widget>[
            Text("Current Image Cache Size: " +
                currentSize.toString() +
                " Entries."),
            Text(
                "Image Cache Max Size: " + maxEntries.toString() + " Entries."),
            Text("Current Image Cache Size: " +
                ' ' +
                "(Bytes)" +
                ' ' +
                filesize(cacheSize)),
            Text("Image Cache Max Size: " +
                ' ' +
                "(Bytes)" +
                ' ' +
                filesize(maxCacheSize)),
            MaterialButton(
              onPressed: () {
                DiskCache().clear();
              },
              child: Text("Clear Cache"),
            )
          ],
        ),
      ),
    );
  }
}
