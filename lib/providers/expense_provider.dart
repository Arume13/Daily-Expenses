import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Expense> _allExpenses = [];
  List<Expense> _todayExpenses = [];
  List<Expense> _monthExpenses = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();

  List<Expense> get allExpenses => _allExpenses;
  List<Expense> get todayExpenses => _todayExpenses;
  List<Expense> get monthExpenses => _monthExpenses;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  // Today's total
  double get todayTotal =>
      _todayExpenses.fold(0, (sum, e) => sum + e.amount);

  // This month's total
  double get monthTotal =>
      _monthExpenses.fold(0, (sum, e) => sum + e.amount);

  // Total per category (for today)
  Map<String, double> get todayCategoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _todayExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  // Total per category (for selected month)
  Map<String, double> get monthCategoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _monthExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  // Daily breakdown for selected month (day -> total)
  Map<int, double> get monthDailyTotals {
    final Map<int, double> totals = {};
    for (final expense in _monthExpenses) {
      final day = expense.date.day;
      totals[day] = (totals[day] ?? 0) + expense.amount;
    }
    return totals;
  }

  // Group expenses by date for display
  Map<DateTime, List<Expense>> get expensesByDate {
    final Map<DateTime, List<Expense>> grouped = {};
    for (final expense in _monthExpenses) {
      final date = DateTime(
          expense.date.year, expense.date.month, expense.date.day);
      grouped[date] = [...(grouped[date] ?? []), expense];
    }
    return grouped;
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    _todayExpenses = await _dbHelper.getExpensesByDate(now);
    _monthExpenses = await _dbHelper.getExpensesByMonth(
        _selectedMonth.year, _selectedMonth.month);
    _allExpenses = await _dbHelper.getAllExpenses();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _dbHelper.createExpense(expense);
    await loadAll();
  }

  Future<void> deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
    await loadAll();
  }

  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense);
    await loadAll();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    _dbHelper
        .getExpensesByMonth(month.year, month.month)
        .then((expenses) {
      _monthExpenses = expenses;
      notifyListeners();
    });
  }
}
