import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

import '../models/http_exiption.dart';

class Auth with ChangeNotifier {
  late String? _token;
  DateTime? _expireDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId.toString();
  }

  String? get token {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authentification(
      String email, String password, String type) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$type?key=AIzaSyAldpr34NQfsLe2JEXmC8oc_QL-pU7KAkY';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responceData = json.decode(response.body);
      if (responceData['error'] != null) {
        throw HttpException(responceData['error']['message']);
      }
      _token = responceData['idToken'];
      _userId = responceData['localId'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responceData['expiresIn'])));
      authTimer();
      notifyListeners();
      final pre = await SharedPreferences.getInstance();
      final userData = json.encode(
          {'token': _token, 'userId': _userId, 'expireDate': _expireDate});
      final authData = pre.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> singUp(String email, String password) async {
    return _authentification(email, password, 'signUp');
  }

  Future<void> Login(String email, String password) async {
    return _authentification(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final pre = await SharedPreferences.getInstance();
    if (!pre.containsKey('userData')) {
      return false;
    }
    final extractUserData = json.decode(pre.getString('userData').toString())
        as Map<String, Object>;
    final expireData = DateTime.parse(extractUserData['expireDate'].toString());
    if (expireData.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractUserData['token'].toString();
    _userId = extractUserData['userId'].toString();
    _expireDate = expireData;
    notifyListeners();
    authTimer();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prev = await SharedPreferences.getInstance();
    prev.clear();
  }

  void authTimer() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _expireDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
}
