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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      body: Container(
          color: Colors.black,
          child: InteractiveViewer(
            child: Center(
              child: FadeInImage.assetNetwork(
                  placeholder: "assets/temp.png", image: widget.imageUrl),
            ),
            maxScale: 2,
            minScale: 0.6,
            boundaryMargin: const EdgeInsets.all(50),
          )),
    );
  }
}
