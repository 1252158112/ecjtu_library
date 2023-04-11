import 'dart:convert';
import 'dart:math';

import 'package:ecjtu_library/components/CardListTile.dart';
import 'package:ecjtu_library/constants.dart';
import 'package:ecjtu_library/utils/http_util.dart';
import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HttpUtil _httpUtil = Get.find();
  final StateUtil _stateUtil = Get.find();
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
      Get.snackbar('提示', '正在过校验');
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
                  Get.changeTheme(
                    Get.isDarkMode
                        ? ThemeData.light(useMaterial3: true)
                        : ThemeData.dark(useMaterial3: true),
                  );

                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      systemNavigationBarColor:
                          Theme.of(context).colorScheme.inverseSurface));
                });
              },
              icon: Get.isDarkMode
                  ? const Icon(Icons.dark_mode_rounded)
                  : const Icon(Icons.light_mode_rounded))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          extendedIconLabelSpacing: 10,
          extendedPadding: const EdgeInsets.all(DEFAULT_PADDING),
          heroTag: 'toWebview',
          onPressed: getToken
              ? () {
                  _stateUtil.link = link;
                  _stateUtil.cookie = cookies;

                  Get.snackbar('提示', '由于安全权限问题，首次进入需要手动登录智慧交大');
                  Get.toNamed('/webview');
                }
              : null,
          label: const Icon(
            Icons.arrow_forward_ios_rounded,
          ),
          icon: const Text(
            '进入图书馆',
            style: TextStyle(fontSize: 17),
          )),
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
                FilledButton.icon(
                    onPressed: loading ? null : passCheck,
                    icon: const Icon(Icons.insert_page_break_rounded),
                    label: const Text('过校验'))
              ],
            ),
          ),
          const SizedBox(
            height: DEFAULT_PADDING / 2,
          ),
          FilledButton.icon(
              onPressed: loading
                  ? null
                  : () {
                      Get.toNamed('/scan');
                    },
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('扫描座位'))
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DEFAULT_PADDING / 2),
        child: ListView(
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(DEFAULT_PADDING),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '开发者',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'lejw@软件工程',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: DEFAULT_PADDING / 2,
                      ),
                      Text(
                        '联系我',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '邮箱:mail.to.lejw@qq.com',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'github:https://github.com/1252158112',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: DEFAULT_PADDING / 2,
                      ),
                      Text(
                        '本工具仅供跳过校园网验证，任何数据仅存储在本地，任何数据都不会分享给第三方或任何服务器',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ]),
              ),
            ),

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
