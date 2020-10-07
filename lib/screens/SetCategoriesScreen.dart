import 'package:flutter/material.dart';

import '../VK%20api/VKController.dart';
import '../functions/FadeAnimation.dart';
import 'ShowGroupsScreen.dart';
import '../functions/swipe.dart';
import '../functions/Alerts.dart' as Alerts;

class SetCategoriesScreen extends StatefulWidget {
  @override
  _SetCategoriesScreenState createState() => _SetCategoriesScreenState();
}

class _SetCategoriesScreenState extends State<SetCategoriesScreen>
    with SingleTickerProviderStateMixin {
  bool editMode = false;
  FadeAnimation fadeOut;
  List<Widget> standardIcons;
  List<Widget> editModeIcons;

  List<int> selectedCommonGroups = new List<int>();
  List<int> selectedFavGroups = new List<int>();

  VKController vk = new VKController();

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  void onLoad() async {
    await vk.init();

    standardIcons = new List<Widget>();
    editModeIcons = new List<Widget>();

    fadeOut = new FadeAnimation(this);
    fadeOut.controller.animateTo(1.0);

    standardIcons.add(IconButton(
      icon: Icon(Icons.create_new_folder, color: Colors.white),
      onPressed: showAddNewCategory,
    ));

    editModeIcons.add(IconButton(
      icon: Icon(Icons.favorite, color: Colors.white),
      onPressed: () {
        setState(() {
          selectedCommonGroups.forEach((element) {
            selectedFavGroups.add(element);
          });
          selectedCommonGroups.clear();
          editMode = false;
        });
      },
    ));

    editModeIcons.add(IconButton(
        icon: Icon(Icons.delete, color: Colors.white),
        onPressed: showRemoveDialog));

    setState(() {});
  }

  void showAddNewCategory() async {
    var _result = await Alerts.showTextDialog(
        'Добавить новую категорию', "Название", context);

    if (_result != null) {
      vk.groups.mainActivities = await vk.groups.makeCommonActivities();
      setState(() {});
    }
  }

  void showRemoveDialog() async {
    var result = await Alerts.show(
        'Вы точно хотите скрыть записи от этих групп?',
        [],
        [
          new FlatButton(
            child: new Text('Да'),
            onPressed: () {
              setState(() {
                Navigator.of(context).pop(true);
              });
            },
          ),
          new FlatButton(
            child: new Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          )
        ],
        context);

    if (result != null) {
      editMode = !editMode;

      selectedCommonGroups.forEach((element) async {
        await vk.groups
            .removeCategory(vk.groups.mainActivities.keys.toList()[element]);
      });

      selectedCommonGroups.clear();

      await vk.groups.loadFromLocal();

      setState(() {});
    }
  }

  void showRenameDialog(String oldText) async {
    var result = await Alerts.showTextDialog("Переименовать", oldText, context);

    if (result != null) {
      await vk.groups.renameCategory(oldText, result);
      setState(() {});
    }
  }

  Color getButtonColor(int index) {
    if (editMode) {
      if (selectedCommonGroups.contains(index)) return Colors.blue;
    }
    if (selectedFavGroups.contains(index)) return Colors.yellow;
    return Colors.lightBlue.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: vk.inited == false
              ? Text("")
              : Text(vk.groups.mainActivities.keys.length.toString() +
                  " категорий"),
          centerTitle: true,
          leading: IconButton(
              icon: !editMode
                  ? Icon(
                      Icons.edit,
                      color: Colors.white,
                    )
                  : Icon(Icons.check, color: Colors.white),
              onPressed: () {
                setState(() {
                  editMode = !editMode;
                  selectedCommonGroups.clear();
                });
              }),
          actions: standardIcons != null && !editMode
              ? standardIcons
              : editModeIcons,
        ),
        body: buildButtonCategory());
  }

  Widget buildButtonCategory() {
    return OrientationBuilder(builder: (context, orientation) {
      return fadeOut != null
          ? FadeTransition(
              opacity: fadeOut.animation,
              child: Stack(children: [
                Container(
                  child: GridView.count(
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: const EdgeInsets.all(15),
                      children: vk.groups.mainActivities != null
                          ? List.generate(vk.groups.mainActivities.keys.length,
                              (index) {
                              return FlatButton(
                                  onLongPress: () {
                                    showRenameDialog(vk
                                        .groups.mainActivities.keys
                                        .toList()[index]);
                                  },
                                  onPressed: () async {
                                    if (!editMode) {
                                      final res = await Navigator.of(context)
                                          .push(GoTo(
                                              ShowGroupsScreen(
                                                  groups: vk.groups,
                                                  groupIndex: index),
                                              left: true));

                                      if (res == "refresh") {
                                        await vk.groups.init();
                                        setState(() {});
                                      }
                                    } else {
                                      setState(() {
                                        if (selectedCommonGroups
                                            .contains(index))
                                          selectedCommonGroups.remove(index);
                                        else
                                          selectedCommonGroups.add(index);

                                        if (selectedFavGroups.contains(index)) {
                                          selectedFavGroups.remove(index);
                                          selectedCommonGroups.remove(index);
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    vk.groups.mainActivities.keys
                                        .toList()[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: editMode
                                            ? selectedCommonGroups
                                                    .contains(index)
                                                ? Colors.white
                                                : Colors.black
                                            : Colors.black),
                                  ),
                                  color: getButtonColor(index));
                            })
                          : List.empty()),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text("Сохранить избранные списки и продолжить"),
                        onPressed: () async {
                          if (selectedFavGroups.length == 0) {
                            Alerts.showError(
                                "Ошибка!",
                                "Вам нужно добавить в избранное хотя бы одну категорию новостей.",
                                context);
                          } else {}
                        }),
                  ),
                )
              ]),
            )
          : Text("");
    });
  }
}
