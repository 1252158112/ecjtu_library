import 'dart:convert';
import 'package:ecjtu_library/components/AuthorCard.dart';
import 'package:ecjtu_library/components/CardListTile.dart';
import 'package:ecjtu_library/constants.dart';
import 'package:ecjtu_library/utils/http_util.dart';
import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HttpUtil _httpUtil = Get.find();
  final StateUtil _stateUtil = Get.find();

  final FlutterShortcuts flutterShortcuts = Get.find();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool getToken = false;
  String link = '未获得';
  String cookies = '未获得';
  @override
  void initState() {
    super.initState();
  }

  void saveUserInfo() async {
    _stateUtil.setLocalForm(
      jsonEncode(
        {
          'username': usernameController.text,
          'password': passwordController.text
        },
      ),
    );
    Get.back();
  }

  void passCheck() async {
    if (loading) {
      // Get.snackbar('提示', '正在过校验');
      return;
    }
    getToken = false;
    setState(() {
      loading = true;
    });
    _httpUtil.initHeader();
    var ret = await _httpUtil.passNetworkCheck(
        usernameController.text, passwordController.text);
    if (ret[0] == '' || ret[1] == '') {
      Get.snackbar('错误', '服务器异常或账号密码错误');
    } else {
      setState(() {
        getToken = true;
        cookies = ret[0];
        link = ret[1];
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            Theme.of(context).colorScheme.inverseSurface));
    return Scaffold(
      appBar: AppBar(
        title: const Text('图书馆工具'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                print(Get.isDarkMode);
                if (Get.isDarkMode) {
                  Get.changeTheme(
                    ThemeData.light(useMaterial3: true),
                  );
                } else {
                  Get.changeTheme(
                    ThemeData.dark(useMaterial3: true),
                  );
                }

                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    systemNavigationBarColor:
                        Theme.of(context).colorScheme.inverseSurface));
              });
            },
            icon: Get.isDarkMode
                ? const Icon(Icons.dark_mode_rounded)
                : const Icon(Icons.light_mode_rounded),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed('updateInfo');
            },
            icon: const Icon(Icons.info),
          ),
          // IconButton(
          //   onPressed: () {

          //   },
          //   icon: const Icon(Icons.shortcut_rounded),
          // )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            extendedIconLabelSpacing: 10,
            extendedPadding: const EdgeInsets.all(DEFAULT_PADDING),
            heroTag: 'toWebview',
            onPressed: getToken
                ? () {
                    _stateUtil.link = link;
                    _stateUtil.cookie = cookies;
                    Get.toNamed('/webview');
                  }
                : null,
            label: const Icon(
              Icons.arrow_forward_ios_rounded,
            ),
            icon: const Text(
              '座位预约',
              style: TextStyle(fontSize: 17),
            ),
          ),
          const SizedBox(
            height: DEFAULT_PADDING,
          ),
          FloatingActionButton.extended(
            extendedIconLabelSpacing: 10,
            extendedPadding: const EdgeInsets.all(DEFAULT_PADDING),
            onPressed: loading || !_stateUtil.hasLoginForm()
                ? null
                : () {
                    Get.toNamed('/scan');
                  },
            label: const Icon(Icons.qr_code_2_rounded),
            icon: const Text(
              '签到',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(children: [
          Expanded(
            child: Row(
              children: [
                TextButton.icon(
                    onPressed: () {
                      Get.defaultDialog(
                        title: '智慧交大',
                        onCancel: Get.back,
                        onConfirm: saveUserInfo,
                        content: Padding(
                          padding: const EdgeInsets.fromLTRB(DEFAULT_PADDING, 0,
                              DEFAULT_PADDING, DEFAULT_PADDING),
                          child: Column(
                            children: [
                              TextField(
                                controller: usernameController,
                                autofocus: true,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  labelText: "账号",
                                  hintText: "你的智慧交大账号",
                                  prefixIcon:
                                      Icon(Icons.account_circle_rounded),
                                ),
                              ),
                              TextField(
                                controller: passwordController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: "密码",
                                  hintText: "你的智慧交大密码",
                                  prefixIcon: Icon(Icons.password_rounded),
                                ),
                                onSubmitted: (a) {
                                  saveUserInfo();
                                },
                              ),
                              const SizedBox(
                                height: DEFAULT_PADDING,
                              ),
                              const Text('应用仅会将信息保存至本地，不会上传至任何第三方'),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('登录')),
              ],
            ),
          ),
          const SizedBox(
            height: DEFAULT_PADDING / 2,
          ),
          FilledButton.icon(
              onPressed:
                  loading || !_stateUtil.hasLoginForm() ? null : passCheck,
              icon: const Icon(Icons.insert_page_break_rounded),
              label: const Text('过校验'))
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DEFAULT_PADDING / 2),
        child: ListView(
          children: [
            const AuthorCard(),
            const SizedBox(
              height: DEFAULT_PADDING,
            ),
            Obx(() {
              if (_stateUtil.hasLoginForm()) {
                usernameController.text = _stateUtil.loginForm['username'];
                passwordController.text = _stateUtil.loginForm['password'];
                if (!getToken) {
                  Future.delayed(const Duration(milliseconds: 500)).then(
                    (value) {
                      passCheck();
                    },
                  );
                }
              }

              return CardListTile(
                '获得智慧交大密码',
                mode: _stateUtil.hasLoginForm() ? 1 : 0,
              );
            }),
            Obx(
              () => CardListTile(
                '通过校园网网关认证',
                mode: _httpUtil.passNetCheck(),
              ),
            ),
            // Obx(
            //   () => CardListTile(
            //     '通过智慧交大认证',
            //     mode: _httpUtil.passCasCheck(),
            //   ),
            // ),
            Obx(
              () => CardListTile(
                '获得图书馆身份认证token',
                mode: _httpUtil.getLibToken(),
              ),
            ),
            const SizedBox(
              height: DEFAULT_PADDING,
            ),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(DEFAULT_PADDING),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '链接',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        link,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: DEFAULT_PADDING / 2,
                      ),
                      Text(
                        'COOKIE',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        cookies,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
