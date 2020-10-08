import 'dart:ffi';

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

  final List<Attachment> attachments;

  PostCard(this.context,
      {this.groupName,
      this.avatarUrl,
      this.timeAgo,
      this.postText,
      this.attachments});

  @override
  _PostCardState createState() => _PostCardState(this.context,
      groupName: groupName,
      avatarUrl: avatarUrl,
      timeAgo: timeAgo,
      postText: postText,
      attachments: attachments);
}

class _PostCardState extends State<PostCard> {
  String groupName;
  String avatarUrl;
  String timeAgo;
  String postText;
  BuildContext context;

  List<Attachment> attachments;

  _PostCardState(this.context,
      {this.groupName,
      this.avatarUrl,
      this.timeAgo,
      this.postText,
      this.attachments}) {
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
          Column(
            children: buildPhotoAttachments(),
          )
          //buildPhotoAttachments()
        ],
      ),
    );
  }

  List<Widget> buildPhotoAttachments() {
    int i = 0;
    Widget res;
    List<Widget> photos = new List<Widget>();

    if (attachments != null) {
      attachments.forEach((attachment) {
        if (attachment.type == "photo") {
          List sizes = attachment.content["sizes"];
          double screenWidth = MediaQuery.of(context).size.width;
          photos.add(Image.network(sizes[0]["url"]));
        }
      });
    }

    if (res != null) {
      return photos;
    } else {
      photos.add(Text(""));
      return photos;
    }
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
