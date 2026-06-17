import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildHeader(provider),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMonthlyTab(provider),
                    _buildAllTransactionsTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ExpenseProvider provider) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Laporan',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              _buildMonthSelector(provider),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatter.format(provider.monthTotal),
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            'Total ${DateFormat('MMMM yyyy', 'id_ID').format(provider.selectedMonth)}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(ExpenseProvider provider) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            final prev = DateTime(
              provider.selectedMonth.year,
              provider.selectedMonth.month - 1,
            );
            provider.setSelectedMonth(prev);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: AppTheme.textSecondary, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMM yyyy', 'id_ID').format(provider.selectedMonth),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            final now = DateTime.now();
            if (provider.selectedMonth.year < now.year ||
                provider.selectedMonth.month < now.month) {
              final next = DateTime(
                provider.selectedMonth.year,
                provider.selectedMonth.month + 1,
              );
              provider.setSelectedMonth(next);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textHint,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Grafik Bulanan'),
          Tab(text: 'Semua Transaksi'),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(ExpenseProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (provider.monthCategoryTotals.isNotEmpty) ...[
            _buildPieChart(provider),
            const SizedBox(height: 20),
            _buildCategoryList(provider),
            const SizedBox(height: 20),
            _buildBarChart(provider),
          ] else
            _buildEmptyReport(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPieChart(ExpenseProvider provider) {
    final categories = provider.monthCategoryTotals;
    final sections = <PieChartSectionData>[];
    int i = 0;
    for (final entry in categories.entries) {
      final color = AppTheme.getCategoryColor(entry.key);
      final isTouched = i == _touchedIndex;
      sections.add(
        PieChartSectionData(
          value: entry.value,
          color: color,
          radius: isTouched ? 65 : 55,
          showTitle: false,
          badgeWidget: isTouched
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(entry.value / provider.monthTotal * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1.3,
        ),
      );
      i++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          const Text(
            'Distribusi per Kategori',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.touchedSection != null) {
                        _touchedIndex =
                            response!.touchedSection!.touchedSectionIndex;
                      } else {
                        _touchedIndex = -1;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: categories.keys.map((cat) {
              final color = AppTheme.getCategoryColor(cat);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cat,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ExpenseProvider provider) {
    return Container(
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
            'Rincian per Kategori',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          ...provider.monthCategoryTotals.entries.map(
            (entry) => CategorySummaryRow(
              category: entry.key,
              amount: entry.value,
              total: provider.monthTotal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ExpenseProvider provider) {
    final dailyTotals = provider.monthDailyTotals;
    if (dailyTotals.isEmpty) return const SizedBox.shrink();

    final maxVal = dailyTotals.values.reduce((a, b) => a > b ? a : b);
    final days = dailyTotals.keys.toList()..sort();

    return Container(
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
            'Pengeluaran per Hari',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.bgCardLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final formatter = NumberFormat.compact(locale: 'id_ID');
                      return BarTooltipItem(
                        'Rp ${formatter.format(rod.toY)}',
                        const TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (!days.contains(day)) return const SizedBox();
                        return Text(
                          '$day',
                          style: const TextStyle(
                            color: AppTheme.textHint,
                            fontSize: 10,
                            fontFamily: 'Poppins',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxVal / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: days.map((day) {
                  final amount = dailyTotals[day] ?? 0;
                  return BarChartGroupData(
                    x: day,
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: AppTheme.primary,
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal * 1.2,
                          color: AppTheme.bgCardLight,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTransactionsTab(ExpenseProvider provider) {
    final grouped = provider.expensesByDate;
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return _buildEmptyReport();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final expenses = grouped[date]!;
        final dayTotal =
            expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM', 'id_ID').format(date),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    formatter.format(dayTotal),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            ...expenses.map((expense) => ExpenseCard(
                  expense: expense,
                  onDelete: () {
                    context
                        .read<ExpenseProvider>()
                        .deleteExpense(expense.id!);
                  },
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddExpenseScreen(existingExpense: expense),
                      ),
                    );
                    if (context.mounted) {
                      context.read<ExpenseProvider>().loadAll();
                    }
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _buildEmptyReport() {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppTheme.textHint,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data bulan ini',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
