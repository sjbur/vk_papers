import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';

class PostCard extends StatefulWidget {
  final String groupName;
  final String avatarUrl;
  final String timeAgo;
  final String postText;
  final BuildContext context;

  final String likes;
  final String comments;
  final String views;
  final String reposts;

  final List<Attachment> attachments;

  PostCard(this.context,
      {this.groupName,
      this.avatarUrl,
      this.timeAgo,
      this.postText,
      this.attachments,
      this.likes,
      this.comments,
      this.reposts,
      this.views});

  @override
  _PostCardState createState() => _PostCardState(this.context,
      groupName: groupName,
      avatarUrl: avatarUrl,
      timeAgo: timeAgo,
      postText: postText,
      attachments: attachments,
      likes: likes,
      comments: comments,
      views: views,
      reposts: reposts);
}

class _PostCardState extends State<PostCard> {
  final String groupName;
  final String avatarUrl;
  String timeAgo;
  final String postText;
  final BuildContext context;

  final String likes;
  final String comments;
  final String views;
  final String reposts;

  List<Attachment> attachments;

  _PostCardState(this.context,
      {this.groupName,
      this.avatarUrl,
      this.timeAgo,
      this.postText,
      this.attachments,
      this.likes,
      this.comments,
      this.reposts,
      this.views}) {
    Duration diff = DateTime.now().difference(DateTime.parse(timeAgo));

    if (diff.inMinutes > 60)
      timeAgo = diff.inHours.toString() + " ч. назад";
    else
      timeAgo = diff.inMinutes.toString() + " мин. назад";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
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
            child: postText != null
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      children: [
                        Linkify(
                            onOpen: (link) => launchURL(link.url),
                            text: postText,
                            options: LinkifyOptions(humanize: false)),
                      ],
                    ),
                  )
                : Text(""),
          ),
          buildPhotoAttachments(),
          postStatistics()
        ],
      ),
    );
  }

  Row buildPhotoAttachments() {
    List<Widget> photos = new List<Widget>();

    if (attachments != null) {
      attachments.forEach((attachment) {
        if (attachment.type == "photo") {
          List sizes = attachment.content["sizes"];
          photos.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(sizes[0]["url"]),
          ));
        }
      });
    }

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

  Row postStatistics() {
    return Row(
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
    );
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
