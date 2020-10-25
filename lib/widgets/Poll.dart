import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

getMapFromUrl(String req, String token, String vkVersion) async {
  var url = "https://api.vk.com/method/" +
      req +
      "&access_token=" +
      token +
      "&v=" +
      vkVersion;

  var response = await http.get(url);
  Map<String, dynamic> js = await jsonDecode(response.body);

  return js["response"];
}

class Poll extends StatefulWidget {
  final String ownerID;
  final String ownerName;
  final String pollID;
  final String vkToken;
  final String vkVersion;

  const Poll(
      {Key key,
      @required this.pollID,
      @required this.vkToken,
      @required this.vkVersion,
      @required this.ownerID,
      @required this.ownerName})
      : super(key: key);

  @override
  _PollState createState() => _PollState();
}

class _PollState extends State<Poll> {
  String question;
  bool anonym;

  List<String> selectedAnswers;
  List totalAnswers;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    selectedAnswers = new List<String>();
    totalAnswers = new List();

    // loading poll's text
    var pollDetails = await getMapFromUrl(
        "polls.getById?owner_id=" +
            widget.ownerID +
            "&poll_id=" +
            widget.pollID,
        widget.vkToken,
        widget.vkVersion);

    question = pollDetails["question"];
    anonym = pollDetails["anonymous"];
    totalAnswers = pollDetails["answers"];

    // get selected answers
    List selAns = pollDetails["answer_ids"];
    selAns.forEach((element) {
      selectedAnswers.add(element.toString());
    });
    selAns.clear();

    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (anonym != null) {
      return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade100,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(children: [
                Text(
                  question,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.ownerName,
                      style: TextStyle(color: Color.fromARGB(200, 0, 0, 0))),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: anonym
                      ? Text("Анонимный опрос",
                          style: TextStyle(color: Color.fromARGB(200, 0, 0, 0)))
                      : Text("Публичный опрос",
                          style:
                              TextStyle(color: Color.fromARGB(200, 0, 0, 0))),
                ),
                Column(
                  children: buildVoteButtons(),
                )
              ])));
    }

    return Text("");
  }

  List<Widget> buildVoteButtons() {
    List<Widget> res = new List<Widget>();

    totalAnswers.forEach((element) {
      res.add(Row(
        children: [
          Expanded(
            child: FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(4.0)),
              color: Color.fromARGB(30, 170, 170, 170),
              onPressed: () {
                voteOrUnvote(element["id"].toString());
              },
              child: selectedAnswers.contains(element["id"].toString())
                  ? Text(
                      element["text"] + " - " + element["rate"].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      element["text"],
                    ),
            ),
          )
        ],
      ));
    });

    return res;
  }

  void voteOrUnvote(String ans) async {
    if (selectedAnswers.isEmpty) {
      if (!selectedAnswers.contains(ans))
        await voteFor(ans);
      else
        await unvoteAll();
    } else {
      await unvoteAll();
    }
  }

  Future<void> voteFor(String ans) async {
    print("voteFor - " + ans);
    int resp = await getMapFromUrl(
        "polls.addVote?owner_id=" +
            widget.ownerID +
            "&poll_id=" +
            widget.pollID +
            "&answer_ids=" +
            ans,
        widget.vkToken,
        widget.vkVersion);

    if (resp == 1) setState(() => selectedAnswers.add(ans));
  }

  Future<void> unvoteAll() async {
    selectedAnswers.forEach((element) async {
      int resp = await getMapFromUrl(
          "polls.deleteVote?owner_id=" +
              widget.ownerID +
              "&poll_id=" +
              widget.pollID +
              "&answer_id=" +
              element,
          widget.vkToken,
          widget.vkVersion);

      if (resp == 1) setState(() => selectedAnswers.remove(element));
    });
  }
}
