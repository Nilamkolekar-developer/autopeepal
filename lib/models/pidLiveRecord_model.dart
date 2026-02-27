// ---------------- YAxisPointName ----------------
class YAxisPointName {
  String? pidName;
  List<String> value;

  YAxisPointName({
    this.pidName,
    List<String>? value,
  }) : value = value ?? [];

  factory YAxisPointName.fromJson(Map<String, dynamic> json) => YAxisPointName(
        pidName: json['pid_name'],
        value: json['value'] != null
            ? List<String>.from(json['value'])
            : [],
      );

  Map<String, dynamic> toJson() => {
        'pid_name': pidName,
        'value': value,
      };
}

// ---------------- PidLive ----------------
class PidLive {
  List<String> xAxisPoint;
  List<YAxisPointName> yAxisPointName;

  PidLive({
    List<String>? xAxisPoint,
    List<YAxisPointName>? yAxisPointName,
  })  : xAxisPoint = xAxisPoint ?? [],
        yAxisPointName = yAxisPointName ?? [];

  factory PidLive.fromJson(Map<String, dynamic> json) => PidLive(
        xAxisPoint: json['x_axis_point'] != null
            ? List<String>.from(json['x_axis_point'])
            : [],
        yAxisPointName: json['y_axis_point_name'] != null
            ? List<YAxisPointName>.from(
                json['y_axis_point_name']
                    .map((e) => YAxisPointName.fromJson(e)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'x_axis_point': xAxisPoint,
        'y_axis_point_name':
            yAxisPointName.map((e) => e.toJson()).toList(),
      };
}

// ---------------- PIDLiveRecord ----------------
class PIDLiveRecord {
  List<PidLive> pidLive;

  PIDLiveRecord({List<PidLive>? pidLive})
      : pidLive = pidLive ?? [];

  factory PIDLiveRecord.fromJson(Map<String, dynamic> json) => PIDLiveRecord(
        pidLive: json['pid_live'] != null
            ? List<PidLive>.from(
                json['pid_live'].map((e) => PidLive.fromJson(e)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'pid_live': pidLive.map((e) => e.toJson()).toList(),
      };
}