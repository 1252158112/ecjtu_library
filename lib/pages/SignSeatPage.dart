import 'dart:convert';
import 'dart:math';

import 'package:ecjtu_library/components/CardListTile.dart';
import 'package:ecjtu_library/constants.dart';
import 'package:ecjtu_library/utils/http_util.dart';
import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../components/AuthorCard.dart';

class SignSeatPage extends StatefulWidget {
  const SignSeatPage({super.key});

  @override
  State<SignSeatPage> createState() => _SignSeatPageState();
}

class _SignSeatPageState extends State<SignSeatPage> {
  final HttpUtil _httpUtil = Get.find();
  final StateUtil _stateUtil = Get.find();
  bool loading = false;
  bool getToken = false;
  String username = '';
  String password = '';
  String link = '未获得';
  String cookies = '未获得';
  String signLink = '';
  @override
  void initState() {
    super.initState();
    signLink = _stateUtil.signLink;
    _stateUtil.signLink = '';
  }

  void passCheck() async {
    setState(() {
      getToken = false;
      loading = true;
    });

    var ret = await _httpUtil.passSeatCheck(username, password, signLink);
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
        title: const Text('座位签到'),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
          label: loading
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
          icon: loading
              ? const Text(
                  '正在加载',
                  style: TextStyle(fontSize: 17),
                )
              : const Text(
                  '前往签到',
                  style: TextStyle(fontSize: 17),
                )),
      // bottomNavigationBar: BottomAppBar(
      //   child: Row(children: [
      //     Expanded(
      //       child: Row(
      //         children: [
      //           // FilledButton.icon(
      //           //     onPressed: loading ? null : passCheck,
      //           //     icon: const Icon(Icons.insert_page_break_rounded),
      //           //     label: const Text('过校验'))
      //         ],
      //       ),
      //     ),
      //     const SizedBox(
      //       height: DEFAULT_PADDING / 2,
      //     ),
      //     FilledButton.icon(
      //         onPressed: loading ? null : passCheck,
      //         icon: const Icon(Icons.insert_page_break_rounded),
      //         label: const Text('过校验'))
      //   ]),
      // ),
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
                username = _stateUtil.loginForm['username'];
                password = _stateUtil.loginForm['password'];
                if (!getToken && !loading) {
                  Future.delayed(const Duration(milliseconds: 500)).then(
                    (value) {
                      passCheck();
                    },
                  );
                }
              }

              return CardListTile(
                '获得座位链接',
                mode: signLink != '' ? 1 : 0,
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
