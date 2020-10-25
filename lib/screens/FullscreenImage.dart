import 'package:flutter/material.dart';

class FullscreenImage extends StatefulWidget {
  final String imageUrl;

  const FullscreenImage({Key key, @required this.imageUrl}) : super(key: key);
  @override
  _FullscreenImageState createState() => _FullscreenImageState();
}

class _FullscreenImageState extends State<FullscreenImage> {
  @override
  initState() {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.restoreSystemUIOverlays();
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: GestureDetector(
          child: Center(
            child: Image.network(widget.imageUrl),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
