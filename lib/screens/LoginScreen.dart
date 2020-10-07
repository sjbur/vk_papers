import 'package:flutter/material.dart';
import 'package:vk_papers/screens/SetCategoriesScreen.dart';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import '../functions/Token.dart' as Token;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool webLogin = false;

  Widget welcomeScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FlatButton(
          onPressed: () {
            setState(() {
              webLogin = true;
            });
          },
          child: Text("Войти через ВКонтакте",
              style: TextStyle(color: Colors.white)),
          color: Colors.blue,
        )
      ],
    );
  }

  Widget webLoginScreen() {
    final Completer<WebViewController> _controller =
        Completer<WebViewController>();

    return WebView(
      initialUrl:
          "https://oauth.vk.com/authorize?client_id=7574653&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=offline,groups,wall,friends&response_type=token&v=5.52",
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webController) {
        _controller.complete(webController);
      },
      onPageFinished: (String url) async {
        print(url);

        if (url.startsWith("https://oauth.vk.com/blank.html")) {
          String token = "";

          var start = false;
          var end = false;

          for (var i = 0; i < url.length; i++) {
            if (url[i] == "&") end = true;

            if (start) if (!end)
              token += url[i];
            else
              break;

            if (url[i] == "#") start = true;
          }
          Token.saveToken(token.replaceAll("access_token=", ""));

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SetCategoriesScreen()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("VK Papers", style: TextStyle(color: Colors.white)),
        ),
        body: webLogin ? webLoginScreen() : welcomeScreen());
  }
}
