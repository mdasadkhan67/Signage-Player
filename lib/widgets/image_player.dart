import 'package:flutter/material.dart';

class ImagePlayer extends StatelessWidget {
  final String url;

  const ImagePlayer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Image.network(
            url,
            fit: BoxFit.cover,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            errorBuilder: (context, _, _) => const Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
