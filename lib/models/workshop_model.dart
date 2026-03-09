class WorkShopModel {
  String? workshop;
  int? workshopId;

  WorkShopModel({
    this.workshop,
    this.workshopId,
  });

  factory WorkShopModel.fromJson(Map<String, dynamic> json) => WorkShopModel(
        workshop: json['Workshop'],
        workshopId: json['WorkshopId'],
      );

  Map<String, dynamic> toJson() => {
        'Workshop': workshop,
        'WorkshopId': workshopId,
      };
}