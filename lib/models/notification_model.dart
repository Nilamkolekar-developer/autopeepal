class NotificationModel {
  String? title;
  String? body;
  String? technician;
  String? workshop;
  String? model;
  String? address;

  NotificationModel({
    this.title,
    this.body,
    this.technician,
    this.workshop,
    this.model,
    this.address,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        title: json['title'],
        body: json['body'],
        technician: json['technician'],
        workshop: json['workshop'],
        model: json['model'],
        address: json['address'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'technician': technician,
        'workshop': workshop,
        'model': model,
        'address': address,
      };
}

class NotificationM {
  String? title;
  String? body;
  String? technitian;
  String? workshop;
  String? model;

  NotificationM({
    this.title,
    this.body,
    this.technitian,
    this.workshop,
    this.model,
  });

  factory NotificationM.fromJson(Map<String, dynamic> json) => NotificationM(
        title: json['title'],
        body: json['body'],
        technitian: json['technitian'],
        workshop: json['workshop'],
        model: json['model'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'technitian': technitian,
        'workshop': workshop,
        'model': model,
      };
}