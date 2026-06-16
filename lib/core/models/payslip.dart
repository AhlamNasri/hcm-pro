class Payslip {
  final String id;
  final String employeeId;
  final int month;
  final int year;
  final double baseSalary;
  final double bonus;
  final double overtime;
  final double transportAllowance;
  final double mealAllowance;
  final double socialSecurity;
  final double incomeTax;
  final double otherDeductions;

  const Payslip({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.baseSalary,
    this.bonus = 0,
    this.overtime = 0,
    this.transportAllowance = 0,
    this.mealAllowance = 0,
    required this.socialSecurity,
    required this.incomeTax,
    this.otherDeductions = 0,
  });

  double get grossSalary =>
      baseSalary + bonus + overtime + transportAllowance + mealAllowance;

  double get totalDeductions => socialSecurity + incomeTax + otherDeductions;

  double get netSalary => grossSalary - totalDeductions;

  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String get period => '$monthName $year';

  factory Payslip.fromFirestore(String id, Map<String, dynamic> data) {
    return Payslip(
      id: id,
      employeeId: data['employeeId'] as String,
      month: (data['month'] as num).toInt(),
      year: (data['year'] as num).toInt(),
      baseSalary: (data['baseSalary'] as num).toDouble(),
      bonus: (data['bonus'] as num?)?.toDouble() ?? 0,
      overtime: (data['overtime'] as num?)?.toDouble() ?? 0,
      transportAllowance: (data['transportAllowance'] as num?)?.toDouble() ?? 0,
      mealAllowance: (data['mealAllowance'] as num?)?.toDouble() ?? 0,
      socialSecurity: (data['socialSecurity'] as num).toDouble(),
      incomeTax: (data['incomeTax'] as num).toDouble(),
      otherDeductions: (data['otherDeductions'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'month': month,
      'year': year,
      'baseSalary': baseSalary,
      'bonus': bonus,
      'overtime': overtime,
      'transportAllowance': transportAllowance,
      'mealAllowance': mealAllowance,
      'socialSecurity': socialSecurity,
      'incomeTax': incomeTax,
      'otherDeductions': otherDeductions,
    };
  }
}

class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double hoursWorked;
  final bool isAbsent;
  final bool isLate;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.hoursWorked,
    this.isAbsent = false,
    this.isLate = false,
  });

  factory AttendanceRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return AttendanceRecord(
      id: id,
      employeeId: data['employeeId'] as String,
      date: DateTime.parse(data['date'] as String),
      checkIn: data['checkIn'] != null ? DateTime.parse(data['checkIn'] as String) : null,
      checkOut: data['checkOut'] != null ? DateTime.parse(data['checkOut'] as String) : null,
      hoursWorked: (data['hoursWorked'] as num).toDouble(),
      isAbsent: data['isAbsent'] as bool? ?? false,
      isLate: data['isLate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'hoursWorked': hoursWorked,
      'isAbsent': isAbsent,
      'isLate': isLate,
    };
  }
}
