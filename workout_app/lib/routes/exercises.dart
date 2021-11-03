// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';
import 'package:workout_app/routes/edit_tags.dart';
import 'package:workout_app/routes/new_exercise.dart';
import 'package:workout_app/routes/new_workout_exercise.dart';
import 'package:workout_app/routes/routines.dart';

class Exercises extends StatefulWidget {
  const Exercises({this.addToWorkout = false, this.workoutId = -1, Key? key})
      : super(key: key);

  final bool addToWorkout;
  final int workoutId;

  @override
  _ExercisesState createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  bool filter = false;
  List<int> currentTagsFilter = [];
  String currentSearchString = '';

  Icon currentSearchIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Exercises');

  void toggleTagSelected(int id) {
    setState(() {
      if (currentTagsFilter.contains(id)) {
        currentTagsFilter.remove(id);
      } else {
        currentTagsFilter.add(id);
      }
      filter = currentTagsFilter.isNotEmpty;
    });
  }

  Future<ExercisesAndTags> getExercisesAndTags() async {
    List<TagInfo> tags = await DatabaseHelper.inst.getAllTags();
    return ExercisesAndTags(
      exercises: await DatabaseHelper.inst.getAllExercises(),
      tags: tags,
    );
  }

  void reloadPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
            icon: currentSearchIcon,
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                if (currentSearchIcon.icon == Icons.search) {
                  print('if true');
                  currentSearchIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Exercise name...',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      onChanged: (search) {
                        setState(() => currentSearchString = search);
                      },
                    ),
                  );
                } else {
                  print('else');
                  currentSearchIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Exercises');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New exercise',
            onPressed: () async {
              var reload = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewExercise(),
                ),
              );
              if (reload == true) {
                reloadPage();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.new_label),
            tooltip: 'Edit labels',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditTags(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getExercisesAndTags(),
        builder:
            (BuildContext context, AsyncSnapshot<ExercisesAndTags> snapshot) {
          if (snapshot.hasError) {
            print('Error getting exercises and tags: $snapshot.error');
            return const Text('Error getting exercises and tags');
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
                    child: Text('Getting exercises...'),
                  )
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.exercises.length,
                  itemBuilder: (context, i) {
                    bool satisfiesFilter = true;
                    if (filter) {
                      for (int tag in currentTagsFilter) {
                        if (!snapshot.data!.exercises[i].tags.contains(tag)) {
                          satisfiesFilter = false;
                          break;
                        }
                      }
                    }
                    if (currentSearchString.isNotEmpty &&
                        !snapshot.data!.exercises[i].name
                            .toLowerCase()
                            .contains(currentSearchString)) {
                      satisfiesFilter = false;
                    }
                    if (satisfiesFilter) {
                      return ExerciseTile(
                        id: snapshot.data!.exercises[i].id,
                        name: snapshot.data!.exercises[i].name,
                        reloadPage: reloadPage,
                        tags: snapshot.data!.exercises[i].tags,
                        addToWorkout: widget.addToWorkout,
                        workoutId: widget.workoutId,
                      );
                    }
                    // nothing
                    return const SizedBox();
                  },
                ),
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data!.tags.length,
                  itemBuilder: (context, i) {
                    return TagTile(
                      id: snapshot.data!.tags[i].id,
                      name: snapshot.data!.tags[i].name,
                      color: snapshot.data!.tags[i].color,
                      selected:
                          currentTagsFilter.contains(snapshot.data!.tags[i].id),
                      toggleTagSelected: toggleTagSelected,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: (!widget.addToWorkout)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    child: const Icon(
                      Icons.format_list_bulleted_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Routines(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: const Icon(
                      Icons.fitness_center,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF505050),
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.id,
    required this.name,
    required this.reloadPage,
    required this.tags,
    required this.addToWorkout,
    required this.workoutId,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final Function reloadPage;
  final List<int> tags;
  final bool addToWorkout;
  final int workoutId;

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
            DatabaseHelper.inst.deleteExercise(id);
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
              onPressed: () {
                if (!addToWorkout) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewWorkoutExercise(
                      workoutId: workoutId,
                      exerciseName: name,
                      exercise: ExerciseInfo(
                        id: id,
                        name: name,
                        tags: tags,
                      ),
                    ),
                  ),
                );
              },
              onLongPress: () async {
                var reload = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewExercise(
                      exercise: ExerciseInfo(
                        id: id,
                        name: name,
                        tags: tags,
                      ),
                    ),
                  ),
                );
                if (reload == true) {
                  reloadPage();
                }
              },
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

class TagTile extends StatelessWidget {
  const TagTile({
    Key? key,
    required this.id,
    required this.name,
    required this.color,
    required this.selected,
    required this.toggleTagSelected,
  }) : super(key: key);

  final int id;
  final String name;
  final int color;
  final bool selected;
  final Function toggleTagSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 30,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
        color: AppData.tagColors[color],
      ),
      child: TextButton(
        child: Text(
          name,
          style: TextStyle(
            color: Colors.black,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          padding: MaterialStateProperty.resolveWith(
            (states) => const EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
        onPressed: () => toggleTagSelected(id),
      ),
    );
  }
}

class ExercisesAndTags {
  List<ExerciseInfo> exercises;
  List<TagInfo> tags;

  ExercisesAndTags({required this.exercises, required this.tags});
}
