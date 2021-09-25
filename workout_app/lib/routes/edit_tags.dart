import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditTags extends StatefulWidget {
  const EditTags({Key? key}) : super(key: key);

  @override
  _EditTagsState createState() => _EditTagsState();
}

class _EditTagsState extends State<EditTags> {
  List<Color> availableColors = const [
    Color(0xFF9BA1FF),
    Color(0xFFFFF3AB),
    Color(0xFFFF9FCE),
    Color(0xFFA9F5FF),
    Color(0xFFBD8261),
    Color(0xFFA7BC54),
    Color(0xFFC52DB5),
    Color(0xFFCFA9FF),
    Color(0xFFD37F31),
  ];
  final int colorsInRow = 5;

  // id=-1 means new tag
  Future<void> showEditTagDialog(context,
      {int id = -1,
      String? oldName,
      Color currentColor = const Color(0xFF9BA1FF)}) async {
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
                  availableColors: availableColors,
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
                    // ignore: avoid_print
                    print(name);
                    // edit existing
                    if (id != -1) {
                    }
                    // create new
                    else {}
                    Navigator.of(context).pop();
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
      body: ListView(
        children: <Widget>[
          TagTile(
            id: 0,
            name: 'Push',
            color: const Color(0xFF9BA1FF),
            showEditTagDialog: showEditTagDialog,
          ),
          TagTile(
            id: 1,
            name: 'Pull',
            color: const Color(0xFFFFF3AB),
            showEditTagDialog: showEditTagDialog,
          ),
          TagTile(
            id: 2,
            name: 'Horizontal',
            color: const Color(0xFFFF9FCE),
            showEditTagDialog: showEditTagDialog,
          ),
        ],
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
    Key? key,
  }) : super(key: key);

  final int id;
  final String name;
  final Color color;
  final Function showEditTagDialog;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: const SlidableScrollActionPane(),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {},
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
