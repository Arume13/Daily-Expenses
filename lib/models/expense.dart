class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ExpenseCategory {
  static const String makan = 'Makan';
  static const String belanja = 'Belanja';
  static const String kebutuhan = 'Kebutuhan';
  static const String transportasi = 'Transportasi';
  static const String hiburan = 'Hiburan';
  static const String lainnya = 'Lainnya';

  static List<String> get all => [
        makan,
        belanja,
        kebutuhan,
        transportasi,
        hiburan,
        lainnya,
      ];
}
