import 'package:autopeepal/utils/extension/extension/app_extensions.dart';

class UserInfo {
  String? clientID;
  String? name;
  String? emailID;
  String? phoneNo;
  String? secondaryPhoneNo;

  UserInfo(
      {this.clientID,
      this.name,
      this.emailID,
      this.phoneNo,
      this.secondaryPhoneNo});

  UserInfo.fromJson(Map<String, dynamic> json) {
    clientID = json['ClientID'];
    name = json['Name'];
    emailID = json['EmailID'];
    phoneNo = json['PhoneNo'];
    secondaryPhoneNo = json['SecondaryPhoneNo'];
  }

  factory UserInfo.empty() => UserInfo(
      clientID: defaultString,
      name: defaultString,
      emailID: defaultString,
      phoneNo: defaultString,
      secondaryPhoneNo: defaultString);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClientID'] = this.clientID;
    data['Name'] = this.name;
    data['EmailID'] = this.emailID;
    data['PhoneNo'] = this.phoneNo;
    data['SecondaryPhoneNo'] = this.secondaryPhoneNo;
    return data;
  }
}
