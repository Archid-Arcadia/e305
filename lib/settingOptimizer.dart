import 'dart:io';

import 'package:e305/ui-Toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:preferences/preference_service.dart';

/*Fire Tablet + :
I/flutter (27727): Calculated DPI: 1.3312500715255737
I/flutter (27727): Calculated Processors: 4

Oneplus 6T:
I/flutter ( 7755): Calculated DPI: 2.625
I/flutter ( 7755): Calculated Processors: 8

Oneplus 7 Pro:
I/flutter (23604): Calculated DPI: 3.5
I/flutter (23604): Calculated Processors: 8

Fire Tablet -:
I/flutter ( 7224): Calculated DPI: 1.0
I/flutter ( 7224): Calculated Processors: 3*/

Future<bool> Optimizer(BuildContext context) async {
  //8+ processors is High
  //4+ processors is Mid
  //3- processors is low

  //DPI 2.5+ is High
  //DPI 1.3+ is Mid
  //DPI 1- is Low/Garbage

  double DensityPI = MediaQuery.of(context).devicePixelRatio;
  int processors = Platform.numberOfProcessors;
  //print('Calculated DPI: ' + DensityPI.toString());
  //print('Calculated Processors: ' + processors.toString());
  bool highresThumb_notSet =
      (PrefService.getBool('hiresChoice') == null); //Thumbnails
  bool animate_notSet =
      (PrefService.getBool('animateChoice') == null); //animations
  bool suggestionbar_notSet =
      (PrefService.getBool('suggestBar') == null); //the bar
  bool fullImage_notSet = (PrefService.getBool('fullImage') == null);
  log('Set Optimize Targets: ' +
      (!highresThumb_notSet &&
              !animate_notSet &&
              !suggestionbar_notSet &&
              !fullImage_notSet)
          .toString());

  //Set Image Qualities
  if (DensityPI < 1.3) {
    if (fullImage_notSet) {
      PrefService.setBool('fullImage', false);
    }
    if (highresThumb_notSet) {
      PrefService.setBool('hiresChoice', false);
    }
  } else if (DensityPI < 2.5) {
    if (fullImage_notSet) {
      PrefService.setBool('fullImage', false);
    }
    if (highresThumb_notSet) {
      PrefService.setBool('hiresChoice', true);
    }
  } else if (DensityPI >= 2.5) {
    if (fullImage_notSet) {
      PrefService.setBool('fullImage', true);
    }
    if (highresThumb_notSet) {
      PrefService.setBool('hiresChoice', true);
    }
  }

  //Set Performance Qualities
  if (processors < 3) {
    if (animate_notSet) {
      PrefService.setBool('animateChoice', false);
    }
    if (suggestionbar_notSet) {
      PrefService.setBool('suggestBar', false);
    }
  } else if (processors < 8) {
    if (animate_notSet) {
      PrefService.setBool('animateChoice', true);
    }
    if (suggestionbar_notSet) {
      PrefService.setBool('suggestBar', false);
    }
  } else if (processors >= 8) {
    if (animate_notSet) {
      PrefService.setBool('animateChoice', true);
    }
    if (suggestionbar_notSet) {
      PrefService.setBool('suggestBar', true);
    }
  }
  return true;
}
