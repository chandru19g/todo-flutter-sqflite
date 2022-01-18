import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../note.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList.isEmpty) {
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: noteList.isNotEmpty
          ? getNoteListView()
          : Center(
              child: Text(
                "Add Todo's",
                style: TextStyle(
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          navigateToDetail(Note("", "", 2), "Add Note");
        },
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, position) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Dismissible(
            key: Key(noteList[position].id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 50.0,
              ),
            ),
            onDismissed: (direction) {
              _delete(noteList[position].id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${noteList[position].title} dismissed'),
                ),
              );
            },
            child: InkWell(
              onTap: () {
                navigateToDetail(noteList[position], "Edit Todo");
              },
              child: SizedBox(
                height: 80.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5.0,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              noteList[position].title.toUpperCase(),
                              style: const TextStyle(
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              noteList[position].date,
                              // style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 4.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _delete(id) async {
    if (id!.isNaN) {
      _showAlertDialog('Status', 'First add a note');
      return;
    }

    int result = await databaseHelper.deleteNote(id);

    if (result != 0) {
      updateListView();
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      updateListView();
      _showAlertDialog('Status', 'Problem deleting Note');
    }
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

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(title, note);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initialzeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }
}
