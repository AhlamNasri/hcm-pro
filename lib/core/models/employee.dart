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
}
