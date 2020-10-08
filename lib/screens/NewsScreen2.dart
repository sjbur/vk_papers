import 'package:flutter/material.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';
import 'package:vk_papers/VK%20api/VKController.dart';
import 'package:vk_papers/functions/Post.dart';

class NewsScreen2 extends StatefulWidget {
  @override
  _NewsScreen2State createState() => _NewsScreen2State();
}

class _NewsScreen2State extends State<NewsScreen2> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    await vk.init();
    posts = await vk.newsfeed
        .getNews("?filters=post&count=1&source_ids=-111162777");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Новости"),
        ),
        body: posts == null
            ? Text("")
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    context,
                    groupName: posts[index].properties["ownerName"],
                    avatarUrl: posts[index].properties["ownerAvatar"],
                    timeAgo: posts[index].properties["postDate"],
                    postText: posts[index].properties["text"],
                    attachments: posts[index].attachments,
                    likes: posts[index].properties["likes"],
                    comments: posts[index].properties["comments"],
                    reposts: posts[index].properties["reposts"],
                    views: posts[index].properties["views"],
                  );
                },
              ));
  }
}
