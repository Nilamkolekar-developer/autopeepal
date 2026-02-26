class CheckJobCardModel {
  D? d;

  CheckJobCardModel({this.d});

  factory CheckJobCardModel.fromJson(Map<String, dynamic> json) {
    return CheckJobCardModel(
      d: json['d'] != null ? D.fromJson(json['d']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'd': d?.toJson(),
    };
  }
}

class Metadata {
  String? id;
  String? uri;
  String? type;

  Metadata({this.id, this.uri, this.type});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      id: json['id'],
      uri: json['uri'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uri': uri,
      'type': type,
    };
  }
}

class Deferred {
  String? uri;

  Deferred({this.uri});

  factory Deferred.fromJson(Map<String, dynamic> json) {
    return Deferred(uri: json['uri']);
  }

  Map<String, dynamic> toJson() => {'uri': uri};
}

class NPHEADERJOB {
  Deferred? deferred;

  NPHEADERJOB({this.deferred});

  factory NPHEADERJOB.fromJson(Map<String, dynamic> json) {
    return NPHEADERJOB(
      deferred: json['__deferred'] != null
          ? Deferred.fromJson(json['__deferred'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '__deferred': deferred?.toJson(),
    };
  }
}

class D {
  Metadata? metadata;
  String? bodyType;
  String? jobnr;
  String? prdSegemnt;
  String? vehGrp;
  String? stearGr;
  String? vehModDes;
  String? delName;
  String? frntAxle;
  String? deCode;
  String? rearTyreNoInnerLhs2;
  String? custName;
  String? rearTyreNoOuterLhs2;
  String? loc;
  String? rearTyreNoInnerRhs2;
  String? rearTyreNoOuterRhs2;
  String? vehMod;
  String? frontTyreNoLhs2;
  String? vehTyp;
  String? delLoc;
  String? frontTyreNoRhs2;
  String? gearBox;
  String? vhvin;
  String? engNo;
  String? turboChrg;
  String? instDate;
  String? rearAxle;
  String? bsNorm;
  String? regNo;
  String? vehStatus;
  String? jobCrd;
  String? permit;
  String? failDate;
  String? kmsCover;
  String? engHr;
  String? drvName;
  String? contNo;
  String? preStat;
  String? vehRoad;
  String? techName;
  NPHEADERJOB? npHeaderJob;

  D({
    this.metadata,
    this.bodyType,
    this.jobnr,
    this.prdSegemnt,
    this.vehGrp,
    this.stearGr,
    this.vehModDes,
    this.delName,
    this.frntAxle,
    this.deCode,
    this.rearTyreNoInnerLhs2,
    this.custName,
    this.rearTyreNoOuterLhs2,
    this.loc,
    this.rearTyreNoInnerRhs2,
    this.rearTyreNoOuterRhs2,
    this.vehMod,
    this.frontTyreNoLhs2,
    this.vehTyp,
    this.delLoc,
    this.frontTyreNoRhs2,
    this.gearBox,
    this.vhvin,
    this.engNo,
    this.turboChrg,
    this.instDate,
    this.rearAxle,
    this.bsNorm,
    this.regNo,
    this.vehStatus,
    this.jobCrd,
    this.permit,
    this.failDate,
    this.kmsCover,
    this.engHr,
    this.drvName,
    this.contNo,
    this.preStat,
    this.vehRoad,
    this.techName,
    this.npHeaderJob,
  });

  factory D.fromJson(Map<String, dynamic> json) {
    return D(
      metadata: json['__metadata'] != null ? Metadata.fromJson(json['__metadata']) : null,
      bodyType: json['BodyType'],
      jobnr: json['Jobnr'],
      prdSegemnt: json['PrdSegemnt'],
      vehGrp: json['VehGrp'],
      stearGr: json['StearGr'],
      vehModDes: json['VehModDes'],
      delName: json['DelName'],
      frntAxle: json['FrntAxle'],
      deCode: json['DeCode'],
      rearTyreNoInnerLhs2: json['RearTyreNoInnerLhs2'],
      custName: json['CustName'],
      rearTyreNoOuterLhs2: json['RearTyreNoOuterLhs2'],
      loc: json['Loc'],
      rearTyreNoInnerRhs2: json['RearTyreNoInnerRhs2'],
      rearTyreNoOuterRhs2: json['RearTyreNoOuterRhs2'],
      vehMod: json['VehMod'],
      frontTyreNoLhs2: json['FrontTyreNoLhs2'],
      vehTyp: json['VehTyp'],
      delLoc: json['DelLoc'],
      frontTyreNoRhs2: json['FrontTyreNoRhs2'],
      gearBox: json['GearBox'],
      vhvin: json['Vhvin'],
      engNo: json['EngNo'],
      turboChrg: json['TurboChrg'],
      instDate: json['InstDate'],
      rearAxle: json['RearAxle'],
      bsNorm: json['BsNorm'],
      regNo: json['RegNo'],
      vehStatus: json['VehStatus'],
      jobCrd: json['JobCrd'],
      permit: json['Permit'],
      failDate: json['FailDate'],
      kmsCover: json['KmsCover'],
      engHr: json['EngHr'],
      drvName: json['DrvName'],
      contNo: json['ContNo'],
      preStat: json['PreStat'],
      vehRoad: json['VehRoad'],
      techName: json['TechName'],
      npHeaderJob: json['NP_HEADER_JOB'] != null ? NPHEADERJOB.fromJson(json['NP_HEADER_JOB']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '__metadata': metadata?.toJson(),
      'BodyType': bodyType,
      'Jobnr': jobnr,
      'PrdSegemnt': prdSegemnt,
      'VehGrp': vehGrp,
      'StearGr': stearGr,
      'VehModDes': vehModDes,
      'DelName': delName,
      'FrntAxle': frntAxle,
      'DeCode': deCode,
      'RearTyreNoInnerLhs2': rearTyreNoInnerLhs2,
      'CustName': custName,
      'RearTyreNoOuterLhs2': rearTyreNoOuterLhs2,
      'Loc': loc,
      'RearTyreNoInnerRhs2': rearTyreNoInnerRhs2,
      'RearTyreNoOuterRhs2': rearTyreNoOuterRhs2,
      'VehMod': vehMod,
      'FrontTyreNoLhs2': frontTyreNoLhs2,
      'VehTyp': vehTyp,
      'DelLoc': delLoc,
      'FrontTyreNoRhs2': frontTyreNoRhs2,
      'GearBox': gearBox,
      'Vhvin': vhvin,
      'EngNo': engNo,
      'TurboChrg': turboChrg,
      'InstDate': instDate,
      'RearAxle': rearAxle,
      'BsNorm': bsNorm,
      'RegNo': regNo,
      'VehStatus': vehStatus,
      'JobCrd': jobCrd,
      'Permit': permit,
      'FailDate': failDate,
      'KmsCover': kmsCover,
      'EngHr': engHr,
      'DrvName': drvName,
      'ContNo': contNo,
      'PreStat': preStat,
      'VehRoad': vehRoad,
      'TechName': techName,
      'NP_HEADER_JOB': npHeaderJob?.toJson(),
    };
  }
}

class JobcardModelSecond {
  String? assignedTo;
  String? dealerOrServiceEnggContactNumber;
  String? openCloseStatus;
  String? ticketIdAlias;
  String? breakdownLocation;
  String? vehicleRegisterNumber;
  String? customerContactNo;
  String? dealerdealerName;
  String? dealerContactNumber1;
  String? chassisNo;
  double? kmCovered;
  String? customerCustomerName;
  String? modelNumber;
  String? productVarient;
  String? tripStart;
  String? tripEnd;
  String? dealerCode;

  JobcardModelSecond({
    this.assignedTo,
    this.dealerOrServiceEnggContactNumber,
    this.openCloseStatus,
    this.ticketIdAlias,
    this.breakdownLocation,
    this.vehicleRegisterNumber,
    this.customerContactNo,
    this.dealerdealerName,
    this.dealerContactNumber1,
    this.chassisNo,
    this.kmCovered,
    this.customerCustomerName,
    this.modelNumber,
    this.productVarient,
    this.tripStart,
    this.tripEnd,
    this.dealerCode,
  });

  factory JobcardModelSecond.fromJson(Map<String, dynamic> json) {
    return JobcardModelSecond(
      assignedTo: json['AssignedTo'],
      dealerOrServiceEnggContactNumber: json['DealerOrServiceEnggContactNumber'],
      openCloseStatus: json['OpenCloseStatus'],
      ticketIdAlias: json['TicketIdAlias'],
      breakdownLocation: json['BreakdownLocation'],
      vehicleRegisterNumber: json['VehicleRegisterNumber'],
      customerContactNo: json['CustomerContactNo'],
      dealerdealerName: json['Dealerdealer_name'],
      dealerContactNumber1: json['DealerContactNumber1'],
      chassisNo: json['ChassisNo'],
      kmCovered: json['KmCovered']?.toDouble(),
      customerCustomerName: json['CustomerCustomerName'],
      modelNumber: json['ModelNumber'],
      productVarient: json['ProductVarient'],
      tripStart: json['TripStart'],
      tripEnd: json['TripEnd'],
      dealerCode: json['DealerCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AssignedTo': assignedTo,
      'DealerOrServiceEnggContactNumber': dealerOrServiceEnggContactNumber,
      'OpenCloseStatus': openCloseStatus,
      'TicketIdAlias': ticketIdAlias,
      'BreakdownLocation': breakdownLocation,
      'VehicleRegisterNumber': vehicleRegisterNumber,
      'CustomerContactNo': customerContactNo,
      'Dealerdealer_name': dealerdealerName,
      'DealerContactNumber1': dealerContactNumber1,
      'ChassisNo': chassisNo,
      'KmCovered': kmCovered,
      'CustomerCustomerName': customerCustomerName,
      'ModelNumber': modelNumber,
      'ProductVarient': productVarient,
      'TripStart': tripStart,
      'TripEnd': tripEnd,
      'DealerCode': dealerCode,
    };
  }
}