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
}
