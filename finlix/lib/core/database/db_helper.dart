import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';
import '../../models/savings_goal_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finlix.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
        onOpen: (db) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Savings Goals Table
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL,
        emoji TEXT NOT NULL,
        target_date TEXT
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // --- Transactions CRUD ---
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Delete a transaction by its id.
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Savings Goals CRUD ---
  Future<int> insertSavingsGoal(SavingsGoalModel goal) async {
    final db = await instance.database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<List<SavingsGoalModel>> getAllSavingsGoals() async {
    final db = await instance.database;
    final result = await db.query('savings_goals', orderBy: 'id ASC');
    return result.map((json) => SavingsGoalModel.fromMap(json)).toList();
  }

  Future<int> updateSavingsGoal(SavingsGoalModel goal) async {
    final db = await instance.database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await instance.database;
    return await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> topUpSavingsGoal(int id, double additionalAmount) async {
    final db = await instance.database;
    final goals = await db.query('savings_goals', where: 'id = ?', whereArgs: [id]);
    if (goals.isEmpty) return 0;
    final current = (goals.first['current_amount'] as num).toDouble();
    final newAmount = current + additionalAmount;
    return await db.update(
      'savings_goals',
      {'current_amount': newAmount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> seedDefaultSavingsGoalsIfEmpty() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM savings_goals'));
    if (count == null || count == 0) {
      await db.insert('savings_goals', {
        'title': 'Emergency Fund',
        'target_amount': 5000.0,
        'current_amount': 4200.0,
        'emoji': '🛡️',
        'target_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      });
      await db.insert('savings_goals', {
        'title': 'Japan Trip',
        'target_amount': 3500.0,
        'current_amount': 2800.0,
        'emoji': '🌸',
        'target_date': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
      });
      await db.insert('savings_goals', {
        'title': 'Desk Setup',
        'target_amount': 1200.0,
        'current_amount': 950.0,
        'emoji': '💻',
        'target_date': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
      });
      await db.insert('savings_goals', {
        'title': 'Concert Tickets',
        'target_amount': 300.0,
        'current_amount': 300.0,
        'emoji': '🎟️',
        'target_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });
    }
  }

  Future<int> getSavingsGoalsCount() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM savings_goals'));
    return count ?? 0;
  }

  // --- Settings & Preferences CRUD ---
  static bool _settingsTableVerified = false;

  Future<void> _ensureSettingsTable(Database db) async {
    if (_settingsTableVerified) return;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    _settingsTableVerified = true;
  }

  Future<String?> getSetting(String key) async {
    try {
      final db = await instance.database;
      await _ensureSettingsTable(db);
      final res = await db.query('settings', where: 'key = ?', whereArgs: [key]);
      if (res.isNotEmpty) {
        return res.first['value'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('DbHelper getSetting error: $e');
      return null;
    }
  }

  Future<void> setSetting(String key, String value) async {
    try {
      final db = await instance.database;
      await _ensureSettingsTable(db);
      await db.insert(
        'settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('DbHelper setSetting error: $e');
    }
  }

  Future<double> getMonthlyBudget() async {
    final val = await getSetting('monthly_budget');
    if (val != null) {
      final parsed = double.tryParse(val);
      if (parsed != null && parsed > 0) return parsed;
    }
    final curr = await getSetting('currency') ?? 'IDR (Rp)';
    final isIdr = curr.contains('IDR') || curr.contains('Rp');
    return isIdr ? 5000000.0 : 1500.0;
  }

  Future<void> setMonthlyBudget(double budget) async {
    await setSetting('monthly_budget', budget.toString());
  }

  Future<Map<String, String>> getUserProfile() async {
    final name = await getSetting('user_name') ?? '';
    final handle = await getSetting('user_handle') ?? '';
    final email = await getSetting('user_email') ?? '';
    final currency = await getSetting('currency') ?? 'IDR (Rp)';
    final salaryDay = await getSetting('salary_day') ?? '25';
    final biometric = await getSetting('biometric_enabled') ?? 'true';
    final budgetAlert = await getSetting('budget_alert_enabled') ?? 'true';
    final haptics = await getSetting('haptics_enabled') ?? 'true';

    return {
      'user_name': name,
      'user_handle': handle,
      'user_email': email,
      'currency': currency,
      'salary_day': salaryDay,
      'biometric_enabled': biometric,
      'budget_alert_enabled': budgetAlert,
      'haptics_enabled': haptics,
    };
  }

  Future<void> resetAllData() async {
    final db = await instance.database;
    await db.delete('transactions');
    await db.delete('savings_goals');
    await db.delete('settings');
    _settingsTableVerified = false;
    await _ensureSettingsTable(db);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
