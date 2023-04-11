import 'dart:typed_data';

import 'package:ecjtu_library/utils/state_util.dart';
import 'package:flutter/material.dart';
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
  bool isGet = false;

  MobileScannerController cameraController = MobileScannerController();
  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pickedFile =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            cameraController.analyzeImage(pickedFile.path);
          }
        },
        child: const Icon(Icons.image_rounded),
      ),
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
                  onConfirm: () {
                    _stateUtil.signLink = barcode.rawValue ?? '';
                    Get.toNamed('/signSeat');
                  },
                  onCancel: () => setState(
                    () {
                      isGet = false;
                      cameraController.start();
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
