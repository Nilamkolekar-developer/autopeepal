class ConnectionCondition {
  bool? isLengthFFF;
  bool? isChannels;
  String? channelId;
  bool? isCH340;

  ConnectionCondition({
    this.isLengthFFF,
    this.isChannels,
    this.channelId,
    this.isCH340,
  });

  factory ConnectionCondition.fromJson(Map<String, dynamic> json) => ConnectionCondition(
        isLengthFFF: json['IsLengthFFF'],
        isChannels: json['IsChannels'],
        channelId: json['ChannelId'],
        isCH340: json['IsCH340'],
      );

  Map<String, dynamic> toJson() => {
        'IsLengthFFF': isLengthFFF,
        'IsChannels': isChannels,
        'ChannelId': channelId,
        'IsCH340': isCH340,
      };
}