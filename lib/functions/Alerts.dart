import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vk_times/widgets/Post.dart';

// void showAddNewCategory() async {
// TextEditingController _textController = TextEditingController();
// return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Добавить новую категорию'),
//         content: TextField(
//           autofocus: true,
//           controller: _textController,
//           decoration: InputDecoration(hintText: "Название"),
//         ),
//         actions: <Widget>[
//           new FlatButton(
//             child: new Text('Сохранить'),
//             onPressed: () {
//               vk.groups.addCategory(_textController.text);
//               Navigator.pop(context, "refresh");
//             },
//           ),
//           new FlatButton(
//             child: new Text('Отмена'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           )
//         ],
//       );
//     }).then((val) async {
//   vk.groups.mainActivities = await vk.groups.makeCommonActivities();
//   setState(() {});
// });
//   }

//    void showRemoveDialog() async {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return ClipRect(
//               child: AlertDialog(
//             title: Text('Вы точно хотите скрыть записи от этих групп?'),
//             actions: <Widget>[
//               new FlatButton(
//                 child: new Text('Да'),
//                 onPressed: () {
//                   setState(() {
//                     Navigator.of(context).pop(true);
//                   });
//                 },
//               ),
//               new FlatButton(
//                 child: new Text('Отмена'),
//                 onPressed: () {
//                   Navigator.of(context).pop(null);
//                 },
//               )
//             ],
//           ));
//         }).then((val) async {
//       if (val != null) {
//         editMode = !editMode;

//         selectedCommonGroups.forEach((element) async {
//           await vk.groups
//               .removeCategory(vk.groups.mainActivities.keys.toList()[element]);
//         });

//         selectedCommonGroups.clear();

//         await vk.groups.loadFromLocal();

//         setState(() {});
//       }
//     });
//   }

Future<dynamic> show(String title, List<Widget> contentWidgets,
    List<Widget> actionWidgets, BuildContext context) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: contentWidgets),
          ),
          actions: actionWidgets,
        );
      });
}

Future<dynamic> showError(String title, String message, BuildContext context,
    {List<Widget> customButtons}) {
  return show(
      title,
      [Text(message)],
      customButtons == null
          ? [
              FlatButton(
                child: Text('ОК'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]
          : customButtons,
      context);
}

Future<String> showTextDialog(String title, String hint, BuildContext context,
    {List<Widget> customButtons}) {
  TextEditingController _textController = TextEditingController();
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            controller: _textController,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('ОК'),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            ),
            new FlatButton(
              child: new Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }).then((val) async {
    return val;
  });
}

postMenu(BuildContext context, String urlToLaunch) {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Дополнительные действия"),
          actions: [
            FlatButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: urlToLaunch));
                  Navigator.of(context).pop();
                },
                child: Text("Скопировать ссылку")),
            FlatButton(
                onPressed: () {
                  launchURL(urlToLaunch, forceVC: false);
                  Navigator.of(context).pop();
                },
                child: Text("Открыть в браузере"))
          ],
        );
      });
}
