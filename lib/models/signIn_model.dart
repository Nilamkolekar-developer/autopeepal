class SigninModel {
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? password;
  String? password2;
  String? deviceType;
  int? workshop;
  String? macId;
  String? serialNumber;

  SigninModel({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.password2,
    this.deviceType,
    this.workshop,
    this.macId,
    this.serialNumber,
  });

  factory SigninModel.fromJson(Map<String, dynamic> json) => SigninModel(
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        mobile: json['mobile'],
        password: json['password'],
        password2: json['password2'],
        deviceType: json['device_type'],
        workshop: json['workshop'],
        macId: json['mac_id'],
        serialNumber: json['serial_number'],
      );

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'password2': password2,
        'device_type': deviceType,
        'workshop': workshop,
        'mac_id': macId,
        'serial_number': serialNumber,
      };
}