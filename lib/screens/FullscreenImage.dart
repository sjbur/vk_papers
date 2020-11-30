import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullscreenImage extends StatefulWidget {
  final List<String> images;
  final int imageIndex;

  const FullscreenImage(
      {Key key, @required this.images, @required this.imageIndex})
      : super(key: key);
  @override
  _FullscreenImageState createState() => _FullscreenImageState();
}

class _FullscreenImageState extends State<FullscreenImage> {
  PageController pg;
  bool showAppBar = true;

  @override
  initState() {
    pg = new PageController(initialPage: widget.imageIndex);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  int ab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: showAppBar
            ? null
            : FloatingActionButton(
                child: Icon(Icons.close),
                onPressed: () => Navigator.pop(context)),
        appBar: showAppBar
            ? AppBar(
                title: pg.hasClients
                    ? Text(ab.toString() +
                        " из " +
                        widget.images.length.toString())
                    : Text((widget.imageIndex + 1).toString() +
                        " из " +
                        widget.images.length.toString()),
              )
            : null,
        body: Container(
            color: Colors.black,
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  onTapUp: (context, details, controllerValue) => setState(() {
                    showAppBar = !showAppBar;
                    if (showAppBar)
                      SystemChrome.setEnabledSystemUIOverlays(
                          SystemUiOverlay.values);
                    else
                      SystemChrome.setEnabledSystemUIOverlays([]);
                  }),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                  imageProvider: NetworkImage(widget.images[index]),
                  heroAttributes: PhotoViewHeroAttributes(
                      tag: widget.images[index].toString()),
                );
              },
              itemCount: widget.images.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes,
                  ),
                ),
              ),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              pageController: pg,
              onPageChanged: (page) => setState(() => ab = page + 1),
            ))
        // body: Container(
        //     color: Colors.black,
        //     child: InteractiveViewer(
        //       child: Center(
        //         child: FadeInImage.assetNetwork(
        //             placeholder: "assets/temp.png", image: widget.imageUrl),
        //       ),
        //       maxScale: 2,
        //       minScale: 0.6,
        //       boundaryMargin: const EdgeInsets.all(50),
        //     )),
        );
  }
}
