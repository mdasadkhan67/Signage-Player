import 'dart:async';
import 'package:flutter/material.dart';

class ImagePlayer extends StatefulWidget {
  final String url;

  const ImagePlayer({super.key, required this.url});

  @override
  State<ImagePlayer> createState() => _ImagePlayerState();
}

class _ImagePlayerState extends State<ImagePlayer> {
  bool _hasError = false;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();

    _timeout = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox.shrink();
    }

    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      gaplessPlayback: true,

      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          _timeout?.cancel();
          return child;
        }

        return const SizedBox.shrink();
      },

      errorBuilder: (context, _, _) {
        _timeout?.cancel();
        return const SizedBox.shrink();
      },
    );
  }
}