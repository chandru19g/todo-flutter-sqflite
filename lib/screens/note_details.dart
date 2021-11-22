import 'package:flutter/material.dart';
import '../note.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  final String buttonText;
  final bool delButton;

  const NoteDetail(this.appBarTitle, this.note, this.buttonText, this.delButton,
      {Key? key})
      : super(key: key);

  @override
  _NoteDetailState createState() =>
      _NoteDetailState(appBarTitle, note, buttonText, delButton);
}

class _NoteDetailState extends State<NoteDetail> {
  static final _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  String buttonText;
  bool delButton;

  _NoteDetailState(
      this.appBarTitle, this.note, this.buttonText, this.delButton);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodyText1;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () => moveToLastScreen(),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                  //dropdown menu
                  child: ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem,
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.lightGreen)),
                          );
                        }).toList(),
                        value: getPriorityAsString(note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            updatePriorityAsInt(valueSelectedByUser.toString());
                          });
                        }),
                  ),
                ),
                // Second Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      icon: const Icon(Icons.title),
                    ),
                  ),
                ),

                // Third Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      icon: Icon(Icons.details),
                    ),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(8.0)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.lightGreen),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(letterSpacing: 1.0),
                            textScaleFactor: 1.2,
                          ),
                          onPressed: () {
                            setState(() {
                              _save();
                            });
                          },
                        ),
                      ),
                      delButton
                          ? Container(
                              width: 10.0,
                            )
                          : Container(),
                      delButton
                          ? Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(8.0)),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.pink),
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(letterSpacing: 1.0),
                                  textScaleFactor: 1.2,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _delete();
                                  });
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
          );
        });
  }

  // convert string to int to save to database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // convert int to string to show user
  String? getPriorityAsString(int value) {
    String? priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      _showAlertDialog('Status', 'Problem saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (note.id!.isNaN) {
      _showAlertDialog('Status', 'First add a note');
      return;
    }

    int result = await helper.deleteNote(note.id!);

    if (result != 0) {
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      _showAlertDialog('Status', 'Problem deleting Note');
    }
  }
}
