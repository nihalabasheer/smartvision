import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const DetectionScreen({required this.cameras, Key? key}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen>
    with WidgetsBindingObserver {
  /* ---------- CONFIG ---------- */
  static const Set<String> dangerousClasses = {
    'person',
    'car',
    'bus',
    'truck',
    'motorcycle',
    'bicycle',
    'bench',
    'chair',
    'tree',
    'wall',
  };

  bool _isClose(Map r) =>
      (r['rect']['w'] as double) * (r['rect']['h'] as double) > 0.20;

  String _direction(Map r) {
    final centerX =
        (r['rect']['x'] as double) + (r['rect']['w'] as double) / 2;
    if (centerX < 0.33) return 'left';
    if (centerX > 0.66) return 'right';
    return 'front';
  }

  /* ---------- STATE ----------- */
  late CameraController _controller;
  final FlutterTts _tts = FlutterTts();

  bool _modelLoaded = false, _isCameraInitialized = false;
  bool _isDetecting = false, _isDisposed = false;

  String? _lastClass;
  double? _lastBoxArea;
  DateTime _lastSpokenAt = DateTime.fromMillisecondsSinceEpoch(0);

  /* ---------- INIT ------------ */
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadModel().then((_) => _initCamera());
  }

  /* ---------- MODEL ----------- */
  Future<void> _loadModel() async {
    final res = await Tflite.loadModel(
      model: 'assets/models/model.tflite',
      labels: 'assets/models/labels.txt',
    );
    print('📦 Model load: $res');
    if (res == 'success' && mounted) setState(() => _modelLoaded = true);
  }

  /* ---------- CAMERA ---------- */
  void _initCamera() {
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: false,
    );

    _controller.initialize().then((_) async {
      if (_isDisposed || !mounted) return;
      setState(() => _isCameraInitialized = true);
      print('🎥 Stream start');
      await _controller.startImageStream(_onFrame);
    }).catchError((e) => print('❌ Camera init error: $e'));
  }

  /* ---------- FRAME ----------- */
  Future<void> _onFrame(CameraImage img) async {
    if (!_modelLoaded || _isDetecting || _isDisposed) return;
    _isDetecting = true;

    try {
      final recs = await Tflite.detectObjectOnFrame(
        bytesList: img.planes.map((p) => p.bytes).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        rotation: 90,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.7,
        numResultsPerClass: 3,
      );
      if (recs != null) _handle(recs);
    } catch (e, st) {
      print('❌ Detect error: $e\n$st');
    } finally {
      _isDetecting = false;
    }
  }

  /* ------ FILTER & SPEAK ------ */
  void _handle(List recs) {
    for (final r in recs) {
      final cls = (r['detectedClass'] as String).toLowerCase();
      if (!dangerousClasses.contains(cls)) continue;
      if (!_isClose(r)) continue;

      // area & direction
      final area = (r['rect']['w'] as double) * (r['rect']['h'] as double);
      final dir = _direction(r);
      final msg = dir == 'front' ? '$cls ahead, move aside' : '$cls on your $dir';

      final now = DateTime.now();
      final bool closer = _lastBoxArea != null && area > _lastBoxArea! * 1.15;
      final bool cooldown = now.difference(_lastSpokenAt).inSeconds > 2;

      if ((cls != _lastClass || closer) && cooldown) {
        _tts.speak(msg);
        print('🔊 $msg');
        _lastClass = cls;
        _lastBoxArea = area;
        _lastSpokenAt = now;
      } else {
        // update area for same class to keep tracking
        if (cls == _lastClass) _lastBoxArea = area;
      }
    }
  }

  /* ------ LIFECYCLE ---------- */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.stopImageStream();
    } else if (state == AppLifecycleState.resumed && !_isDisposed) {
      _initCamera();
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    if (_controller.value.isStreamingImages) {
      await _controller.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await _controller.dispose();
    await Tflite.close();
    await _tts.stop();
    super.dispose();
  }

  /* ---------- UI ------------- */
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detection')),
    body: _isCameraInitialized
        ? CameraPreview(_controller)
        : const Center(child: CircularProgressIndicator()),
  );
}
