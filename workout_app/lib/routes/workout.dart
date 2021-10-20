// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Exercise',
            onPressed: () {},
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(20),
        onReorder: (int oldIndex, int newIndex) async {
          if (oldIndex < newIndex) {
            newIndex--;
          }
          print('exercise $oldIndex moved to postion $newIndex');
          // await DatabaseHelper.inst
          //     .reorderexercises(widget.workoutId, oldIndex, newIndex);
          // setState(() {});
        },
        itemCount: 3,
        itemBuilder: (context, i) {
          return Exercise(
            key: Key(i.toString()),
            id: i,
            name: 'Front Lever Ring Raise',
            sets: '4',
            reps: '3-5',
            reloadPage: () {
              setState(() {});
            },
          );
        },
      ),
    );
  }
}

class Exercise extends StatelessWidget {
  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final String sets;
  final String reps;
  final Function reloadPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
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
                        color: AppData.supersetColors[1],
                      ),
                      child: const Center(child: Text('1')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text('Full scapula retraction'),
            const SizedBox(height: 10),
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
                      children: const [
                        Text(
                          'SETS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text('4'),
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
                      children: const [
                        Text(
                          'REPS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text('4-6'),
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
                      children: const [
                        Text(
                          'WEIGHT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text('0kg'),
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
    );
  }
}
