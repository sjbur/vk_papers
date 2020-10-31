import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../VK%20api/Groups.dart';
import '../functions/swipe.dart';

import 'SetCategoriesScreen.dart';

String _selection;

class ShowGroupsScreen extends StatefulWidget {
  final VKGroups groups;
  final int groupIndex;

  ShowGroupsScreen({this.groups, this.groupIndex});

  @override
  _ShowGroupsScreenState createState() =>
      _ShowGroupsScreenState(groups: groups, groupIndex: this.groupIndex);
}

class _ShowGroupsScreenState extends State<ShowGroupsScreen> {
  final VKGroups groups;
  final int groupIndex;

  _ShowGroupsScreenState({this.groups, this.groupIndex});

  List<Widget> editModeButtons = new List<Widget>();
  bool editMode = false;

  List<int> selectedIndexes = new List<int>();

  void showMoveToDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return ClipRect(
              child: AlertDialog(
            title: Text('Переместить в'),
            content: DropdownButtonBug(groups.mainActivities.keys.toList()),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Перенести'),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop(_selection);
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
          ));
        }).then((val) {
      setState(() {
        if (val != null) {
          editMode = !editMode;
          selectedIndexes.forEach((element) {
            groups.moveFromToCategoryByIndex(
                element,
                groups.mainActivities.keys.toList()[groupIndex].toString(),
                val);
          });
          selectedIndexes.clear();
          Navigator.pop(context, "refresh");
        }
      });
    });
  }

  void showRemoveDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return ClipRect(
              child: AlertDialog(
            title: Text('Вы точно хотите скрыть записи от этих групп?'),
            actions: <Widget>[
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
          ));
        }).then((val) {
      setState(() {
        if (val != null) {
          editMode = !editMode;

          List<Group> ls = groups
              .mainActivities[groups.mainActivities.keys.toList()[groupIndex]];

          selectedIndexes.forEach((element) {
            groups.removeGroup(
                ls[element], groups.mainActivities.keys.toList()[groupIndex]);
          });

          selectedIndexes.clear();
          Navigator.pop(context, "refresh");
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    editModeButtons.add(IconButton(
      icon: Icon(
        Icons.folder,
        color: Colors.white,
      ),
      onPressed: showMoveToDialog,
    ));
    editModeButtons.add(
      IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () async {
            showRemoveDialog();
          }),
    );
  }

  Widget groupItem(int index) {
    return InkWell(
      onTap: editMode
          ? () {
              if (!selectedIndexes.contains(index))
                selectedIndexes.add(index);
              else
                selectedIndexes.remove(index);
              setState(() {});
            }
          : () {},
      child: Container(
        decoration: BoxDecoration(
            color: editMode
                ? selectedIndexes.contains(index)
                    ? Colors.lightBlue
                    : Colors.white
                : Colors.white,
            border: Border(
                bottom: BorderSide(
                    color: Color.fromARGB(255, 190, 190, 190), width: 1.0))),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(groups
                              .mainActivities[groups.mainActivities.keys
                                  .toList()[groupIndex]][index]
                              .avatarUrl),
                          fit: BoxFit.fill),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                          groups
                              .mainActivities[groups.mainActivities.keys
                                  .toList()[groupIndex]][index]
                              .name,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 17.0,
                              color: editMode
                                  ? selectedIndexes.contains(index)
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.black)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {});
        Navigator.pop(context, 'refresh');
        return true;
      },
      child: new Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
                groups.mainActivities.keys.toList()[groupIndex].toString()),
            centerTitle: true,
            leading: IconButton(
              icon: !editMode
                  ? Icon(Icons.edit, color: Colors.white)
                  : Icon(Icons.check, color: Colors.white),
              onPressed: () async {
                editMode = !editMode;
                selectedIndexes.clear();

                setState(() {});
              },
            ),
            actions: editModeButtons != null && editMode ? editModeButtons : [],
          ),
          body: GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Note: Sensitivity is integer used when you don't want to mess up vertical drag
              int sensitivity = 3;
              if (details.delta.dx > sensitivity) {
                Navigator.push(
                    context, GoTo(SetCategoriesScreen(), left: true));
                // Right Swipe
              }
            },
            child: ListView.builder(
                itemCount: groups
                    .mainActivities[
                        groups.mainActivities.keys.toList()[groupIndex]]
                    .length,
                itemBuilder: (context, index) {
                  return groupItem(index);
                }),
          )),
    );
    //  );
  }
}

class DropdownButtonBug extends StatefulWidget {
  final List activities;

  DropdownButtonBug(this.activities);

  @override
  _DropdownButtonBugState createState() => _DropdownButtonBugState(activities);
}

class _DropdownButtonBugState extends State<DropdownButtonBug> {
  final List<String> _items;

  _DropdownButtonBugState(this._items);

  @override
  void initState() {
    _selection = _items.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMenuOptions = _items
        .map((String item) =>
            new DropdownMenuItem<String>(value: item, child: new Text(item)))
        .toList();

    return new DropdownButton<String>(
        isExpanded: true,
        value: _selection,
        items: dropdownMenuOptions,
        onChanged: (s) {
          setState(() {
            _selection = s;
          });
        });
  }
}
