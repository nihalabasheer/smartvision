import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

class DetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const DetectionScreen({required this.cameras, Key? key}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  late CameraController _controller;
  bool _isDetecting = false;
  bool _modelLoaded = false;
  bool _isCameraInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadModel().then((_) => _initializeCamera());
  }

  Future<void> _loadModel() async {
    print("🔄 Starting model load...");
    try {
      final res = await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
      );
      print("📦 Model load result: $res");
      if (res == "success") {
        if (!_isDisposed && mounted) {
          setState(() => _modelLoaded = true);
        }
      } else {
        print("❌ Model load failed: $res");
      }
    } catch (e) {
      print("❌ Exception while loading model: $e");
    }
  }

  void _initializeCamera() {
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );

    _controller.initialize().then((_) async {
      if (_isDisposed || !mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });

      print("🎥 Image stream starting...");
      try {
        await _controller.startImageStream(_processCameraImage);
      } catch (e) {
        print("❌ Error starting image stream: $e");
      }
    }).catchError((e) {
      print("❌ Camera initialization error: $e");
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!_modelLoaded || !_isCameraInitialized || _isDisposed) {
      print("⚠ Model, camera not ready or disposed, skipping frame.");
      return;
    }
    if (_isDetecting) {
      return;
    }

    _isDetecting = true;

    try {
      final recognitions = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((p) => p.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        rotation: 90, // Adjust based on device orientation
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5,
        numResultsPerClass: 3,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        print("🔍 Detected objects:");
        for (var r in recognitions) {
          print(
              ' • ${r['detectedClass']} - ${(r['confidenceInClass'] * 100).toStringAsFixed(1)}%');
        }
      } else {
        print("🤷 No objects detected");
      }
    } catch (e, st) {
      print("❌ Detection error: $e\n$st");
    } finally {
      _isDetecting = false;
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;

    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
      // Small delay to ensure stream is fully stopped before disposing
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await _controller.dispose();

    await Tflite.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detection', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        toolbarHeight: 90,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C0E47), Color(0xFF3A4D8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isCameraInitialized
          ? CameraPreview(_controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
