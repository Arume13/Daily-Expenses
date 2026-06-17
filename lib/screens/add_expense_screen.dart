import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = ExpenseCategory.makan;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      _titleController.text = e.title;
      _amountController.text = e.amount.toStringAsFixed(0);
      _noteController.text = e.note ?? '';
      _selectedCategory = e.category;
      _selectedDate = e.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.bgCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final expense = Expense(
      id: widget.existingExpense?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.replaceAll('.', '')),
      category: _selectedCategory,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _selectedDate,
    );

    final provider = context.read<ExpenseProvider>();
    if (widget.existingExpense != null) {
      await provider.updateExpense(expense);
    } else {
      await provider.addExpense(expense);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingExpense != null
                ? 'Pengeluaran berhasil diperbarui!'
                : 'Pengeluaran berhasil ditambahkan!',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExpense != null;
    final color = AppTheme.getCategoryColor(_selectedCategory);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          isEditing ? 'Edit Pengeluaran' : 'Tambah Pengeluaran',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input Hero
              _buildAmountInput(color),
              const SizedBox(height: 24),

              // Category Selection
              _buildSectionLabel('Kategori'),
              const SizedBox(height: 12),
              _buildCategoryGrid(),
              const SizedBox(height: 24),

              // Title Input
              _buildSectionLabel('Nama Pengeluaran'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontFamily: 'Poppins'),
                decoration: const InputDecoration(
                  hintText: 'Contoh: Makan siang, Bensin...',
                  prefixIcon: Icon(Icons.edit_note_rounded,
                      color: AppTheme.textSecondary),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              _buildSectionLabel('Tanggal'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                            .format(_selectedDate),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note Input
              _buildSectionLabel('Catatan (Opsional)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontFamily: 'Poppins'),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.notes_rounded,
                        color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Simpan Perubahan' : 'Simpan Pengeluaran',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Nominal Pengeluaran',
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp ',
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.white30,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Masukkan nominal yang valid';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ExpenseCategory.all.map((category) {
        return CategoryChip(
          category: category,
          isSelected: _selectedCategory == category,
          onTap: () => setState(() => _selectedCategory = category),
        );
      }).toList(),
    );
  }
}
