import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditTags extends StatefulWidget {
  const EditTags({Key? key}) : super(key: key);

  @override
  _EditTagsState createState() => _EditTagsState();
}

class _EditTagsState extends State<EditTags> {
  Color currentColor = Colors.lightBlue;
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

  void onColorChanged(Color color) => setState(() => currentColor = color);

  Future<void> _showEditTagDialog(context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Tag'),
          content: Column(
            children: [
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: ListView(
                  children: [
                    BlockPicker(
                      pickerColor: currentColor,
                      onColorChanged: onColorChanged,
                      availableColors: availableColors,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tags'),
      ),
      body: ListView(
        children: <Widget>[
          Slidable(
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
                    onPressed: () => _showEditTagDialog(context),
                    child: const Text(
                      'tag name',
                      style: TextStyle(
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
                        color: Colors.lightBlue,
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
          ),
          // TagTile(id: 0, name: 'Push', color: Color(0xFF9BA1FF)),
          // TagTile(id: 1, name: 'Pull', color: Color(0xFFFFF3AB)),
          // TagTile(id: 2, name: 'Horizontal', color: Color(0xFFFF9FCE)),
        ],
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
  }) : super(key: key);

  final int id;
  final String name;
  final Color color;

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
              onPressed: () => {}, //_showEditTagDialog(context),
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
