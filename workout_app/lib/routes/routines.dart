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
                  onPressed: () async {
                    final name = nameController.text;
                    final goals = goalsController.text;
                    // edit existing
                    if (id != -1) {
                      await DatabaseHelper.inst.updateRoutine(
                        RoutineInfo(
                          id: id,
                          name: name,
                          goals: goals,
                        ),
                      );
                    }
                    // create new routine
                    else {
                      await DatabaseHelper.inst.createRoutine(
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
          body: ReorderableListView.builder(
            onReorder: (int oldIndex, int newIndex) async {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              await DatabaseHelper.inst.reorderRoutines(oldIndex, newIndex);
              setState(() {});
            },
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              return RoutineTile(
                key: Key(snapshot.data![i].id.toString()),
                id: snapshot.data![i].id,
                name: snapshot.data![i].name,
                goals: snapshot.data![i].goals,
                order: snapshot.data![i].order,
                showEditRoutineDialog: showEditRoutineDialog,
                reloadPage: reloadPage,
              );
            },
          ),
          bottomNavigationBar: Row(
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
    required this.order,
    required this.showEditRoutineDialog,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final String goals;
  final int order;
  final Function showEditRoutineDialog;
  final Function reloadPage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      onTap: () {},
      onLongPress: () => showEditRoutineDialog(
        context,
        id: id,
        oldName: name,
        oldGoals: goals,
      ),
      title: Slidable(
        key: Key(id.toString()),
        actionPane: const SlidableScrollActionPane(),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async {
              await DatabaseHelper.inst.deleteRoutine(id);
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
              Center(
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
              //reorderable handle
              Align(
                alignment: Alignment.centerRight,
                child: ReorderableDragStartListener(
                  index: order,
                  child: const Icon(
                    Icons.drag_indicator,
                    color: Color(0xAAEEEEFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // trailing: ,
    );
  }
}
