import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vk_papers/VK%20api/Newsfeed.dart';

class VKWall {
  String _token;
  String _vkVersion;

  VKWall(this._token, this._vkVersion);

  Future<bool> repostDialog(Post post, BuildContext context) async {
    TextEditingController textEdit = new TextEditingController(text: "");
    AlertDialog dialog = new AlertDialog(
      title: Text("Сделать репост"),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          TextField(
            controller: textEdit,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Комментарий'),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(post.properties["ownerAvatar"]),
                ),
              ),
              Expanded(
                  child: RichText(
                      text: TextSpan(
                          text: post.properties["ownerName"],
                          style: TextStyle(color: Colors.black),
                          children: [
                    TextSpan(
                        text: '\nЗапись', style: TextStyle(color: Colors.grey))
                  ])))
            ],
          ),
        ],
      )),
      actions: [
        FlatButton(
            onPressed: () => Navigator.pop(context, true), child: Text("ОК")),
        FlatButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Отмена"))
      ],
    );

    bool value = await showDialog(context: context, child: dialog);
    if (value == true) {
      await repost(post.properties["ownerID"].toString(),
          post.properties["postID"].toString(),
          commentText: textEdit.text);
    }

    return value;
  }

  Future<http.Response> repost(String ownerID, String postID,
      {String commentText = "", String objectType = "wall"}) {
    var url = "https://api.vk.com/method/" +
        "wall.repost?object=" +
        objectType +
        ownerID +
        "_" +
        postID +
        "&message=" +
        commentText +
        "&access_token=" +
        _token +
        "&v=" +
        _vkVersion;

    return http.get(url);
  }
}
