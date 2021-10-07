// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/Data/db_helper.dart';

class EditTags extends StatefulWidget {
  const EditTags({Key? key}) : super(key: key);

  @override
  _EditTagsState createState() => _EditTagsState();
}

class _EditTagsState extends State<EditTags> {
  final int colorsInRow = 5;

  void reloadPage() {
    setState(() {});
  }

  // id=-1 means new tag
  Future<void> showEditTagDialog(
    context, {
    int id = -1,
    String? oldName,
    Color currentColor = const Color(0xFF9BA1FF),
  }) async {
    final nameController = (id == -1)
        ? TextEditingController()
        : TextEditingController(text: oldName);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                const Text(
                  'Edit Tag',
                  textAlign: TextAlign.left,
                  style: TextStyle(
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
                BlockPicker(
                  pickerColor: currentColor,
                  onColorChanged: (Color color) =>
                      setState(() => currentColor = color),
                  availableColors: AppData.availableColors,
                  layoutBuilder: (BuildContext context, List<Color> colors,
                      PickerItem child) {
                    return SizedBox(
                      width: 300,
                      height: colors.length / colorsInRow * 70,
                      child: GridView.count(
                        crossAxisCount: colorsInRow,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        children:
                            colors.map((Color color) => child(color)).toList(),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF90CAF9),
                    ),
                  ),
                  onPressed: () {
                    final name = nameController.text;
                    // edit existing
                    if (id != -1) {
                      DatabaseHelper.inst.updateTag(
                        TagInfo(
                          id: id,
                          name: name,
                          color: AppData.colorToIndex(currentColor),
                        ),
                      );
                    }
                    // create new tag
                    else {
                      DatabaseHelper.inst.createTag(
                        TagInfo(
                          name: name,
                          color: AppData.colorToIndex(currentColor),
                        ),
                      );
                    }
                    // instead of pop so the FutureBuilder reloads
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New tag',
            onPressed: () {
              showEditTagDialog(context, id: -1);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: DatabaseHelper.inst.getAllTags(),
        builder: (BuildContext context, AsyncSnapshot<List<TagInfo>> snapshot) {
          if (snapshot.hasError) {
            print('Error getting tags: $snapshot.error');
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
                    child: Text('Getting tags...'),
                  )
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              return TagTile(
                id: snapshot.data![i].id,
                name: snapshot.data![i].name,
                color: AppData.availableColors[snapshot.data![i].color],
                showEditTagDialog: showEditTagDialog,
                reloadPage: reloadPage,
              );
            },
          );
        },
      ),
    );
  }
}

class TagTile extends StatelessWidget {
  const TagTile({
    required this.id,
    required this.name,
    required this.color,
    required this.showEditTagDialog,
    required this.reloadPage,
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final Color color;
  final Function showEditTagDialog;
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
            DatabaseHelper.inst.deleteTag(id);
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
                showEditTagDialog(
                  context,
                  id: id,
                  oldName: name,
                  currentColor: color,
                );
              },
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            // tag colour circle
            Positioned(
              left: 10,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100),
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
