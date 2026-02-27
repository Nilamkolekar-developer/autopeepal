import 'package:flutter/foundation.dart';

/// ================= TreeListModel =================
class TreeListModel extends ChangeNotifier {
  int _id = 0;
  int get id => _id;
  set id(int value) {
    _id = value;
    notifyListeners();
  }

  int _okPageNodeId = 0;
  int get okPageNodeId => _okPageNodeId;
  set okPageNodeId(int value) {
    _okPageNodeId = value;
    notifyListeners();
  }

  int _notOkPageNodeId = 0;
  int get notOkPageNodeId => _notOkPageNodeId;
  set notOkPageNodeId(int value) {
    _notOkPageNodeId = value;
    notifyListeners();
  }

  String _topic = '';
  String get topic => _topic;
  set topic(String value) {
    _topic = value;
    notifyListeners();
  }

  String _description = '';
  String get description => _description;
  set description(String value) {
    _description = value;
    notifyListeners();
  }

  String _groupName = '';
  String get groupName => _groupName;
  set groupName(String value) {
    _groupName = value;
    notifyListeners();
  }

  double _viewHeight = 0.0;
  double get viewHeight => _viewHeight;
  set viewHeight(double value) {
    _viewHeight = value;
    notifyListeners();
  }

  String _descriptionTextColor = '';
  String get descriptionTextColor => _descriptionTextColor;
  set descriptionTextColor(String value) {
    _descriptionTextColor = value;
    notifyListeners();
  }

  String _descriptionBackgroundColor = '';
  String get descriptionBackgroundColor => _descriptionBackgroundColor;
  set descriptionBackgroundColor(String value) {
    _descriptionBackgroundColor = value;
    notifyListeners();
  }

  bool _pageVisible = false;
  bool get pageVisible => _pageVisible;
  set pageVisible(bool value) {
    _pageVisible = value;
    notifyListeners();
  }

  List<GroupListModel> _groupList = [];
  List<GroupListModel> get groupList => _groupList;
  set groupList(List<GroupListModel> value) {
    _groupList = value;
    notifyListeners();
  }

  List<DecissionModel> _decissionList = [];
  List<DecissionModel> get decissionList => _decissionList;
  set decissionList(List<DecissionModel> value) {
    _decissionList = value;
    notifyListeners();
  }

  List<LastQueCheckModel> _lastQuestionList = [];
  List<LastQueCheckModel> get lastQuestionList => _lastQuestionList;
  set lastQuestionList(List<LastQueCheckModel> value) {
    _lastQuestionList = value;
    notifyListeners();
  }
}

/// ================= GroupListModel =================
class GroupListModel extends ChangeNotifier {
  String _upperLimit = '';
  String get upperLimit => _upperLimit;
  set upperLimit(String value) {
    _upperLimit = value;
    notifyListeners();
  }

  String _lowerLimit = '';
  String get lowerLimit => _lowerLimit;
  set lowerLimit(String value) {
    _lowerLimit = value;
    notifyListeners();
  }

  bool _upperLowerValueVisible = false;
  bool get upperLowerValueVisible => _upperLowerValueVisible;
  set upperLowerValueVisible(bool value) {
    _upperLowerValueVisible = value;
    notifyListeners();
  }

  String _unit = '';
  String get unit => _unit;
  set unit(String value) {
    _unit = value;
    notifyListeners();
  }

  String _groupName = '';
  String get groupName => _groupName;
  set groupName(String value) {
    _groupName = value;
    notifyListeners();
  }

  String _currentLimit = '';
  String get currentLimit => _currentLimit;
  set currentLimit(String value) {
    if (_isDigitsOnly(value)) {
      _currentLimit = value;
    } else {
      _currentLimit = '';
    }
    notifyListeners();
  }

  String _statusColor = '#000000';
  String get statusColor => _statusColor;
  set statusColor(String value) {
    _statusColor = value;
    notifyListeners();
  }

  String _entryDescription = '';
  String get entryDescription => _entryDescription;
  set entryDescription(String value) {
    _entryDescription = value;
    notifyListeners();
  }

  bool _isDigitsOnly(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }
}

/// ================= LastQueCheckModel =================
class LastQueCheckModel extends ChangeNotifier {
  bool _isCheck = false;
  bool get isCheck => _isCheck;
  set isCheck(bool value) {
    _isCheck = value;
    notifyListeners();
  }

  String _describe = '';
  String get describe => _describe;
  set describe(String value) {
    _describe = value;
    notifyListeners();
  }

  int _id = 0;
  int get id => _id;
  set id(int value) {
    _id = value;
    notifyListeners();
  }
}

/// ================= DecissionModel =================
class DecissionModel extends ChangeNotifier {
  bool _isCheck = false;
  bool get isCheck => _isCheck;
  set isCheck(bool value) {
    _isCheck = value;
    notifyListeners();
  }

  String _textValue = '';
  String get textValue => _textValue;
  set textValue(String value) {
    _textValue = value;
    notifyListeners();
  }

  int _nextNode = 0;
  int get nextNode => _nextNode;
  set nextNode(int value) {
    _nextNode = value;
    notifyListeners();
  }

  String _type = '';
  String get type => _type;
  set type(String value) {
    _type = value;
    notifyListeners();
  }

  int _id = 0;
  int get id => _id;
  set id(int value) {
    _id = value;
    notifyListeners();
  }
}