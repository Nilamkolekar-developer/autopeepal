// ---------------- WorkShopGroupModel ----------------
class WorkShopGroupModel {
  String? workshopsGroupName;
  List<WorkCity> cityList;

  WorkShopGroupModel({
    this.workshopsGroupName,
    List<WorkCity>? cityList,
  }) : cityList = cityList ?? [];

  factory WorkShopGroupModel.fromJson(Map<String, dynamic> json) =>
      WorkShopGroupModel(
        workshopsGroupName: json['workshopsGroupName'],
        cityList: (json['CityList'] as List<dynamic>?)
                ?.map((e) => WorkCity.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'workshopsGroupName': workshopsGroupName,
        'CityList': cityList.map((e) => e.toJson()).toList(),
      };
}

// ---------------- WorkCity ----------------
class WorkCity {
  String? city;
  List<WorkShopGroup> workshops;

  WorkCity({
    this.city,
    List<WorkShopGroup>? workshops,
  }) : workshops = workshops ?? [];

  factory WorkCity.fromJson(Map<String, dynamic> json) => WorkCity(
        city: json['city'],
        workshops: (json['workshops'] as List<dynamic>?)
                ?.map((e) => WorkShopGroup.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'city': city,
        'workshops': workshops.map((e) => e.toJson()).toList(),
      };
}

// ---------------- WorkShopGroup ----------------
class WorkShopGroup {
  String? pincode;
  String? name1;
  String? region;
  String? address;
  String? created;
  String? modified;
  int? id;
  int? cityId;
  int? oemId;
  int? parentId;
  bool? isActive;
  int? userId;
  int? groupNameId;
  int? stateId;
  int? countryId;
  String? name;

  WorkShopGroup({
    this.pincode,
    this.name1,
    this.region,
    this.address,
    this.created,
    this.modified,
    this.id,
    this.cityId,
    this.oemId,
    this.parentId,
    this.isActive,
    this.userId,
    this.groupNameId,
    this.stateId,
    this.countryId,
    this.name,
  });

  factory WorkShopGroup.fromJson(Map<String, dynamic> json) => WorkShopGroup(
        pincode: json['pincode'],
        name1: json['name1'],
        region: json['region'],
        address: json['address'],
        created: json['created'],
        modified: json['modified'],
        id: json['id'],
        cityId: json['city_id'],
        oemId: json['oem_id'],
        parentId: json['parent_id'],
        isActive: json['is_active'],
        userId: json['user_id'],
        groupNameId: json['group_name_id'],
        stateId: json['state_id'],
        countryId: json['country_id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'pincode': pincode,
        'name1': name1,
        'region': region,
        'address': address,
        'created': created,
        'modified': modified,
        'id': id,
        'city_id': cityId,
        'oem_id': oemId,
        'parent_id': parentId,
        'is_active': isActive,
        'user_id': userId,
        'group_name_id': groupNameId,
        'state_id': stateId,
        'country_id': countryId,
        'name': name,
      };
}