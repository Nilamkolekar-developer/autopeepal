class UserModelRememberIsChecked {
  String? username;
  String? password;
  String? macId;
  String? deviceType;
  bool? rememberIsChecked;

  UserModelRememberIsChecked({
     this.username,
     this.password,
     this.macId,
     this.deviceType,
     this.rememberIsChecked,
  });

  // JSON deserialization
  factory UserModelRememberIsChecked.fromJson(Map<String, dynamic> json) {
    return UserModelRememberIsChecked(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      macId: json['mac_id'] ?? '',
      deviceType: json['device_type'] ?? '',
      rememberIsChecked: json['RememberIsChecked'] ?? false,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'mac_id': macId,
      'device_type': deviceType,
      'RememberIsChecked': rememberIsChecked,
    };
  }
}