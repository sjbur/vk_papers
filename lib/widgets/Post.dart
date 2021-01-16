import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vk_times/VK%20api/Newsfeed.dart';
import 'package:vk_times/VK%20api/VKController.dart';
import 'package:vk_times/screens/FullscreenImage.dart';
import 'package:vk_times/widgets/Poll.dart';
import 'package:vk_times/widgets/VideoPlay.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vk_times/functions/Alerts.dart';

class PostCard extends StatefulWidget {
  final String groupName;
  final String avatarUrl;
  final String timeAgo;
  final String postText;
  final BuildContext context;

  final String likes;
  final bool userLikes;
  final String comments;
  final String views;
  final String reposts;
  final bool userReposted;

  final String accessToken;
  final String vkVersion;

  final Map properties;
  final List<Attachment> attachments;

  final VKController vk;

  PostCard(
      this.context,
      this.groupName,
      this.avatarUrl,
      this.timeAgo,
      this.postText,
      this.attachments,
      this.likes,
      this.userLikes,
      this.comments,
      this.reposts,
      this.userReposted,
      this.views,
      this.accessToken,
      this.vkVersion,
      this.properties,
      this.vk);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String timeAgo;

  bool userLiked;
  bool userReposted;

  var imageAvatar;

  @override
  void initState() {
    super.initState();

    Duration diff = DateTime.now().difference(DateTime.parse(widget.timeAgo));

    userLiked = widget.userLikes;
    userReposted = widget.userReposted;

    if (diff.inMinutes > 60)
      timeAgo = diff.inHours.toString() + " ч. назад";
    else if (diff.inMinutes == 0)
      timeAgo = "сейчас";
    else
      timeAgo = diff.inMinutes.toString() + " мин. назад";

    imageAvatar = Image.network(widget.avatarUrl);
  }

