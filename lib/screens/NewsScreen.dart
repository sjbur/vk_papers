import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:linkify/linkify.dart';
// import 'package:video_player/video_player.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';
import 'package:vk_papers/VK%20api/VKController.dart';

class NewsScreeen extends StatefulWidget {
  @override
  _NewsScreeenState createState() => _NewsScreeenState();
}

class _NewsScreeenState extends State<NewsScreeen> {
  @override
  void initState() {
    super.initState();
    aue();
  }

  void aue() async {
    await loadPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Новости"),
        ),
        body: r
            ? new ListView.builder(
                itemCount: posts.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return buildPost(
                      posts[index].properties["ownerAvatar"],
                      posts[index].properties["ownerName"],
                      posts[index].properties["text"],
                      posts[index].properties["postDate"],
                      posts[index].properties["likes"],
                      posts[index].properties["comments"],
                      posts[index].properties["reposts"],
                      posts[index].properties["views"]);
                })
            : Text(""));
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  List<String> extractLinks(String input) {
    List<String> _res = new List<String>();
    var elements = linkify(input,
        options: LinkifyOptions(
          humanize: false,
        ));
    for (var e in elements) {
      if (e is LinkableElement) {
        _res.add(e.url);
      }
    }
    return _res;
  }

  List<Post> posts = new List<Post>();
  var r = false;
  Future<void> loadPost() async {
    await vk.init();
    posts = await vk.newsfeed.getNews("?count=10&filters=post");
    print(posts.length);
    setState(() {
      r = true;
    });
  }

  Widget buildPost(
      String avatarUrl,
      String groupName,
      String text,
      String timeAgo,
      String likes,
      String comments,
      String reposts,
      String views) {
    //List<String> links = extractLinks(text);

    return Card(
      child: Column(children: [
        ListTile(
          leading: Container(
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
              )),
          title: Text(groupName),
          subtitle: Text(timeAgo),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: text != null
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Linkify(
                          onOpen: (link) => launchURL(link.url),
                          text: text,
                          options: LinkifyOptions(humanize: false)),
                    ],
                  ),
                )
              : Text(""),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.favorite), onPressed: null),
                  if (likes != null) Text(likes) else Text("")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                IconButton(icon: Icon(Icons.comment), onPressed: null),
                if (comments != null) Text(comments) else Text("")
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.share), onPressed: null),
                  if (reposts != null) Text(reposts) else Text("")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.portrait), onPressed: null),
                  if (views != null) Text(views) else Text("")
                ],
              ),
            )
          ],
        )
      ]),
    );
  }
}

class BuildPhotos extends StatelessWidget {
  const BuildPhotos({Key key, @required this.photosList}) : super(key: key);

  final List<String> photosList;

  @override
  Widget build(BuildContext context) {
    switch (photosList.length) {
      case 1:
        return Image.network(
          photosList[0],
          fit: BoxFit.fitWidth,
        );
        break;
      case 2:
        List<Widget> column1 = new List<Widget>();
        List<Widget> column2 = new List<Widget>();

        var i = 0;
        photosList.forEach((element) {
          i % 2 == 0
              ? column1.add(
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Image.network(
                      photosList[i],
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                )
              : column2.add(
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Image.network(
                      photosList[i],
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                );
          i++;
        });
        return Row(children: [
          Expanded(
            flex: 5,
            child: Column(
              children: column1,
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: column2,
            ),
          )
        ]);
        break;

      default:
        List<Widget> row = new List<Widget>();
        photosList.forEach((element) {
          row.add(Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Image.network(
              element,
              fit: BoxFit.fitHeight,
            ),
          ));
        });
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Expanded(
            child: Row(
              children: row,
            ),
          ),
        );
        break;
    }
  }
}

class BuildPhotoLink extends StatelessWidget {
  const BuildPhotoLink({
    Key key,
    @required this.linkPic,
    @required this.linkUrl,
    @required this.linkTitle,
  }) : super(key: key);

  final String linkPic;
  final String linkUrl;
  final String linkTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(9.0)),
      child: Column(children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6.0), bottom: Radius.zero),
                child: Image.network(
                  linkPic,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: ListTile(
              title: Text(linkTitle),
              subtitle: Text(linkUrl),
            )),
          ],
        ),
      ]),
    );
  }
}
