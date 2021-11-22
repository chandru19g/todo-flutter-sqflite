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
          navigateToDetail(Note("", "", 2), "Add Note", "Save", false);
        },
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, position) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.deepPurple[400],
          elevation: 4.0,
          child: ListTile(
            leading: const CircleAvatar(
                backgroundImage: NetworkImage(
              'https://i.ibb.co/m98Mfmm/Whats-App-Image-2021-11-22-at-1-48-05-PM-removebg-preview.png',
            )),
            title: Text(noteList[position].title.toUpperCase(),
                style: const TextStyle(
                  letterSpacing: 2.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                )),
            subtitle: Text(
              noteList[position].date,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: GestureDetector(
              child: const Icon(Icons.open_in_new, color: Colors.white),
              onTap: () {
                navigateToDetail(
                    noteList[position], "Edit Todo", "Update", true);
              },
            ),
          ),
        );
      },
    );
  }

  void navigateToDetail(
      Note note, String title, String buttonText, bool delButton) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(title, note, buttonText, delButton);
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
