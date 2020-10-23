import 'package:flutter/material.dart';
import 'package:vk_papers/VK%20api/Newsfeed.dart';
import 'package:vk_papers/VK%20api/VKController.dart';
// import 'package:vk_papers/functions/Post.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/screens/LoginScreen.dart';

class NewsScreen2 extends StatefulWidget {
  @override
  _NewsScreen2State createState() => _NewsScreen2State();
}

class _NewsScreen2State extends State<NewsScreen2> {
  List<Post> posts;
  String token;
  String vkVer;

  @override
  void initState() {
    super.initState();
    load();
  }

  List<Post> news;
  void load() async {
    await vk.init();
    news = await vk.newsfeed
        .getNews("?filters=post&count=1&source_ids=-140820686");

    // make check in vk class
    if (news == null)
      await Navigator.of(context)
          .pushReplacement(GoTo(LoginScreen(), left: true));

    token = await vk.getToken();
    vkVer = vk.vkVersion;
    if (news != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Новости"),
        ),
        body: Column(
          children: [news != null ? BuildPoll(post: news[0]) : Text("")],
        ));
  }
}

class BuildPoll extends StatefulWidget {
  final Post post;

  const BuildPoll({Key key, this.post}) : super(key: key);

  @override
  _BuildPollState createState() => _BuildPollState();
}

class _BuildPollState extends State<BuildPoll> {
  Color mainColor = Color(0xff3A4E9F);

  String ownerName;
  String pollID;
  String pollTitle;
  bool anonym;

  List<Map<String, dynamic>> answers = new List<Map<String, dynamic>>();
  List<String> selectedAnswersID;

  void checkInteraction() async {
    setState(() {
      answers.clear();
      widget.post.attachments.forEach((element) {
        if (element.type == "poll") {
          ownerName = widget.post.properties["ownerName"].toString();
          pollID = element.content["id"].toString();
          anonym = element.content["anonymous"];
          pollTitle = element.content["question"].toString();

          List a = element.content["answers"];
          a.forEach((element) {
            var newAnswer = {
              'id': element["id"],
              'rate': element["rate"],
              'text': element["text"],
              'votes': element["votes"]
            };
            answers.add(newAnswer);
          });
          print("кол-во ответов: " + answers.length.toString());

          if (element.content["answer_ids"].toString() == "[]") {
            print("null");
            selectedAnswersID = new List<String>();
          } else {
            print("not null - " + element.content["answer_ids"].toString());
            selectedAnswersID = new List<String>();
            List.of(element.content["answer_ids"]).forEach((answer) {
              selectedAnswersID.add(answer.toString());
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("start");
    checkInteraction();

    if (answers.isEmpty) {
      return Text("");
    } else {
      return buildPoll();
    }
  }

  Widget buildPoll() {
    return Container(
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(children: [
              Text(
                pollTitle,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(ownerName,
                    style: TextStyle(color: Color.fromARGB(200, 0, 0, 0))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: anonym
                    ? Text("Анонимный опрос",
                        style: TextStyle(color: Color.fromARGB(200, 0, 0, 0)))
                    : Text("Публичный опрос",
                        style: TextStyle(color: Color.fromARGB(200, 0, 0, 0))),
              ),
              Column(
                children: buildVoteButtons(),
              )
            ])));
  }

  void ae(String id) {
    print("a");
  }

  List<Widget> buildVoteButtons() {
    List<Widget> res = new List<Widget>();

    answers.forEach((element) {
      res.add(VoteButton(
        voteTitle: element["text"].toString(),
        voteID: element["id"].toString(),
        votePercent: element["rate"].toString(),
        selected: selectedAnswersID.contains(
          element["id"].toString(),
        ),
        func: ae,
      ));
    });

    return res;
  }
}

class VoteButton extends StatefulWidget {
  final String voteTitle;
  final String voteID;
  final String votePercent;
  final bool selected;
  final func;

  const VoteButton({
    Key key,
    this.voteTitle,
    this.voteID,
    this.votePercent,
    this.selected,
    this.func,
  }) : super(key: key);

  @override
  _VoteButtonState createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  bool clicked = false;

  @override
  void initState() {
    super.initState();

    if (widget.selected == true) {
      setState(() {
        clicked = true;
      });
    }
  }

  void voteUnvote() {
    if (!clicked) setState(() => clicked = !clicked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(4.0)),
              color: Color.fromARGB(30, 170, 170, 170),
              onPressed: () {
                widget.func();
              },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: clicked == false
                      ? Text(
                          widget.voteTitle,
                          style: TextStyle(color: Color.fromARGB(220, 0, 0, 0)),
                        )
                      : Text(
                          widget.voteTitle + " - " + widget.votePercent + "%",
                          style: TextStyle(
                              color: Color.fromARGB(220, 0, 0, 0),
                              fontWeight: FontWeight.bold),
                        ))),
        ),
      ],
    );
  }
}
