import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VKVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const VKVideoPlayer({Key key, this.videoUrl}) : super(key: key);
  @override
  VKVideoPlayerState createState() => VKVideoPlayerState();
}

class VKVideoPlayerState extends State<VKVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  //
  WebViewController wbC;
  String url;

  void getVideoLink(String body) {
    print("started to extract");

    List videoQLTS = ["240", "360", "480", "720", "1080"];
    Map videoLinks = new Map();
    var doc = parse(body);

    doc.getElementsByTagName("source").forEach((element) {
      element.attributes.forEach((key, value) {
        if (key == "type") {
          if (value == "video/mp4") {
            String link = element.attributes["src"];

            videoQLTS.forEach((element) {
              if (link.contains(element + ".mp4"))
                videoLinks.putIfAbsent(element, () => link);
            });
          }
        }
      });
    });

    url = videoLinks.values.first;
    print(url);

    _controller = VideoPlayerController.network(url);

    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setVolume(1.0);

    if (this.mounted) setState(() {});

    return;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(children: [
          SizedBox.shrink(
            child: WebView(
              onWebViewCreated: (w) {
                wbC = w;
              },
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.videoUrl,
              onPageFinished: (a) async {
                print("page finished");
                getVideoLink(await wbC.evaluateJavascript(
                    "document.getElementsByTagName('html')[0].innerHTML"));
              },
            ),
          ),
          FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 50),
                            reverseDuration: Duration(milliseconds: 200),
                            child: _controller.value.isPlaying
                                ? SizedBox.shrink()
                                : Container(
                                    color: Colors.black26,
                                    child: Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 100.0,
                                      ),
                                    ),
                                  ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (this.mounted)
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                            },
                          ),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                  bufferedColor: Colors.lightBlue.shade100,
                                  backgroundColor: Colors.grey.shade200,
                                  playedColor: Colors.lightBlue)),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ]),
      ),
    );
  }
}
