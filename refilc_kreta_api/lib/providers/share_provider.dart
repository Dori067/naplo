import 'package:refilc/api/client.dart';
import 'package:refilc/api/providers/user_provider.dart';
import 'package:refilc/models/settings.dart';
import 'package:refilc/models/shared_theme.dart';
// import 'package:refilc/models/shared_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ShareProvider extends ChangeNotifier {
  final UserProvider _user;

  ShareProvider({
    required UserProvider user,
  }) : _user = user;

  // Future<void> shareTheme({required SharedTheme theme}) async {

  // }

  // themes
  Future<(SharedTheme?, int)> shareCurrentTheme(
    BuildContext context, {
    bool isPublic = false,
    bool shareNick = true,
    required SharedGradeColors gradeColors,
    String displayName = '',
  }) async {
    final SettingsProvider settings =
        Provider.of<SettingsProvider>(context, listen: false);

    Map themeJson = {
      'public_id': const Uuid().v4(),
      'is_public': isPublic,
      'nickname': shareNick ? _user.nickname : 'Anonymous',
      'display_name': displayName,
      'background_color': (settings.customBackgroundColor ??
              SettingsProvider.defaultSettings().customBackgroundColor)
          ?.value,
      'panels_color': (settings.customHighlightColor ??
              SettingsProvider.defaultSettings().customHighlightColor)
          ?.value,
      'accent_color': (settings.customAccentColor ??
                  SettingsProvider.defaultSettings().customAccentColor)
              ?.value ??
          const Color(0xFF3D7BF4).value,
      'icon_color': (settings.customIconColor ??
                  SettingsProvider.defaultSettings().customIconColor)
              ?.value ??
          const Color(0x00000000).value,
      'shadow_effect': settings.shadowEffect,
      'theme_mode': settings.theme == ThemeMode.dark
          ? 'dark'
          : (settings.theme == ThemeMode.light ? 'light' : null),
      'font_family': settings.fontFamily,
    };

    SharedTheme theme = SharedTheme.fromJson(themeJson, gradeColors);
    int shareResult = await FilcAPI.addSharedTheme(theme);

    if (shareResult == 201) {
      return (theme, 201);
    } else {
      return (null, shareResult);
    }
  }

  Future<SharedTheme?> getThemeById(BuildContext context,
      {required String id}) async {
    Map? themeJson = await FilcAPI.getSharedTheme(id);

    if (themeJson != null) {
      Map? gradeColorsJson =
          await FilcAPI.getSharedGradeColors(themeJson['grade_colors_id']);

      if (gradeColorsJson != null) {
        SharedTheme theme = SharedTheme.fromJson(
          themeJson,
          SharedGradeColors.fromJson(gradeColorsJson["public_id"] != ''
              ? gradeColorsJson
              : {
                  "public_id": "0",
                  "is_public": false,
                  "nickname": "Anonymous",
                  "five_color":
                      SettingsProvider.defaultSettings().gradeColors[4].value,
                  "four_color":
                      SettingsProvider.defaultSettings().gradeColors[3].value,
                  "three_color":
                      SettingsProvider.defaultSettings().gradeColors[2].value,
                  "two_color":
                      SettingsProvider.defaultSettings().gradeColors[1].value,
                  "one_color":
                      SettingsProvider.defaultSettings().gradeColors[0].value,
                }),
        );
        return theme;
      }
    }

    return null;
  }

  Future<List<SharedTheme>> getAllPublicThemes(BuildContext context,
      {int count = 0}) async {
    List? themesJson = await FilcAPI.getAllSharedThemes(count);

    List<SharedTheme> themes = [];

    if (themesJson != null) {
      for (var t in themesJson) {
        if (t['public_id'].toString().replaceAll(' ', '') == '') continue;
        if (t['grade_colors_id'].toString().replaceAll(' ', '') == '') continue;

        Map? gradeColorsJson =
            await FilcAPI.getSharedGradeColors(t['grade_colors_id']);

        if (gradeColorsJson != null) {
          SharedTheme theme = SharedTheme.fromJson(
            t,
            SharedGradeColors.fromJson(gradeColorsJson["public_id"] != ''
                ? gradeColorsJson
                : {
                    "public_id": "0",
                    "is_public": false,
                    "nickname": "Anonymous",
                    "five_color":
                        SettingsProvider.defaultSettings().gradeColors[4].value,
                    "four_color":
                        SettingsProvider.defaultSettings().gradeColors[3].value,
                    "three_color":
                        SettingsProvider.defaultSettings().gradeColors[2].value,
                    "two_color":
                        SettingsProvider.defaultSettings().gradeColors[1].value,
                    "one_color":
                        SettingsProvider.defaultSettings().gradeColors[0].value,
                  }),
          );

          themes.add(theme);
        }
      }
    }

    return themes;
  }

  // grade colors
  Future<(SharedGradeColors?, int)> shareCurrentGradeColors(
    BuildContext context, {
    bool isPublic = false,
    bool shareNick = true,
  }) async {
    final SettingsProvider settings =
        Provider.of<SettingsProvider>(context, listen: false);

    Map gradeColorsJson = {
      'public_id': const Uuid().v4(),
      'is_public': isPublic,
      'nickname': shareNick ? _user.nickname : 'Anonymous',
      'five_color': settings.gradeColors[4].value,
      'four_color': settings.gradeColors[3].value,
      'three_color': settings.gradeColors[2].value,
      'two_color': settings.gradeColors[1].value,
      'one_color': settings.gradeColors[0].value,
    };

    SharedGradeColors gradeColors = SharedGradeColors.fromJson(gradeColorsJson);
    int shareResult = await FilcAPI.addSharedGradeColors(gradeColors);

    if (shareResult == 201) {
      return (gradeColors, 201);
    } else {
      return (null, shareResult);
    }
  }

  Future<SharedGradeColors?> getGradeColorsById(BuildContext context,
      {required String id}) async {
    Map? gradeColorsJson = await FilcAPI.getSharedGradeColors(id);

    if (gradeColorsJson != null) {
      SharedGradeColors gradeColors = SharedGradeColors.fromJson(
        gradeColorsJson["public_id"] != ''
            ? gradeColorsJson
            : {
                "public_id": "0",
                "is_public": false,
                "nickname": "Anonymous",
                "five_color":
                    SettingsProvider.defaultSettings().gradeColors[4].value,
                "four_color":
                    SettingsProvider.defaultSettings().gradeColors[3].value,
                "three_color":
                    SettingsProvider.defaultSettings().gradeColors[2].value,
                "two_color":
                    SettingsProvider.defaultSettings().gradeColors[1].value,
                "one_color":
                    SettingsProvider.defaultSettings().gradeColors[0].value,
              },
      );
      return gradeColors;
    }

    return null;
  }
}
