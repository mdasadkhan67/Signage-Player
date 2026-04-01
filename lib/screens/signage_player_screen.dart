import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../helpers/app_constants.dart';
import '../models/media_item.dart';
import '../services/content_service.dart';
import '../utils/app_logger.dart';
import '../widgets/image_player.dart';
import '../widgets/video_player_widget.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlaylist();
  }

  Future<void> _initializePlaylist() async {
    final data = await ContentService.loadContent();

    _mediaList.addAll(data);

    if (_mediaList.isNotEmpty) {
      await _loadCurrentMedia();
      _startLoopTimer();
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _startLoopTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.displayDurationSeconds),
      (_) => _nextMedia(),
    );
  }

  Future<void> _nextMedia() async {
    if (_mediaList.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _mediaList.length;
    await _loadCurrentMedia();
  }

  Future<void> _loadCurrentMedia() async {
    final item = _mediaList[_currentIndex];

    await _videoController?.dispose();
    _videoController = null;

    if (item.type == 'video') {
      try {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(item.url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );

        await controller.initialize();
        await controller.setVolume(0);
        await controller.play();

        _videoController = controller;
      } catch (e) {
        AppLogger.log('Video load error: $e');
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_mediaList.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No content found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final item = _mediaList[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox.expand(
          child: item.type == 'image'
              ? ImagePlayer(url: item.url)
              : _videoController != null
              ? VideoPlayerWidget(controller: _videoController!)
              : const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
