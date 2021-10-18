import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Routine extends StatefulWidget {
  const Routine({
    required this.routineId,
    required this.name,
    required this.goals,
    Key? key,
  }) : super(key: key);

  final int routineId;
  final String name;
  final String goals;

  @override
  _RoutineState createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  String? goalsText;

  @override
  void initState() {
    super.initState();
    goalsText = widget.goals.replaceAll(',', '\n');
  }

  Future<void> showNewExerciseDialog(context) async {
    final nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                const Text(
                  'New Workout',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                  ),
                ),
                TextButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF90CAF9),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameController.text;
                    // edit existing
                    await DatabaseHelper.inst.createWorkout(
                      WorkoutInfo(
                        routineId: widget.routineId,
                        name: name,
                      ),
                    );
                    // instead of pop so the FutureBuilder reloads
                    Navigator.pop(context);
                    setState(() {});
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
      future: DatabaseHelper.inst.getWorkoutsForRoutine(widget.routineId),
      builder:
          (BuildContext context, AsyncSnapshot<List<WorkoutInfo>> snapshot) {
        if (snapshot.hasError) {
          // ignore: avoid_print
          print('Error getting workouts: $snapshot.error');
          return const Text('Error getting workouts');
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
                  child: Text('Getting workouts...'),
                )
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'New routine',
                onPressed: () {
                  showNewExerciseDialog(context);
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: snapshot.data!.length + 1,
            itemBuilder: (context, i) {
              // goals
              if (i == 0) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    color: Color(0x20FFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'GOALS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        width: 70,
                        height: 1,
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF40C0DC),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        goalsText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Workout(
                id: snapshot.data![i - 1].id,
                name: snapshot.data![i - 1].name,
                reloadPage: () {
                  setState(() {});
                },
              );
            },
          ),
        );
      },
    );
  }
}

class Workout extends StatelessWidget {
  const Workout({
    required this.id,
    required this.name,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final Function reloadPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Slidable(
          key: Key(id.toString()),
          actionPane: const SlidableStrechActionPane(),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () async {
                await DatabaseHelper.inst.deleteWorkout(id);
                reloadPage();
              },
            )
          ],
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0x20FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: [
                // title row (title + edit button)
                SizedBox(
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 70,
                              height: 1,
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF40C0DC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          splashRadius: 24,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      WorkoutExercise(
                        name: 'BTW HSPU',
                        sets: '4',
                        reps: '4-6',
                        notes: 'One foot off wall, minimal arch',
                        rest: 90,
                        superset: 1,
                      ),
                      WorkoutExercise(
                        name: 'Front Lever Ring Raise',
                        sets: '4',
                        reps: '3-5',
                        notes: '',
                        rest: 90,
                        superset: 1,
                      ),
                      WorkoutExercise(
                        name: 'Planche Lean',
                        sets: '3',
                        reps: '10s',
                        notes: '',
                        rest: 30,
                        superset: 2,
                      ),
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
}

class WorkoutExercise extends StatelessWidget {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.notes,
    required this.rest,
    required this.superset,
    Key? key,
  }) : super(key: key);

  final String name;
  final String sets;
  final String reps;
  final String notes;
  final int rest;
  final int superset;

  @override
  Widget build(BuildContext context) {
    String finalDescription = (notes != '')
        ? '     $sets x $reps\n     $notes\n     Rest: ${rest}s'
        : '     $sets x $reps\n     Rest: ${rest}s';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$superset. $name',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            height: 2,
          ),
        ),
        Text(
          finalDescription,
          style: const TextStyle(
            color: Color(0x80FFFFFF),
          ),
        ),
      ],
    );
  }
}
