// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';

class NewExercise extends StatefulWidget {
  const NewExercise({Key? key}) : super(key: key);

  @override
  _NewExerciseState createState() => _NewExerciseState();
}

class _NewExerciseState extends State<NewExercise> {
  final nameController = TextEditingController();

  // int = tag id, bool = selected
  Map<int, bool> tagSelection = <int, bool>{};
  Future<List<TagInfo>> getTags() async {
    List<TagInfo> tags = await DatabaseHelper.inst.getAllTags();
    for (TagInfo tag in tags) {
      if (tagSelection[tag.id] == null) {
        tagSelection[tag.id] = false;
      }
    }
    return tags;
  }

  void toggleTagSelected(int id) {
    setState(() => tagSelection[id] = !tagSelection[id]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Exercise'),
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
                              selected: tagSelection[tag.id]!,
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
                          onPressed: () {},
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
                            'CREATE',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {},
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
        color: AppData.availableColors[color],
      ),
      child: TextButton(
        child: Text(
          name,
          style: selected
              ? const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )
              : const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
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
