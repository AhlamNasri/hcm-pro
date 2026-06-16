import 'package:flutter/material.dart';

enum Department { hr, it, finance, marketing, operations, sales, legal }

enum EmployeeStatus { active, onLeave, inactive }

enum ContractType { cdi, cdd, intern, freelance }

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String position;
  final Department department;
  final EmployeeStatus status;
  final ContractType contractType;
  final DateTime hireDate;
  final double salary;
  final String managerId;
  final String avatarColor;
  final int leaveBalance;
  final double performanceScore;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.status,
    required this.contractType,
    required this.hireDate,
    required this.salary,
    required this.managerId,
    required this.avatarColor,
    required this.leaveBalance,
    required this.performanceScore,
  });

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName[0]}${lastName[0]}'.toUpperCase();

  Color get avatarColorValue => Color(int.parse('0xFF$avatarColor'));

  String get departmentLabel {
    switch (department) {
      case Department.hr:
        return 'Human Resources';
      case Department.it:
        return 'Information Technology';
      case Department.finance:
        return 'Finance';
      case Department.marketing:
        return 'Marketing';
      case Department.operations:
        return 'Operations';
      case Department.sales:
        return 'Sales';
      case Department.legal:
        return 'Legal';
    }
  }

  Employee copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? position,
    EmployeeStatus? status,
    int? leaveBalance,
    double? performanceScore,
  }) {
    return Employee(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department,
      status: status ?? this.status,
      contractType: contractType,
      hireDate: hireDate,
      salary: salary,
      managerId: managerId,
      avatarColor: avatarColor,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      performanceScore: performanceScore ?? this.performanceScore,
    );
  }

  String get contractLabel {
    switch (contractType) {
      case ContractType.cdi:
        return 'CDI';
      case ContractType.cdd:
        return 'CDD';
      case ContractType.intern:
        return 'Intern';
      case ContractType.freelance:
        return 'Freelance';
    }
  }

  factory Employee.fromFirestore(String id, Map<String, dynamic> data) {
    return Employee(
      id: id,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      position: data['position'] as String,
      department: Department.values.byName(data['department'] as String),
      status: EmployeeStatus.values.byName(data['status'] as String),
      contractType: ContractType.values.byName(data['contractType'] as String),
      hireDate: DateTime.parse(data['hireDate'] as String),
      salary: (data['salary'] as num).toDouble(),
      managerId: data['managerId'] as String? ?? '',
      avatarColor: data['avatarColor'] as String,
      leaveBalance: (data['leaveBalance'] as num).toInt(),
      performanceScore: (data['performanceScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department.name,
      'status': status.name,
      'contractType': contractType.name,
      'hireDate': hireDate.toIso8601String(),
      'salary': salary,
      'managerId': managerId,
      'avatarColor': avatarColor,
      'leaveBalance': leaveBalance,
      'performanceScore': performanceScore,
    };
  }
}
