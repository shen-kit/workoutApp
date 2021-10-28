import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';

class NewWorkoutExercise extends StatefulWidget {
  const NewWorkoutExercise({
    this.workoutId,
    this.exercise,
    this.workoutExercise,
    required this.exerciseName,
    Key? key,
  }) : super(key: key);

  final int? workoutId;
  final ExerciseInfo? exercise;
  final WorkoutExerciseInfo? workoutExercise;

  final String exerciseName;

  @override
  _NewWorkoutExerciseState createState() => _NewWorkoutExerciseState();
}

class _NewWorkoutExerciseState extends State<NewWorkoutExercise> {
  TextEditingController setsController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController supersetController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  final double textFieldWidth = 160;

  @override
  void initState() {
    // new exercise
    if (widget.workoutExercise != null) {
      setsController.text = widget.workoutExercise!.sets;
      repsController.text = widget.workoutExercise!.reps;
      weightController.text = widget.workoutExercise!.weight;
      supersetController.text = widget.workoutExercise!.superset.toString();
      notesController.text = widget.workoutExercise!.notes;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add to Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // sets+reps row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    // maxLength: 5,
                    decoration: const InputDecoration(
                      hintText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Reps (.. for time)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // weight+superset row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    // maxLength: 5,
                    decoration: const InputDecoration(
                      hintText: 'Weight',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: supersetController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Superset',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: notesController,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              // maxLength: 5,
              decoration: const InputDecoration(
                hintText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            // push buttons to the bottom of the screen
            const Expanded(child: SizedBox()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  height: 50,
                  width: 160,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.red,
                  ),
                  child: TextButton(
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.zero,
                  height: 50,
                  width: 160,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Color(0xFF40C0DC),
                  ),
                  child: TextButton(
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      String weight = (weightController.text.isEmpty)
                          ? '0'
                          : weightController.text;

                      String reps = (repsController.text.endsWith('..'))
                          ? repsController.text.replaceAll('..', 's')
                          : repsController.text;

                      if (setsController.text == '' ||
                          setsController.text == '' ||
                          supersetController.text == '') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'An Error Occurred: Please check all inputs are valid',
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        if (widget.workoutExercise == null) {
                          WorkoutExerciseInfo info = WorkoutExerciseInfo(
                            workoutId: widget.workoutId!,
                            exerciseId: widget.exercise!.id,
                            sets: setsController.text,
                            reps: reps,
                            notes: notesController.text,
                            weight: weight,
                            superset: int.parse(supersetController.text),
                          );
                          await DatabaseHelper.inst.createWorkoutExercise(info);
                        } else {
                          WorkoutExerciseInfo info = WorkoutExerciseInfo(
                            id: widget.workoutExercise!.id,
                            workoutId: widget.workoutExercise!.workoutId,
                            exerciseId: widget.workoutExercise!.exerciseId,
                            sets: setsController.text,
                            reps: reps,
                            notes: notesController.text,
                            weight: weight,
                            superset: int.parse(supersetController.text),
                          );
                          await DatabaseHelper.inst.updateWorkoutExercise(info);
                        }
                        Navigator.of(context).popUntil(
                          ModalRoute.withName('/workoutPage'),
                        );
                      } catch (err) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'An Error Occurred: Please check all inputs are valid',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
