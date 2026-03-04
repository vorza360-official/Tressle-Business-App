
// Employee Model
import 'dart:io';

class Employee {
  String id;
  String name;
  String email;
  String phone;
  String designation;
  String workingDays;
  String workingHours;
  String joiningDate;
  String shiftStart;
  String shiftEnd;
  File? profileImage;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.workingDays,
    required this.workingHours,
    required this.joiningDate,
    required this.shiftStart,
    required this.shiftEnd,
    this.profileImage,
  });
}

// Main Employee Management Widget
