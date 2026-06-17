import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String _key = 'expenses_data';
  static int _nextId = 1;

  DatabaseHelper._init();

  // Load all expenses from SharedPreferences
  Future<List<Expense>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = json.decode(jsonStr);
    final expenses = jsonList.map((e) => Expense.fromMap(e)).toList();

    // Update next ID
    if (expenses.isNotEmpty) {
      final maxId = expenses
          .where((e) => e.id != null)
          .map((e) => e.id!)
          .fold(0, (a, b) => a > b ? a : b);
      _nextId = maxId + 1;
    }

    return expenses;
  }

  // Save all expenses to SharedPreferences
  Future<void> _saveAll(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toMap()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  // CREATE
  Future<Expense> createExpense(Expense expense) async {
    final all = await _loadAll();
    final newExpense = expense.copyWith(id: _nextId++);
    all.add(newExpense);
    await _saveAll(all);
    return newExpense;
  }

  // READ ALL
  Future<List<Expense>> getAllExpenses() async {
    final all = await _loadAll();
    all.sort((a, b) {
      final dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    return all;
  }

  // READ BY DATE (single day)
  Future<List<Expense>> getExpensesByDate(DateTime date) async {
    final all = await _loadAll();
    return all.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // READ BY MONTH
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final all = await _loadAll();
    return all.where((e) {
      return e.date.year == year && e.date.month == month;
    }).toList()
      ..sort((a, b) {
        final dateCmp = b.date.compareTo(a.date);
        if (dateCmp != 0) return dateCmp;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  // UPDATE
  Future<void> updateExpense(Expense expense) async {
    final all = await _loadAll();
    final index = all.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      all[index] = expense;
      await _saveAll(all);
    }
  }

  // DELETE
  Future<void> deleteExpense(int id) async {
    final all = await _loadAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }
}
