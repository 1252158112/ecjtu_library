import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';

class AuthorCard extends StatelessWidget {
  const AuthorCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(DEFAULT_PADDING),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            '开源:https://github.com/1252158112/ecjtu_library',
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
    );
  }
}
