import 'dart:typed_data';

import 'package:ecjtu_library/constants.dart';
import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shortcuts/flutter_shortcuts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final StateUtil _stateUtil = Get.find();
  final FlutterShortcuts flutterShortcuts = Get.find();
  bool isGet = false;
  final TextEditingController textController = TextEditingController();
  MobileScannerController cameraController = MobileScannerController();
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void jump(String link) {
    _stateUtil.signLink = link;
    Get.toNamed('/signSeat');
  }

  @override
  Widget build(BuildContext context) {
    List<ActionChip> chips = [];
    for (var i in _stateUtil.likeSeat) {
      chips.add(
        ActionChip(
          avatar: const Icon(Icons.chair_rounded),
          label: Text(
            i['info'],
          ),
          onPressed: () {
            flutterShortcuts.updateShortcutItem(
              shortcut: ShortcutItem(
                id: "2",
                action: 'toSignSeat@@@${i["link"]}',
                shortLabel: '收藏座位${i["info"]}',
                icon: 'assets/icons/bag.png',
              ),
            );
            jump(i['link']);
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return Icon(Icons.flash_off_rounded,
                        color: Theme.of(context).colorScheme.primary);
                  case TorchState.on:
                    return Icon(Icons.flash_on_rounded,
                        color: Theme.of(context).colorScheme.tertiary);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front_rounded);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear_rounded);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton.extended(
          onPressed: () async {
            final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              cameraController.analyzeImage(pickedFile.path);
            }
          },
          icon: const Icon(Icons.image_rounded),
          label: const Text(
            '本地图片',
            style: TextStyle(fontSize: 17),
          ),
        ),
        const SizedBox(
          height: DEFAULT_PADDING,
        ),
        FloatingActionButton.extended(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          heroTag: 'likeSeat',
          onPressed: () async {
            Get.defaultDialog(
                title: '收藏座位',
                content: Hero(
                  tag: 'likeSeat',
                  child: Wrap(
                    spacing: DEFAULT_PADDING / 2, //水平间距
                    runSpacing: DEFAULT_PADDING / 2, //垂直间距
                    // direction: Axis.vertical,
                    alignment: WrapAlignment.start,
                    // crossAxisAlignment: WrapCrossAlignment.start,
                    children: chips,
                  ),
                ));
          },
          icon: const Icon(Icons.chair_rounded),
          label: const Text(
            '收藏座位',
            style: TextStyle(fontSize: 17),
          ),
        ),
      ]),
      body: Stack(
        children: [
          MobileScanner(
            // fit: BoxFit.contain,
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (isGet) return;
              setState(() {
                isGet = true;
                cameraController.stop();
              });

              for (final barcode in barcodes) {
                Get.defaultDialog(
                  title: '结果',
                  middleText: barcode.rawValue ?? '',
                  confirm: TextButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Get.back();
                      jump(barcode.rawValue ?? '');
                    },
                  ),
                  cancel: TextButton(
                    child: const Text('收藏'),
                    onPressed: () {
                      Get.defaultDialog(
                          title: '备注',
                          content: TextField(
                            controller: textController,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: "备注信息",
                              hintText: "备注名称",
                              prefixIcon: Icon(Icons.info_rounded),
                            ),
                          ),
                          onConfirm: () {
                            flutterShortcuts.updateShortcutItem(
                              shortcut: ShortcutItem(
                                id: "2",
                                action:
                                    'toSignSeat@@@${barcode.rawValue ?? ''}',
                                shortLabel: '收藏座位${textController.text}',
                                icon: 'assets/icons/bag.png',
                              ),
                            );
                            _stateUtil.likeSeat.add({
                              'info': textController.text,
                              'link': barcode.rawValue ?? ''
                            });
                            _stateUtil.setLikeSeat();
                            Get.back();
                            Get.back();
                            Get.toNamed('/signSeat');
                          });
                      _stateUtil.signLink = barcode.rawValue ?? '';
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
