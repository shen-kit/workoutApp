// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';
import 'package:workout_app/routes/exercises.dart';

class Routines extends StatefulWidget {
  const Routines({Key? key}) : super(key: key);

  @override
  _RoutinesState createState() => _RoutinesState();
}

class _RoutinesState extends State<Routines> {
  void reloadPage() {
    setState(() {});
  }

  Future<void> showEditRoutineDialog(
    context, {
    int id = -1,
    String? oldName,
    String? oldGoals,
  }) async {
    final nameController = (id == -1)
        ? TextEditingController()
        : TextEditingController(text: oldName);
    final goalsController = (id == -1)
        ? TextEditingController()
        : TextEditingController(text: oldGoals);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Text(
                  (id == -1) ? 'New Routine' : 'Edit Routine',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: goalsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Goals (comma separated)',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF90CAF9),
                    ),
                  ),
                  onPressed: () {
                    final name = nameController.text;
                    final goals = goalsController.text;
                    // edit existing
                    if (id != -1) {
                      // DatabaseHelper.inst.updateRoutine(
                      //   RoutineInfo(
                      //     id: id,
                      //     name: name,
                      //   ),
                      // );
                    }
                    // create new tag
                    else {
                      DatabaseHelper.inst.createRoutine(
                        RoutineInfo(
                          name: name,
                          goals: goals,
                        ),
                      );
                    }
                    Navigator.pop(context);
                    reloadPage();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.inst.getAllRoutines(),
      builder:
          (BuildContext context, AsyncSnapshot<List<RoutineInfo>> snapshot) {
        if (snapshot.hasError) {
          print('Error getting routines: $snapshot.error');
          return const Text('Error getting routines');
        }
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Getting routines...'),
                )
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Routines'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'New routine',
                onPressed: () => showEditRoutineDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    return RoutineTile(
                      id: snapshot.data![i].id,
                      name: snapshot.data![i].name,
                      goals: snapshot.data![i].goals,
                      showEditRoutineDialog: showEditRoutineDialog,
                      reloadPage: reloadPage,
                    );
                  },
                ),
              ),
              // footer
              Container(
                color: const Color(0xFF3E3E3E),
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TextButton(
                        child: const Icon(
                          Icons.format_list_bulleted_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF505050),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        child: const Icon(
                          Icons.fitness_center,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Exercises(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoutineTile extends StatelessWidget {
  const RoutineTile({
    required this.id,
    required this.name,
    required this.goals,
    required this.showEditRoutineDialog,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final String goals;
  final Function showEditRoutineDialog;
  final Function reloadPage;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(id.toString()),
      actionPane: const SlidableScrollActionPane(),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            // DatabaseHelper.inst.deleteRoutine(id);
            // reload page
            reloadPage();
          },
        )
      ],
      actionExtentRatio: 1 / 5,
      child: SizedBox(
        height: 60,
        width: double.maxFinite,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              onLongPress: () => showEditRoutineDialog(
                context,
                id: id,
                oldName: name,
                oldGoals: goals,
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            //divider
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Divider(height: 1, thickness: 1),
            ),
          ],
        ),
      ),
    );
  }
}