  @override
  void didChangeDependencies() {
    precacheImage(imageAvatar.image, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: imageAvatar,
                        // child: FadeInImage.assetNetwork(
                        //     fadeOutDuration: Duration(milliseconds: 30),
                        //     placeholder: "assets/group2.png",
                        //     image: widget.avatarUrl),
                      )),
                  title: Text(widget.groupName),
                  subtitle: Text(timeAgo),
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.more,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    // launch(urlString)
                    // launchURL(
                    //     "https://vk.com/wall" +
                    //         widget.properties["ownerID"].toString() +
                    //         "_" +
                    //         widget.properties["postID"].toString(),
                    //     forceVC: false);
                    postMenu(
                        context,
                        "https://vk.com/wall" +
                            widget.properties["ownerID"].toString() +
                            "_" +
                            widget.properties["postID"].toString());
                  })
            ],
          ),
          if (widget.postText != null || widget.postText != "")
            BuildTextPost(
              postText: widget.postText,
            ),
          buildPhotoAttachments(),
          BuildPhotoLink(widget.attachments),
          buildDocumentsAttachments(),
          buildVideos(),
          buildPoll(),
          postStatistics(),
        ],
      ),
    );
  }

  void likePost() async {}

  Widget buildPhotoAttachments() {
    List<Widget> photos = new List<Widget>();
    // List<Image> precachedPhotos = new List<Image>();

    List<String> imagesHQList = new List<String>();
    List<String> imagesLQList = new List<String>();

    if (widget.attachments != null) {
      widget.attachments.forEach((attachment) {
        if (attachment.type == "photo") {
          List sizes = attachment.content["sizes"];

          imagesLQList.add(sizes[0]["url"]);
          imagesHQList.add(sizes[sizes.length - 1]["url"]);
        }
      });
    }

    imagesHQList.forEach((element) {
      photos.add(GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return FullscreenImage(
                imageIndex: imagesHQList.indexOf(element),
                images: imagesHQList,
              );
            }));
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: FadeInImage.assetNetwork(
                placeholder: "assets/temp.png",
                image: imagesLQList[imagesHQList.indexOf(element)]
                // child: Image.network(
                //   thumbnail,
                //   fit: BoxFit.fill,
                // ),
                ),
          )));
    });

    List<Widget> res = [];
    List<Widget> res2 = [];
    List<Widget> res3 = [];

    int i = 0;
    photos.forEach((element) {
      if (i == 3) i = 0;

      switch (i) {
        case 0:
          res.add(element);
          break;
        case 1:
          res2.add(element);
          break;
        case 2:
          res3.add(element);
          break;
      }

      i++;
    });

    if (photos.length == 1) return res[0];

    if (photos != null) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: res,
              ),
            ),
            Expanded(
              child: Column(
                children: res2,
              ),
            ),
            Expanded(
              child: Column(
                children: res3,
              ),
            )
          ]);
    } else {
      photos.add(Text(""));
      return Row(
        children: photos,
      );
    }
  }

  String shortStatNum(String num, {bool views = false}) {
    String res;
    double dNum = double.parse(num);

    if (views) {
      if (dNum > 1000) res = (dNum / 1000).floor().toString() + "K";
    } else {
      if (dNum > 10000) res = (dNum / 1000).toStringAsFixed(2) + "K";
    }

    if (res == null)
      return num;
    else
      return res;
  }

  Row postStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                    iconSize: 18.0,
                    icon: Icon(
                      Icons.favorite,
                      color: userLiked == true ? Colors.pink : Colors.grey,
                    ),
                    onPressed: () async {
                      userLiked = !userLiked;

                      var url;

                      if (userLiked) {
                        url =
                            "https://api.vk.com/method/likes.add?type=post&owner_id=" +
                                widget.properties["ownerID"].toString() +
                                "&item_id=" +
                                widget.properties["postID"].toString() +
                                "&access_token=" +
                                widget.accessToken +
                                "&v=" +
                                widget.vkVersion;
                      } else {
                        url =
                            "https://api.vk.com/method/likes.delete?type=post&owner_id=" +
                                widget.properties["ownerID"].toString() +
                                "&item_id=" +
                                widget.properties["postID"].toString() +
                                "&access_token=" +
                                widget.accessToken +
                                "&v=" +
                                widget.vkVersion;
                      }

                      await http.get(url);

                      setState(() {});
                    },
                    padding: EdgeInsets.all(0)),
                if (widget.likes != null && widget.likes != "0")
                  Text(shortStatNum(widget.likes))
                else
                  Text("")
              ],
            ),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                IconButton(
                  iconSize: 18.0,
                  icon: Icon(Icons.comment),
                  onPressed: null,
                  padding: EdgeInsets.all(0),
                ),
                if (widget.comments != null && widget.comments != "0")
                  Text(widget.comments)
                else
                  Text("")
              ]),
            )),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    iconSize: 18.0,
                    icon: Icon(Icons.share),
                    color: userReposted ? Colors.lightBlue : Colors.grey,
                    onPressed: () async {
                      bool res = await widget.vk.wall.repostDialog(
                          new Post(widget.properties, widget.attachments),
                          context);

                      if (res == true) setState(() => userReposted = true);
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  if (widget.reposts != null && widget.reposts != "0")
                    Text(shortStatNum(widget.reposts))
                  else
                    Text("")
                ],
              ),
            )),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  iconSize: 18.0,
                  icon: Icon(Icons.portrait),
                  onPressed: null,
                  padding: EdgeInsets.all(0),
                ),
                if (widget.views != null && widget.views != "0")
                  Text(shortStatNum(widget.views, views: true))
                else
                  Text("")
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildDocumentsAttachments() {
    List<Widget> docs = new List<Widget>();
    if (widget.attachments != null) {
      widget.attachments.forEach((attachment) {
        if (attachment.type == "gif") {
          docs.add(BuildGif(
              gifPreview: attachment.content["preview"]["photo"]["sizes"][0]
                  ["src"],
              gifUrl: attachment.content["url"]));
        }
      });
    }

    return Column(
      children: docs,
    );
  }

  Widget buildVideos() {
    List<Widget> res = new List<Widget>();

    if (widget.attachments != null) {
      widget.attachments.forEach((attachment) {
        if (attachment.type == "video") {
          res.add(VideoP(
            token: widget.accessToken,
            vkV: widget.vkVersion,
            videoId: attachment.content["id"].toString(),
            videoOwner: attachment.content["owner_id"].toString(),
          ));
        }
      });
    }

    return Column(
      children: res,
    );
  }

  Widget buildPoll() {
    List<Widget> res = new List<Widget>();

    if (widget.attachments != null) {
      widget.attachments.forEach((attachment) {
        if (attachment.type == "poll") {
          res.add(Poll(
            vkToken: widget.accessToken,
            vkVersion: widget.vkVersion,
            pollID: attachment.content["id"].toString(),
            ownerID: attachment.content["owner_id"].toString(),
            ownerName: widget.groupName,
          ));
        }
      });
    }

    return Column(
      children: res,
    );
  }
}

class BuildTextPost extends StatefulWidget {
  final postText;

  const BuildTextPost({Key key, this.postText}) : super(key: key);
  @override
  _BuildTextPostState createState() => _BuildTextPostState(postText);
}

class _BuildTextPostState extends State<BuildTextPost> {
  final postText;
  String textShorted;
  bool shorted;

  _BuildTextPostState(this.postText);

  @override
  void initState() {
    super.initState();
    if (postText.length > 300) textShorted = postText.substring(0, 300);
    shorted = true;
    setState(() {});
  }

