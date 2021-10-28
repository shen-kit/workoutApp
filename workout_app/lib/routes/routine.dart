import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_app/routes/workout.dart' as workout_page;

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

  Future<List<Map<WorkoutInfo, List<WorkoutExerciseInfo>>>>
      getRoutineInfo() async {
    List<Map<WorkoutInfo, List<WorkoutExerciseInfo>>> routineInfo = [];

    List<WorkoutInfo> workouts =
        await DatabaseHelper.inst.getWorkoutsForRoutine(widget.routineId);

    for (WorkoutInfo workout in workouts) {
      List<WorkoutExerciseInfo> workoutExercises =
          await DatabaseHelper.inst.getWorkoutExercises(workout.id);

      routineInfo.add({workout: workoutExercises});
    }

    return routineInfo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRoutineInfo(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<WorkoutInfo, List<WorkoutExerciseInfo>>>>
              snapshot) {
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
          body: ReorderableListView.builder(
            padding: const EdgeInsets.all(20),
            onReorder: (int oldIndex, int newIndex) async {
              // don't allow reordering the goals section
              if (oldIndex == 0 || newIndex == 0) return;
              if (oldIndex < newIndex) {
                newIndex--;
              }
              // -1 for goals
              await DatabaseHelper.inst.reorderWorkouts(
                  widget.routineId, oldIndex - 1, newIndex - 1);
              setState(() {});
            },
            itemCount: snapshot.data!.length + 1,
            itemBuilder: (context, i) {
              // goals
              if (i == 0) {
                return ListTile(
                  key: const Key('goals'),
                  contentPadding: EdgeInsets.zero,
                  onLongPress: () {}, // non-reorderable
                  title: Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    margin: const EdgeInsets.only(bottom: 10),
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
                  ),
                );
              }
              WorkoutInfo workoutInfo = snapshot.data![i - 1].keys.single;
              return Workout(
                key: Key(workoutInfo.id.toString()),
                id: workoutInfo.id,
                name: workoutInfo.name,
                workoutExercises: snapshot.data![i - 1].values.single,
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
    required this.workoutExercises,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final List<WorkoutExerciseInfo> workoutExercises;
  final Function reloadPage;

  List<WorkoutExercise> createWorkoutExercises() {
    List<WorkoutExercise> exercises = [];
    for (WorkoutExerciseInfo workoutExercise in workoutExercises) {
      exercises.add(
        WorkoutExercise(
          name: workoutExercise.exerciseName!,
          sets: workoutExercise.sets,
          reps: workoutExercise.reps,
          notes: workoutExercise.notes,
          superset: workoutExercise.superset,
        ),
      );
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0x20FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Slidable(
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
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
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings:
                                  const RouteSettings(name: '/workoutPage'),
                              builder: (context) => workout_page.Workout(
                                workoutId: id,
                                name: name,
                              ),
                            ),
                          );
                          reloadPage();
                        },
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
                  children: createWorkoutExercises(),
                ),
              ),
            ],
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
    required this.superset,
    Key? key,
  }) : super(key: key);

  final String name;
  final String sets;
  final String reps;
  final String notes;
  final int superset;

  @override
  Widget build(BuildContext context) {
    String finalDescription = (notes != '')
        ? '     $sets x $reps\n     $notes'
        : '     $sets x $reps';
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
