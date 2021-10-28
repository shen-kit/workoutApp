// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_app/routes/exercises.dart';
import 'package:workout_app/routes/new_workout_exercise.dart';

class Workout extends StatefulWidget {
  const Workout({
    required this.workoutId,
    required this.name,
    Key? key,
  }) : super(key: key);

  final int workoutId;
  final String name;

  @override
  _WorkoutState createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  Future<void> showEditWorkoutDialog(context, String oldName) async {
    final nameController = TextEditingController(text: oldName);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                const Text(
                  'Edit Workout',
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
                    await DatabaseHelper.inst.editWorkout(
                      name,
                      widget.workoutId,
                    );
                    // instead of pop so the FutureBuilder reloads
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Workout(workoutId: widget.workoutId, name: name),
                      ),
                    );
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
        future: DatabaseHelper.inst.getWorkoutExercises(widget.workoutId),
        builder: (context, AsyncSnapshot<List<WorkoutExerciseInfo>> snapshot) {
          if (snapshot.hasError) {
            print('Error getting workout: $snapshot.error');
            return const Text('Error getting workout');
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
                    child: Text('Getting workout...'),
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
                  tooltip: 'Add Exercise',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Exercises(
                          addToWorkout: true,
                          workoutId: widget.workoutId,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showEditWorkoutDialog(context, widget.name);
                  },
                ),
              ],
            ),
            body: ReorderableListView.builder(
              padding: const EdgeInsets.all(20),
              onReorder: (int oldIndex, int newIndex) async {
                if (oldIndex < newIndex) {
                  newIndex--;
                }
                await DatabaseHelper.inst.reorderWorkoutExercise(
                    widget.workoutId, oldIndex, newIndex);
                setState(() {});
              },
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                WorkoutExerciseInfo exercise = snapshot.data![i];
                return Exercise(
                  key: Key(exercise.id.toString()),
                  id: exercise.id,
                  workoutId: widget.workoutId,
                  name: exercise.exerciseName!,
                  sets: exercise.sets,
                  reps: exercise.reps,
                  weight: exercise.weight,
                  notes: exercise.notes,
                  superset: exercise.superset,
                  reloadPage: () {
                    setState(() {});
                  },
                );
              },
            ),
          );
        });
  }
}

class Exercise extends StatelessWidget {
  const Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.notes,
    required this.superset,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final int workoutId;
  final String name;
  final String sets;
  final String reps;
  final String weight;
  final String notes;
  final int superset;
  final Function reloadPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0x20FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 0,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewWorkoutExercise(
                exerciseName: name,
                workoutExercise: WorkoutExerciseInfo(
                  id: id,
                  workoutId: workoutId,
                  exerciseId: -1,
                  exerciseName: name,
                  sets: sets,
                  reps: reps,
                  notes: notes,
                  weight: weight,
                  superset: superset,
                ),
              ),
            ),
          );

          reloadPage();
        },
        title: Slidable(
          actionPane: const SlidableStrechActionPane(),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () async {
                await DatabaseHelper.inst.deleteWorkoutExercise(id);
                reloadPage();
              },
            )
          ],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                // title row
                SizedBox(
                  height: 35,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppData.supersetColors[superset - 1],
                          ),
                          child: Center(child: Text(superset.toString())),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(notes),
                SizedBox(height: (notes.isEmpty) ? 0 : 10),
                // sets/reps/weight
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            const Text(
                              'SETS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(sets),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        thickness: 1,
                        color: Color(0xFF40C0DC),
                      ),
                      SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            const Text(
                              'REPS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(reps),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        thickness: 1,
                        color: Color(0xFF40C0DC),
                      ),
                      SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            const Text(
                              'WEIGHT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text((weight == '0') ? 'N/A' : weight + 'kg'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
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