  List<Widget> showText() {
    if (textShorted != null) {
      if (shorted)
        return [
          Linkify(
              onOpen: (link) => launchURL(link.url),
              text: textShorted,
              options: LinkifyOptions(humanize: false)),
          Align(
            alignment: Alignment.centerLeft,
            child: FlatButton(
              onPressed: () {
                setState(() => shorted = false);
              },
              child: Text("Читать дальше"),
            ),
          )
        ];
      else
        return [
          Linkify(
              onOpen: (link) => launchURL(link.url),
              text: postText,
              options: LinkifyOptions(humanize: false))
        ];
    } else {
      return [
        Linkify(
            onOpen: (link) => launchURL(link.url),
            text: postText,
            options: LinkifyOptions(humanize: false))
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: postText != null
            ? Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: showText(),
                ),
              )
            : Text(""),
      ),
    );
  }
}

class BuildPhotoLink extends StatelessWidget {
  BuildPhotoLink(this.attachments);

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    String linkPic;
    String linkUrl;
    String linkTitle;

    bool exists = false;

    attachments.forEach((element) {
      if (element.type == "link") {
        linkTitle = element.content["title"];
        linkUrl = element.content["url"];

        if (element.content["photo"] != null && element.content["photo"] != "")
          linkPic = element.content["photo"]["sizes"][0]["url"];

        // element.content["photo"]["sizes"][1] == null
        //     ? linkPic = element.content["photo"]["sizes"][0]["url"]
        //     : linkPic = element.content["photo"]["sizes"][1]["url"];

        exists = true;
      }
    });

    if (!exists) return Text("");

    return InkWell(
      onTap: () {
        launchURL(linkUrl);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9.0),
            border: Border.all(color: Colors.grey, width: 0.5)),
        child: Column(children: [
          Row(
            children: [
              if (linkPic != null)
                Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6.0), bottom: Radius.zero),
                      child: Container(
                        height: 100,
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/temp.png",
                          image: linkPic,
                          fit: BoxFit.cover,
                        ),
                      )
                      // ? Image.network(
                      //     linkPic,
                      //     // fit: BoxFit.fitWidth,
                      //   )
                      ),
                )
            ],
          ),
          ListTile(
            leading: linkPic != null ? null : Icon(Icons.web_asset),
            title: Text(linkTitle),
            subtitle: Text(linkUrl),
          )
        ]),
      ),
    );
  }
}

class BuildGif extends StatefulWidget {
  final String gifUrl;
  final String gifPreview;

  const BuildGif({Key key, this.gifUrl, this.gifPreview}) : super(key: key);

  @override
  _BuildGifState createState() => _BuildGifState();
}

class _BuildGifState extends State<BuildGif> {
  bool showFull = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => showFull = !showFull),
      child: showFull
          ? Image.network(
              widget.gifUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            )
          : Container(
              child: Column(
                children: [
                  Image.network(widget.gifPreview),
                  FlatButton(onPressed: null, child: Text("GIF"))
                ],
              ),
            ),
    );
  }
}

class VideoP extends StatefulWidget {
  final String token;
  final String vkV;
  final String videoId;
  final String videoOwner;

  const VideoP({Key key, this.videoId, this.videoOwner, this.token, this.vkV})
      : super(key: key);

  @override
  _VideoPState createState() => _VideoPState();
}

class _VideoPState extends State<VideoP> {
  String url;
  String platform = "";
  String wUrl;
  String firstFrame;

  bool vkPlay = false;
  bool webLoaded = false;

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  void onLoad() async {
    await getPlayer();
  }

  Future getPlayer() async {
    var url = "https://api.vk.com/method/video.get?extended=1&videos=" +
        widget.videoOwner +
        "_" +
        widget.videoId +
        "&access_token=" +
        widget.token +
        "&v=" +
        widget.vkV;

    print(url);

    var response = await http.get(url);
    Map<String, dynamic> js = await jsonDecode(response.body);

    if (js.containsKey("error")) {
      throw Exception(js["error"]);
    } else {
      js = js["response"];

      if (js["count"] != 0) {
        js = js["items"][0];

        if (js.containsKey("platform")) {
          //print(js["platform"]);
          platform = "YouTube";
          wUrl = js["player"];
          print(wUrl);
        } else {
          print("vk video");
          platform = "vk";

          firstFrame = js["image"][0]["url"];
        }
      } else {
        platform = "";
      }

      if (this.mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (platform) {
      case "vk":
        return vkPlay == true
            ? VKVideoPlayer(
                videoUrl: "https://m.vk.com/video" +
                    widget.videoOwner +
                    "_" +
                    widget.videoId)
            : InkWell(
                onTap: () => setState(() => vkPlay = true),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(firstFrame), fit: BoxFit.fill)),
                  child: Center(
                      child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  )),
                ),
              );
        break;

      case "":
        return Text("");
        break;

      default:
        return Container(
          width: 250,
          height: 250,
          child: Stack(children: [
            WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: wUrl,
                onPageFinished: (a) => setState(() {
                      webLoaded = true;
                    })),
            Center(
              child: Container(
                child:
                    webLoaded ? SizedBox.shrink() : CircularProgressIndicator(),
              ),
            )
          ]),
        );
        break;
    }
  }
}

launchURL(String url, {bool forceVC = true}) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: forceVC);
  }
}
