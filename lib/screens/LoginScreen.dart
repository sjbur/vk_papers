import 'package:flutter/material.dart';
import 'package:vk_papers/screens/SetTimersScreen.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

import '../functions/Token.dart' as Token;
import 'package:vk_papers/screens/SetCategoriesScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool webLogin = false;

  Widget welcomeScreen() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "VK Papers",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                  text:
                      " - это приложение для людей, для которых важно как и быть в курсе последних новостей из социальных сетей, так и использовать своё время с пользой.",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
                flex: 1,
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      webLogin = true;
                    });
                  },
                  child: Text("Войти через ВКонтакте",
                      style: TextStyle(color: Colors.white)),
                  color: Colors.blue,
                ))
          ]),
        )
      ],
    );
  }

  bool isLoading = true;
  Widget webLoginScreen() {
    final Completer<WebViewController> _controller =
        Completer<WebViewController>();

    return Stack(
      children: [
        WebView(
          initialUrl:
              "https://oauth.vk.com/authorize?client_id=7574653&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=offline,groups,wall,friends,video&response_type=token&v=5.52",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webController) {
            _controller.complete(webController);
          },
          onPageStarted: (String url) async {
            setState(() {
              if (!isLoading) isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              if (isLoading) isLoading = false;
            });
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
                  MaterialPageRoute(builder: (context) => SetTimersScreen()));
            }
          },
        ),
        Center(
          child: isLoading ? CircularProgressIndicator() : Text(""),
        )
      ],
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
