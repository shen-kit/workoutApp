import 'package:flutter/material.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

import 'package:workout_app/Data/db_helper.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // delete database
          TextButton(
            child: const ListTile(
              title: Text(
                'Reset Database',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              trailing: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (await confirm(
                context,
                title: const Text('Reset the database?'),
                content: const Text(
                    'This action cannot be undone\n\nRestart the app immediately after to avoid errors'),
              )) {
                DatabaseHelper.inst.deleteDb();
              }
            },
          ),
        ],
      ),
    );
  }
}
