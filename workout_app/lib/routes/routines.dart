// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New routine',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, i) {
                return RoutineTile(
                  id: -1,
                  name: 'Routine $i',
                  // showEditRoutineDialog: showEditRoutineDialog,
                  reloadPage: reloadPage,
                );
              },
            ),
          ),
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
  }
}

class RoutineTile extends StatelessWidget {
  const RoutineTile({
    required this.id,
    required this.name,
    // required this.showEditRoutineDialog,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  // final Function showEditRoutineDialog;
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
              onPressed: () {
                // showEditRoutineDialog(
                //   context,
                //   id: id,
                //   oldName: name,
                // );
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
