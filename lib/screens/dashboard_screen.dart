import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(dateStr),
              SliverToBoxAdapter(
                child: _buildHeroCard(provider),
              ),
              SliverToBoxAdapter(
                child: _buildSummaryGrid(provider),
              ),
              SliverToBoxAdapter(
                child: _buildCategoryBreakdown(provider),
              ),
              SliverToBoxAdapter(
                child: _buildRecentTransactions(provider),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(String dateStr) {
    return SliverAppBar(
      expandedHeight: 0,
      backgroundColor: AppTheme.bgDark,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: AppTheme.bgDark),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran Harian',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            dateStr,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(ExpenseProvider provider) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C58D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Total Hari Ini',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.todayExpenses.length} transaksi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatter.format(provider.todayTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Bulan ini: ${formatter.format(provider.monthTotal)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(ExpenseProvider provider) {
    final categories = provider.todayCategoryTotals;
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori Hari Ini',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final entry = categories.entries.elementAt(index);
              return SummaryCard(
                label: entry.key,
                amount: entry.value,
                icon: AppTheme.getCategoryIcon(entry.key),
                color: AppTheme.getCategoryColor(entry.key),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ExpenseProvider provider) {
    final categories = provider.todayCategoryTotals;
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Pengeluaran',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            ...categories.entries.map(
              (entry) => CategorySummaryRow(
                category: entry.key,
                amount: entry.value,
                total: provider.todayTotal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(ExpenseProvider provider) {
    final expenses = provider.todayExpenses;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaksi Hari Ini',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            _buildEmptyState()
          else
            ...expenses.map(
              (expense) => ExpenseCard(
                expense: expense,
                onDelete: () {
                  context
                      .read<ExpenseProvider>()
                      .deleteExpense(expense.id!);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCardLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppTheme.textHint,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pengeluaran hari ini',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap tombol + untuk menambahkan',
            style: TextStyle(
              color: AppTheme.textHint,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        );
        if (context.mounted) {
          context.read<ExpenseProvider>().loadAll();
        }
      },
      backgroundColor: AppTheme.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Tambah',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
