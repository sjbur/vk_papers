import 'dart:convert';
import 'package:http/http.dart' as http;

import 'VKController.dart';

class Attachment {
  String type;
  Map<String, dynamic> content;

  Attachment(this.type, this.content);
}

class VKNewsfeed {
  String startFrom;

  Future<List<Post>> getNews(String req) async {
    var url = "https://api.vk.com/method/newsfeed.get" +
        req +
        "&access_token=" +
        await vk.getToken() +
        "&v=" +
        vk.vkVersion;

    var response = await http.get(url);
    Map<String, dynamic> js = await jsonDecode(response.body);

    if (js.containsKey("error")) {
      print("Error");
      throw Exception(js["error"]);
    } else {
      js = js["response"];
      startFrom = js["next_from"];

      List items = js["items"];
      List<Post> postCollection = new List<Post>();

      for (var i = 0; i < items.length; i++) {
        Map item = items[i];

        int groupID = item["source_id"];
        int timestamp = item["date"];

        String groupName = await getGroupName(js, groupID);
        String groupAvatar = await getGroupAvatar(js, groupID);
        String postDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
            .toLocal()
            .toString();
        String isAd = item["marked_as_ads"] == 1 ? "Да" : "Нет";
        String text = item["text"] == null ? "" : item["text"];

        String likes =
            item["likes"] != null ? item["likes"]["count"].toString() : "";

        String comments = item["comments"] != null
            ? item["comments"]["count"].toString()
            : "";

        String reposts =
            item["reposts"] != null ? item["reposts"]["count"].toString() : "";

        String views =
            item["views"] != null ? item["views"]["count"].toString() : "";
        String isFavor = item["is_favorite"].toString();
        String postID = item["post_id"].toString();

        Map _properties = new Map();
        _properties.putIfAbsent("ownerID", () => groupID);
        _properties.putIfAbsent("ownerName", () => groupName);
        _properties.putIfAbsent("ownerAvatar", () => groupAvatar);
        _properties.putIfAbsent("postDate", () => postDate);
        _properties.putIfAbsent("postUnixDate", () => timestamp.toString());
        _properties.putIfAbsent("isAd", () => isAd);
        _properties.putIfAbsent("text", () => text);
        _properties.putIfAbsent("likes", () => likes);
        _properties.putIfAbsent("comments", () => comments);
        _properties.putIfAbsent("isFavor", () => isFavor);
        _properties.putIfAbsent("reposts", () => reposts);
        _properties.putIfAbsent("views", () => views);
        _properties.putIfAbsent("postID", () => postID);

        postCollection
            .add(new Post(_properties, await getPostAttachments(item)));
      }

      return postCollection;
    }
  }

  Future<String> getGroupName(Map file, int num) async {
    List groups = file["groups"];

    for (var i = 0; i < groups.length; i++) {
      Map gr = groups[i];

      if (gr.containsValue(num * -1)) return (gr["name"]);
    }

    return "";
  }

  Future<String> getGroupAvatar(Map file, int num) async {
    List groups = file["groups"];

    for (var i = 0; i < groups.length; i++) {
      Map gr = groups[i];

      if (gr.containsValue(num * -1)) return (gr["photo_100"]);
    }

    return "";
  }

  Future<List<Attachment>> getPostAttachments(Map item) async {
    List<Attachment> attachments = new List<Attachment>();

    List _attachments = item["attachments"];

    if (_attachments != null)
      for (var q = 0; q < _attachments.length; q++) {
        Map attachment = _attachments[q];
        String attachmentType = attachment["type"];

        Attachment newAttachment;

        // print(attachmentType);
        switch (attachmentType) {
          case "link":
            Map<String, dynamic> content = {
              "url": attachment["link"]["url"],
              "title": attachment["link"]["title"]
            };

            if (attachment["link"]["photo"] != null) {
              content.putIfAbsent("photo", () => attachment["link"]["photo"]);
            }

            newAttachment = new Attachment("link", content);

            break;
          case "photo":
            Map<String, dynamic> content = {
              "sizes": attachment["photo"]["sizes"]
            };
            newAttachment = new Attachment("photo", content);
            break;

          case "doc":
            Map<String, dynamic> content = attachment["doc"];

            newAttachment = new Attachment(attachment["doc"]["ext"], content);

            break;

          case "video":
            Map<String, dynamic> content = attachment["video"];

            newAttachment = new Attachment("video", content);

            break;

          case "poll":
            Map<String, dynamic> content = attachment["poll"];

            newAttachment = new Attachment("poll", content);
            break;
        }

        if (newAttachment != null) attachments.add(newAttachment);
      }

    return attachments;
  }
}

class Post {
  Map properties = new Map();
  List<Attachment> attachments = new List<Attachment>();

  Post(this.properties, this.attachments);
}
