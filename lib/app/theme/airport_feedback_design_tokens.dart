import 'package:flutter/material.dart';

abstract final class AirportFeedbackAssets {
  static const mialLogo = 'assets/branding/mial-logo.svg';
  static const rocketLaunchAnimation = 'assets/animation/rocket_launch.json';
  static const successAnimation = 'assets/animation/success.json';

  static const lightAirportBackground =
      'assets/branding/airport_background_light.png';
  static const darkAirportBackground =
      'assets/branding/airport_background_dark.png';

  static const slipperyFloor = 'assets/feedback/issues/slippery_floor.png';
  static const noSoap = 'assets/feedback/issues/no_soap.png';
  static const noToiletPaper = 'assets/feedback/issues/no_toilet_paper.png';
  static const mirrorDirty = 'assets/feedback/issues/mirror_dirty.png';
  static const urinalDirty = 'assets/feedback/issues/urinal_dirty.png';
  static const commodeDirty = 'assets/feedback/issues/commode_dirty.png';
  static const sinkClogged = 'assets/feedback/issues/sink_clogged.png';
  static const washbasinDirty = 'assets/feedback/issues/washbasin_dirty.png';
  static const waterjetIssue = 'assets/feedback/issues/waterjet_issue.png';
  static const unpleasantSmell = 'assets/feedback/issues/unpleasant_smell.png';
  static const others = 'assets/feedback/issues/others.png';
}

abstract final class AirportFeedbackColors {
  static const lightBackground = Color(0xFFF9F8FF);
  static const darkBackground = Color(0xFF031129);

  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF071A31);
  static const darkSurfaceAlt = Color(0xFF0B2A37);

  static const lightPrimaryText = Color(0xFF09183A);
  static const lightSecondaryText = Color(0xFF5F6780);
  static const darkPrimaryText = Color(0xFFFFFFFF);
  static const darkSecondaryText = Color(0xFFC2C8D7);

  static const primaryBlue = Color(0xFF246BFD);
  static const primaryPurple = Color(0xFF7248E8);
  static const primaryPink = Color(0xFFE83E8C);
  static const darkPrimaryCyan = Color(0xFF12D5CF);
  static const darkPrimaryTeal = Color(0xFF26E0B8);

  static const success = Color(0xFF24B875);
  static const successSoft = Color(0xFFBDF6D8);
  static const error = Color(0xFFF05E69);
  static const errorSoft = Color(0xFFFFD0D4);

  static const goodActionLight = Color(0xFF03B989);
  static const badActionLight = Color(0xFFE83C48);
  static const goodActionDark = Color(0xFF04A17A);
  static const badActionDark = Color(0xFFD23643);

  static const goodCardLight = Color(0xFFE2F3F5);
  static const goodCardBorderLight = Color(0xFF8ED2C7);
  static const badCardLight = Color(0xFFF9EAF0);
  static const badCardBorderLight = Color(0xFFD68794);

  static const goodCardDark = Color(0xFF052535);
  static const goodCardBorderDark = Color(0xFF27776E);
  static const badCardDark = Color(0xFF221C35);
  static const badCardBorderDark = Color(0xFF834759);

  static const issueCardLight = Color(0xFFFFFFFF);
  static const issueCardBorderLight = Color(0xFFE7E6F1);
  static const issueSelectedLight = Color(0xFFF6F2FF);
  static const issueSelectedBorderLight = Color(0xFF7248E8);

  static const issueCardDark = Color(0xFF071A31);
  static const issueCardBorderDark = Color(0xFF263C5B);
  static const issueSelectedDark = Color(0xFF0D2940);
  static const issueSelectedBorderDark = Color(0xFF2C75FF);

  static const progressActiveLight = Color(0xFF7048E8);
  static const progressInactiveLight = Color(0xFFD9D3F4);
  static const progressActiveDark = Color(0xFF2C75FF);
  static const progressInactiveDark = Color(0xFF32405B);
}

abstract final class AirportFeedbackGradients {
  static const lightWelcome = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5A43DB), Color(0xFF7043DD), Color(0xFFC54A93)],
    stops: [0, 0.58, 1],
  );

  static const darkWelcome = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2C56DE), Color(0xFF953A9E), Color(0xFFD74164)],
  );

  static const lightSubmit = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6941D8), Color(0xFF8748C4), Color(0xFFC54A93)],
    stops: [0, 0.68, 1],
  );

  static const darkSubmit = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF375ADD), Color(0xFF7B40BA), Color(0xFFD14072)],
  );
}
