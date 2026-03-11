import 'package:flutter/material.dart';

class GdImageZoomPage extends StatelessWidget {
  final String? imageUrl;
  final String? title;

  const GdImageZoomPage({
    super.key,
     this.imageUrl,
     this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5,
            child: Image.network(
              imageUrl!,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}