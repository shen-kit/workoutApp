import 'package:flutter/material.dart';

class Routine extends StatefulWidget {
  const Routine({Key? key}) : super(key: key);

  @override
  _RoutineState createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  final String name = 'routineName';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New routine',
            onPressed: () {}, //showEditWorkoutDialog(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          // goals
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0x20FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: const [
                SizedBox(height: 20),
                Text(
                  'GOALS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 1,
                  child: Divider(
                    thickness: 1,
                    color: Color(0xFF40C0DC),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '5 x BTW HSPU Minimal Arch\n10s x 60cm Planche Lean\n10s x 2 Finger Assisted OAHS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
          // upper
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0x20FFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: [
                // title row (title + edit button)
                SizedBox(
                  height: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'UPPER',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              height: 1,
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFF40C0DC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          splashRadius: 24,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  // width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise 1
                      const Text(
                        '1. Ring Front Lever Raise',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                      Text(
                        (' ' * 5) +
                            '4 x 4-6\n' +
                            (' ' * 5) +
                            'Full scapula retraction',
                        style: const TextStyle(
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                      // Exercise 2
                      const Text(
                        '1. BTW Handstand Push Up',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                      Text(
                        (' ' * 5) +
                            '4 x 3-5\n' +
                            (' ' * 5) +
                            'One foot off wall',
                        style: const TextStyle(
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                      // Exercise 3
                      const Text(
                        '2. Band Assisted One Arm Chin Up',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                      Text(
                        (' ' * 5) + '3 x 3-4\n' + (' ' * 5) + 'Blue band',
                        style: const TextStyle(
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                      // Exercise 4
                      const Text(
                        '2. Planche Lean',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          height: 2,
                        ),
                      ),
                      Text(
                        (' ' * 5) + '3 x 10s',
                        style: const TextStyle(
                          color: Color(0x80FFFFFF),
                        ),
                      ),
                    ],
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
