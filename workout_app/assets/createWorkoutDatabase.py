import sqlite3
from sqlite3 import Error

default_exercises = [
    # horizontal pushing
    {"tags": [1, 3, 5], "name": "Push Up"},
    {"tags": [1, 3, 5], "name": "Wide Push Up"},
    {"tags": [1, 3, 5], "name": "Diamond Push Up"},
    {"tags": [1, 3, 5], "name": "Explosive Push Up"},
    {"tags": [1, 3, 5], "name": "Pseudo Planche Push Up"},
    {"tags": [1, 3, 5], "name": "Tuck Planche Push Up"},
    {"tags": [1, 3, 5], "name": "Archer Push Up"},
    {"tags": [1, 3, 5], "name": "Planche Lean"},
    {"tags": [1, 3, 5], "name": "Tuck Planche"},
    # vertical pushing
    {"tags": [1, 3, 6], "name": "Pike Push Up"},
    {"tags": [1, 3, 6], "name": "BTW Handstand Push Up"},
    {"tags": [1, 3, 6], "name": "CTW Handstand Push Up"},
    {"tags": [1, 3, 6], "name": "Handstand Push Up Eccentric"},
    {"tags": [1, 3, 6], "name": "Handstand Push Up"},
    # vertical pulling
    {"tags": [1, 4, 6], "name": "Pull Up"},
    {"tags": [1, 4, 6], "name": "Wide Pull Up"},
    {"tags": [1, 4, 6], "name": "Close Grip Pull Up"},
    {"tags": [1, 4, 6], "name": "L-Sit Pull Up"},
    {"tags": [1, 4, 6], "name": "Chin Up"},
    {"tags": [1, 4, 6], "name": "Close Grip Chin Up"},
    {"tags": [1, 4, 6], "name": "L-Sit Chin Up"},
    # horizontal pulling
    {"tags": [1, 4, 5], "name": "Inverted Row"},
    {"tags": [1, 4, 5], "name": "Front Lever"},
    {"tags": [1, 4, 5], "name": "Straddle Front Lever"},
    {"tags": [1, 4, 5], "name": "Tuck Front Lever"},
    {"tags": [1, 4, 5], "name": "Advanced Tuck Front Lever"},
    {"tags": [1, 4, 5], "name": "Front Lever Ring Raise"},
    {"tags": [1, 4, 5], "name": "Tuck Front Lever Row"},
    {"tags": [1, 4, 5], "name": "Advanced Tuck Front Lever Row"},
    {"tags": [1, 4, 5], "name": "Front Lever Raise"}
  ];

def connect(db_name):
    try:
        conn = sqlite3.connect(db_name)

        insert_exercises(conn)
    except Error as e:
        print('caught error:')
        print(e)
    finally:
        if conn:
            conn.close()


def insert_exercises(conn):
    cur = conn.cursor()

    # start from scratch
    print('deleting current exercises and exerciseTags...')
    cur.execute('DELETE FROM exercises')
    cur.execute('DELETE FROM exerciseTags')

    print("inserting exercises...")
    for exercise in default_exercises:
        sql = f"INSERT INTO exercises(name) VALUES (?)"
        cur.execute(sql, [exercise['name']])
        exercise_id = cur.lastrowid
        for tag in exercise["tags"]:
            sql = f"INSERT INTO exerciseTags(exerciseId, tagId) VALUES(?,?)"
            cur.execute(sql, [exercise_id, tag])
    conn.commit()


if __name__ == "__main__":
    connect("D:\\1_ComputerScience\\0_Coding\\Flutter\\Workout App\\App\\workout_app\\assets\\workoutAppDb.db")
