import 'package:dynamic_color/dynamic_color.dart';
import 'package:ecjtu_library/pages/ScanPage.dart';
import 'package:ecjtu_library/pages/SignSeatPage.dart';
import 'package:ecjtu_library/pages/WebviewPage.dart';
import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:ui' as ui;
import 'constants.dart';
import 'pages/HomePage.dart';
import 'utils/http_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(HttpUtil());
    Get.put(StateUtil());
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return GetMaterialApp(
          locale: ui.window.locale,
          title: '华交图书馆工具',
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const HomePage(),
            ),
            GetPage(
              name: '/webview',
              page: () => const WebviewPage(),
            ),
            GetPage(
              name: '/scan',
              page: () => ScanPage(),
            ),
            GetPage(
              name: '/signSeat',
              page: () => SignSeatPage(),
            ),
          ],
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.system,
          theme: ThemeData(
              colorSchemeSeed: lightDynamic?.primary ?? SEED,
              scaffoldBackgroundColor: ColorScheme.fromSeed(
                seedColor: lightDynamic?.primary ?? SEED,
              ).onInverseSurface,
              appBarTheme: AppBarTheme(
                backgroundColor: ColorScheme.fromSeed(
                  seedColor: lightDynamic?.primary ?? SEED,
                ).onInverseSurface,
              ),
              useMaterial3: true),
          home: const HomePage(),
        );
      },
    );
  }
}
