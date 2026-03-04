class Staff {
  int? id;
  String fullName;
  String email;
  String phoneNumber;
  String designation;
  String workingDays;
  String workingHours;
  String? profilePicture;
  DateTime joiningDate;
  String employeeId;

  Staff({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.designation,
    required this.workingDays,
    required this.workingHours,
    this.profilePicture,
    required this.joiningDate,
    required this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'designation': designation,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'profilePicture': profilePicture,
      'joiningDate': joiningDate.toIso8601String(),
      'employeeId': employeeId,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      designation: map['designation'],
      workingDays: map['workingDays'],
      workingHours: map['workingHours'],
      profilePicture: map['profilePicture'],
      joiningDate: DateTime.parse(map['joiningDate']),
      employeeId: map['employeeId'],
    );
  }
}