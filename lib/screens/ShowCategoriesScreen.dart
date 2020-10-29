import 'package:flutter/material.dart';
import 'package:vk_papers/VK%20api/VKController.dart';
import 'package:vk_papers/functions/swipe.dart';
import 'package:vk_papers/screens/SettingsScreen.dart';
// import 'package:vk_papers/screens/ShowGroupsScreen.dart';
import 'package:vk_papers/screens/TestNewsScreen.dart';

class ShowCategoriesScreen extends StatefulWidget {
  @override
  _ShowCategoriesScreenState createState() => _ShowCategoriesScreenState();
}

class _ShowCategoriesScreenState extends State<ShowCategoriesScreen> {
  VKController vk = new VKController();

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  onLoad() async {
    await vk.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Новости"),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async {
                  await Navigator.of(context).push(GoTo(SettingsScreen()));
                })
          ],
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return vk.groups != null
              ? GridView.count(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  padding: const EdgeInsets.all(15),
                  children: generateButtons())
              : Text("");
        }));
  }

  List<Widget> generateButtons() {
    // sort by fav first
    return List.generate(vk.groups.mainActivities.keys.length, (index) {
      return FlatButton(
          color: Colors.lightBlue.shade400,
          onPressed: () async {
            String sources = "";
            vk.groups
                .mainActivities[vk.groups.mainActivities.keys.toList()[index]]
                .forEach((element) {
              sources += "-" + element.id + ",";
            });
            await Navigator.of(context).push(GoTo(
              TestNewsScreen(
                sources: sources,
                title: vk.groups.mainActivities.keys.toList()[index].toString(),
              ),
            ));
          },
          child: Text(
            vk.groups.mainActivities.keys.toList()[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ));
    });
  }
}
