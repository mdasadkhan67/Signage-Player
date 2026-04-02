import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../helpers/app_constants.dart';
import '../models/media_item.dart';
import '../services/content_service.dart';
import '../utils/app_logger.dart';
import '../widgets/fallback_widget.dart';
import '../widgets/image_player.dart';
import '../widgets/video_player_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SignagePlayerScreen extends StatefulWidget {
  const SignagePlayerScreen({super.key});

  @override
  State<SignagePlayerScreen> createState() => _SignagePlayerScreenState();
}

class _SignagePlayerScreenState extends State<SignagePlayerScreen> {
  final List<MediaItem> _mediaList = [];

  int _currentIndex = 0;

  Timer? _timer;

  VideoPlayerController? _videoController;
  VideoPlayerController? _nextVideoController;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isOffline = false;


  late final StreamSubscription<List<ConnectivityResult>> _connectionSub;

  @override
  void initState() {
    super.initState();
    _listenInternet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlaylist();
    });
  }

  void _listenInternet() {
    _connectionSub = Connectivity().onConnectivityChanged.listen((results) async {
      if (!mounted) return;
      final hasInternet = results.any((r) => r != ConnectivityResult.none);
      if (hasInternet == !_isOffline) return;

      if (!hasInternet) {
        setState(() {
          _isOffline = true;
        });
        return;
      }

      setState(() {
        _isOffline = false;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      await _restartFromBeginning();
    });
  }



  Future<void> _restartFromBeginning() async {
    _timer?.cancel();

    final oldController = _videoController;
    final oldNextController = _nextVideoController;

    _videoController = null;
    _nextVideoController = null;

    oldController?.dispose();
    oldNextController?.dispose();

    _mediaList.clear();
    _currentIndex = 0;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await _initializePlaylist();
  }

  Future<void> _initializePlaylist() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      final data = await ContentService.loadContent();

      if (!mounted) return;

      _mediaList.clear();
      _mediaList.addAll(data);

      if (_mediaList.isEmpty) {
        _hasError = true;
      } else {
        await _loadCurrentMedia();
            _startLoopTimer();
      await  _preloadNextMedia();
      }
    } catch (e) {
      _hasError = true;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _preloadNextMedia() async {
    if (_mediaList.isEmpty || !mounted) return;

    final nextIndex = (_currentIndex + 1) % _mediaList.length;
    final item = _mediaList[nextIndex];

    final oldNextController = _nextVideoController;
    _nextVideoController = null;

    try {
      if (item.type == 'video') {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(item.url),
        );

        await controller.initialize().timeout(const Duration(seconds: 5));

        if (!mounted) {
          controller.dispose();
          return;
        }

        await controller.setVolume(0);
        await controller.setLooping(true);

        _nextVideoController = controller;
      }

      if (item.type == 'image') {
        try {
          await precacheImage(NetworkImage(item.url), context);
        } catch (e) {
          AppLogger.log('Image preload error: $e');
        }
      }
    } catch (e) {
      AppLogger.log('Preload failed, skipping media: $e');
      _nextVideoController = null;
    }

    oldNextController?.dispose();
  }

  void _startLoopTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.displayDurationSeconds),
          (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_isOffline) return;

        try {
          await _nextMedia();
        } catch (e) {
          AppLogger.log('Loop error: $e');
        }
      },
    );
  }

  void _skipToNext() {
    if (_mediaList.isEmpty) return;

    final oldController = _videoController;
    _videoController = null;

    _currentIndex = (_currentIndex + 1) % _mediaList.length;

    _preloadNextMedia();

    oldController?.dispose();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _nextMedia() async {
    if (_mediaList.isEmpty) return;

    final nextIndex = (_currentIndex + 1) % _mediaList.length;
    final nextItem = _mediaList[nextIndex];

    final oldController = _videoController;

    _currentIndex = nextIndex;

    if (nextItem.type == 'video') {
      if (_nextVideoController != null &&
          _nextVideoController!.value.isInitialized) {

        /// ✅ INSTANT SWITCH (BEST CASE)
        final newController = _nextVideoController!;
        _nextVideoController = null;

        await newController.play();
        _videoController = newController;

      } else {
        await Future.delayed(const Duration(milliseconds: 300));

        if (_nextVideoController != null &&
            _nextVideoController!.value.isInitialized) {

          final newController = _nextVideoController!;
          _nextVideoController = null;

          await newController.play();
          _videoController = newController;

        } else {
          await _loadCurrentMedia();
        }
      }
    }

    oldController?.dispose();


    _preloadNextMedia();

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadCurrentMedia() async {
    if (_mediaList.isEmpty) return;

    final item = _mediaList[_currentIndex];

    final oldController = _videoController;
    _videoController = null;

    try {
      if (item.type == 'video') {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(item.url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        await controller.initialize().timeout(const Duration(seconds: 5));

        if (!mounted) {
          controller.dispose();
          return;
        }

        await controller.setVolume(0);
        await controller.setLooping(true);
        await controller.play();

        _videoController = controller;
      }
    } catch (e) {
      AppLogger.log('Video failed, skipping: $e');

      _videoController?.dispose();
      _videoController = null;

      _skipToNext();
      return;
    }

    oldController?.dispose();

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    try {
      _connectionSub.cancel();
    } catch (_) {}

    _timer?.cancel();

    _videoController?.dispose();
    _nextVideoController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_isOffline) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: buildFallback(
          context,
          onRetry: () async {
            final result = await Connectivity().checkConnectivity();

            if (result == ConnectivityResult.none) return;

            await _restartFromBeginning();
          },
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Loading...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_hasError || _mediaList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: buildFallback(context),
      );
    }

    final item = _mediaList[_currentIndex];

    Widget content;

    if (item.type == 'image') {
      content = ImagePlayer(url: item.url);

    } else if (_videoController != null &&
        _videoController!.value.isInitialized) {

      content = VideoPlayerWidget(controller: _videoController!);

    } else {
      content = const Center(
        child: Text(
          "Loading...",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox.expand(child: content),
      ),
    );
  }
}
