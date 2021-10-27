// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';

class NewExercise extends StatefulWidget {
  const NewExercise({Key? key, this.exercise}) : super(key: key);
  final ExerciseInfo? exercise;

  @override
  _NewExerciseState createState() => _NewExerciseState();
}

class _NewExerciseState extends State<NewExercise> {
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      nameController.text = widget.exercise!.name;
      tagSelection = widget.exercise!.tags;
    }
  }

  // int = tag id, bool = selected
  List<int> tagSelection = [];
  Future<List<TagInfo>> getTags() async {
    return await DatabaseHelper.inst.getAllTags();
  }

  void toggleTagSelected(int id) {
    setState(() {
      if (tagSelection.contains(id)) {
        tagSelection.remove(id);
      } else {
        tagSelection.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.exercise == null)
            ? const Text('New Exercise')
            : const Text('Edit Exercise'),
      ),
      body: FutureBuilder(
        future: getTags(),
        builder: (BuildContext context, AsyncSnapshot<List<TagInfo>> snapshot) {
          if (snapshot.hasError) {
            print('Error getting tags: $snapshot.error');
            return const Text('Error getting tags for new exercise page');
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
                    child: Text('Loading...'),
                  )
                ],
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: snapshot.data!
                          .map(
                            (tag) => TagTile(
                              id: tag.id,
                              name: tag.name,
                              color: tag.color,
                              selected: tagSelection.contains(tag.id),
                              toggleTagSelected: toggleTagSelected,
                            ),
                          )
                          .toList()
                          .cast<Widget>(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
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
                            Navigator.pop(context, false);
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
                          child: Text(
                            (widget.exercise == null) ? 'CREATE' : 'UPDATE',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            tagSelection.sort();
                            (widget.exercise == null)
                                ? DatabaseHelper.inst.createExercise(
                                    ExerciseInfo(
                                      name: nameController.text,
                                      tags: tagSelection,
                                    ),
                                  )
                                : DatabaseHelper.inst.updateExercise(
                                    ExerciseInfo(
                                      id: widget.exercise!.id,
                                      name: nameController.text,
                                      tags: tagSelection,
                                    ),
                                  );
                            Navigator.pop(context, true);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
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
