import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/subtask.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasking.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );

    return _database!;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parentTaskId INTEGER NOT NULL,
        name TEXT NOT NULL,
        isValid INTEGER NOT NULL,
        FOREIGN KEY(parentTaskId) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_state (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  String formatDbDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$year-$month-$day';
  }

  Future<void> cleanupOldDoneTasks() async {
    final db = await database;
    final limitDate = DateTime.now().subtract(const Duration(days: 30));
    await db.delete(
      'tasks',
      where: 'status = ? AND date < ?',
      whereArgs: ['done', formatDbDate(limitDate)],
    );
  }

  Future<void> resetDailyCounterIfNeeded() async {
    final db = await database;
    final today = formatDbDate(DateTime.now());

    final result = await db.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['counter_date'],
      limit: 1,
    );

    if (result.isEmpty || result.first['value'] != today) {
      await db.insert(
        'app_state',
        {'key': 'counter_date', 'value': today},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await db.insert(
        'app_state',
        {'key': 'valid_today', 'value': '0'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> getValidTodayCount() async {
    await resetDailyCounterIfNeeded();

    final db = await database;
    final result = await db.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['valid_today'],
      limit: 1,
    );

    if (result.isEmpty) return 0;
    return int.tryParse(result.first['value'].toString()) ?? 0;
  }

  Future<void> incrementValidToday() async {
    await resetDailyCounterIfNeeded();

    final db = await database;
    final current = await getValidTodayCount();

    await db.insert(
      'app_state',
      {'key': 'valid_today', 'value': (current + 1).toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getRemainCount() async {
    final db = await database;
    final today = formatDbDate(DateTime.now());

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM tasks
      WHERE status != ? AND date <= ?
      ''',
      ['done', today],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Task>> getActualTasks() async {
    final db = await database;
    final today = formatDbDate(DateTime.now());

    final result = await db.query(
      'tasks',
      where: 'status != ? AND date <= ?',
      whereArgs: ['done', today],
      orderBy: 'date ASC, id DESC',
    );

    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> getIncomingTasks() async {
    final db = await database;
    final today = formatDbDate(DateTime.now());

    final result = await db.query(
      'tasks',
      where: 'status != ? AND date > ?',
      whereArgs: ['done', today],
      orderBy: 'date ASC, id DESC',
    );

    return result.map(Task.fromMap).toList();
  }

  Future<List<Task>> getDoneTasks() async {
    final db = await database;

    final result = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: ['done'],
      orderBy: 'date DESC, id DESC',
    );

    return result.map(Task.fromMap).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(Task task) async {
    final db = await database;

    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markTaskDone(Task task) async {
    if (task.status == 'done') return;

    await updateTask(task.copyWith(status: 'done'));
    await incrementValidToday();
  }

  Future<List<Subtask>> getSubtasks(int parentTaskId) async {
    final db = await database;

    final result = await db.query(
      'subtasks',
      where: 'parentTaskId = ?',
      whereArgs: [parentTaskId],
      orderBy: 'id ASC',
    );

    return result.map(Subtask.fromMap).toList();
  }

  Future<int> insertSubtask(Subtask subtask) async {
    final db = await database;
    return db.insert('subtasks', subtask.toMap());
  }

  Future<void> updateSubtask(Subtask subtask) async {
    final db = await database;

    await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<void> deleteSubtask(int id) async {
    final db = await database;
    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
}