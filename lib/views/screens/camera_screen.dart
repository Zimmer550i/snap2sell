import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final void Function(List<File>) onSubmit;
  const CameraScreen({super.key, required this.onSubmit});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 1;
  final List<FlashMode> _flashModes = [
    FlashMode.always,
    FlashMode.off,
    FlashMode.auto,
  ];
  int _flashIndex = 0;
  final List<File> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras.last, ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  // your existing function
  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final file = await _controller!.takePicture();

    // read image bytes
    final bytes = await File(file.path).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded != null) {
      // crop to square (1:1)
      final size = decoded.width < decoded.height
          ? decoded.width
          : decoded.height;
      final x = (decoded.width - size) ~/ 2;
      final y = (decoded.height - size) ~/ 2;

      final cropped = img.copyCrop(
        decoded,
        x: x,
        y: y,
        width: size,
        height: size,
      );

      // overwrite the file with cropped version
      final croppedBytes = Uint8List.fromList(img.encodeJpg(cropped));
      final croppedFile = await File(file.path).writeAsBytes(croppedBytes);

      setState(() {
        _capturedImages.add(croppedFile);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              if (_controller != null && _controller!.value.isInitialized)
                SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  height: MediaQuery.of(context).size.width - 32,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusGeometry.vertical(
                        top: Radius.circular(16),
                      ),
                      color: const Color(0xff003846),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: OverflowBox(
                        fit: OverflowBoxFit.deferToChild,
                        maxWidth: MediaQuery.of(context).size.width - 32,
                        maxHeight:
                            (MediaQuery.of(context).size.width - 32) *
                            (_controller!.value.previewSize!.width /
                                _controller!.value.previewSize!.height),
                        child: SizedBox(
                          width: _controller!.value.previewSize!.height,
                          height: _controller!.value.previewSize!.width,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _flashIndex++;
                      if (_flashIndex >= _flashModes.length) {
                        _flashIndex = 0;
                      }
                      setState(() {
                        _controller?.setFlashMode(_flashModes[_flashIndex]);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        color: Color(0xff003846),
                      ),
                      child: Icon(
                        _flashModes[_flashIndex] == FlashMode.always
                            ? Icons.flash_on_rounded
                            : _flashModes[_flashIndex] == FlashMode.off
                            ? Icons.flash_off_rounded
                            : Icons.flash_auto_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _cameraIndex++;
                      if (_cameraIndex >= _cameras.length) {
                        _cameraIndex = 0;
                      }
                      setState(() {
                        _controller?.setDescription(_cameras[_cameraIndex]);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        color: Color(0xff003846),
                      ),
                      child: Icon(
                        Icons.cameraswitch_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Captured images list
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: _capturedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(),
                          ),
                          margin: const EdgeInsets.all(8),
                          child: Image.file(
                            _capturedImages[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Capture + Confirm/Cancel buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.onSubmit(_capturedImages);
                        Navigator.pop(context, _capturedImages);
                      },
                      child: Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xff003846),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 32),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xff003846),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Color(0xfff5f5f5),
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        widget.onSubmit(_capturedImages);
                        Navigator.pop(context, _capturedImages);
                      },
                      child: Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xff003846),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
