import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_pro/core/utils/extensions.dart';

import '../constants/app_colors.dart';
import '../constants/app_defaults.dart';

class AppTheme {
  /// Add your custom font name here, which you added in [pubspec.yaml] file
  static const fontName = 'Montserrat';

  /// A light theme for NewsPro
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textTheme: ThemeData.light().textTheme.apply(fontFamily: fontName),
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        cardColor: AppColors.cardColor,
        canvasColor: AppColors.cardColor,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDefaults.borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDefaults.borderRadius,
            borderSide: const BorderSide(
              color: AppColors.primary,
            ),
          ),
          fillColor: AppColors.cardColor,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: fontName,
          ),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(AppDefaults.padding),
            shape: RoundedRectangleBorder(
              borderRadius: AppDefaults.borderRadius,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.all(AppDefaults.padding),
            shape: RoundedRectangleBorder(
              borderRadius: AppDefaults.borderRadius,
            ),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          dividerColor: AppColors.separator,
          labelPadding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 1.15,
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.cardColorDark.withOpacityValue(0.5),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontFamily: fontName,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontFamily: fontName),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        checkboxTheme: const CheckboxThemeData(
          side: BorderSide(
            color: AppColors.scaffoldBackgrounDark,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.black12,
        ),
      );

  /// A dark theme for NewsPro
  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary, brightness: Brightness.dark),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: fontName,
              displayColor: Colors.white,
              bodyColor: Colors.white,
            ),
        cardColor: AppColors.cardColorDark,
        scaffoldBackgroundColor: AppColors.scaffoldBackgrounDark,
        canvasColor: AppColors.cardColorDark,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDefaults.borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDefaults.borderRadius,
            borderSide: const BorderSide(
              color: AppColors.primary,
            ),
          ),
          fillColor: AppColors.cardColorDark,
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: const TextStyle(color: AppColors.placeholder),
          iconColor: AppColors.placeholder,
          hintStyle: const TextStyle(color: AppColors.placeholder),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        listTileTheme: const ListTileThemeData(
            iconColor: AppColors.primary, textColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBackgrounDark,
          elevation: 0,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          // systemOverlayStyle: SystemUiOverlayStyle(
          //   statusBarBrightness: Brightness.dark,
          //   statusBarIconBrightness: Brightness.light,
          //   systemNavigationBarColor: AppColors.scaffoldBackgrounDark,
          //   statusBarColor: AppColors.scaffoldBackgrounDark,
          // ),
          systemOverlayStyle: SystemUiOverlayStyle.light,

          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: fontName,
          ),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(AppDefaults.padding),
            shape: RoundedRectangleBorder(
              borderRadius: AppDefaults.borderRadius,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.all(AppDefaults.padding),
            shape: RoundedRectangleBorder(
              borderRadius: AppDefaults.borderRadius,
            ),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 1.15,
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.cardColor.withOpacityValue(0.5),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontFamily: fontName,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontFamily: fontName),
          dividerColor: AppColors.cardColorDark,
        ),
        checkboxTheme: const CheckboxThemeData(
          side: BorderSide(
            color: AppColors.scaffoldBackground,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.black12,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: fontName,
            ),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: AppColors.cardColorDark),
      );
}
