import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:play_meet/models/club_model.dart';
import 'package:play_meet/models/ticket_model.dart';
import 'package:play_meet/tools/app_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  AppCache cache = AppCache();

  register({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    String url = "http://fromproject.ir/api/register";

    Map<String, String> headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Register >>>> $json");
      }
      SharedPreferences shpr = await SharedPreferences.getInstance();
      shpr.setString("token", json["access_token"]);
      return true;
    } else {
      if (kDebugMode) {
        print("Json Register Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  login({
    required BuildContext context,
    required email,
    required password,
  }) async {
    String url = "http://fromproject.ir/api/login";

    Map<String, String> headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Login >>>> $json");
      }
      SharedPreferences shpr = await SharedPreferences.getInstance();
      shpr.setString("token", json["access_token"]);
      shpr.setString("admin", json["admin"]);
      return true;
    } else {
      if (kDebugMode) {
        print("Json Login Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  personalQuestion({
    required BuildContext context,
    required String birthDate,
    required String gender,
    required String physicalFitnessLevel,
    required String gameLevel,
    required dynamic profile,
    required List postId,
  }) async {
    String url = "http://fromproject.ir/api/personal-info";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Base64Encoder b = const Base64Encoder();

    Map<String, dynamic> body = {
      "birth_date": birthDate,
      "gender": gender,
      "physical_fitness_level": physicalFitnessLevel,
      "game_level": gameLevel,
      "profile": profile == null ? "" : b.convert(profile.readAsBytesSync()),
      "post_id": postId,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json personalQuestion >>>> $json");
      }
      // ignore: use_build_context_synchronously
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return true;
    } else {
      if (kDebugMode) {
        print("Json personalQuestion Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  getAllNews({required BuildContext context}) async {
    String url = "https://one-api.ir/rss/?token=316809:65858e15d9fa5&action=varzesh3";

    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json News >>>> $json");
      }
      json = json["result"]["item"];
      return json;
    } else {
      if (kDebugMode) {
        print("Json News Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  getHtmlNews({required String newsLink}) async {
    final response = await http.get(Uri.parse(newsLink));
    List htmlNews = response.body.toString().trim().split("\n");

    List<String> l = htmlNews
        .elementAt(htmlNews.indexWhere((n) => n.toString().contains('<div class="news-main-image"')) + 1)
        .toString()
        .replaceAll('<img alt="', '')
        .replaceAll('width="800"', '')
        .replaceAll('src="', '')
        .replaceAll('?w=800', '')
        .replaceAll('" />', '')
        .replaceAll(' ', '')
        .trim()
        .split('"');

    return l[1].toString();
  }

  getPersonalInfo({required BuildContext context}) async {
    String url = "http://fromproject.ir/api/personal-info";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Personal Information >>>> $json");
      }
      return json['data'];
    } else {
      if (kDebugMode) {
        print("Json Personal Information Error >>>> $json");
      }
      return false;
    }
  }

  sendEmail({required BuildContext context, required String email}) async {
    String url = "http://fromproject.ir/api/send-email";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode({'email': email}));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Send Email >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return true;
    } else {
      if (kDebugMode) {
        print("Json Send Email Error >>>> $json");
      }
      if (json["message"].toString().contains("email is invalid")) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ایمیل وارد شده وجود ندارد")));
      }
      return false;
    }
  }

  resetPassword({
    required BuildContext context,
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    String url = "http://fromproject.ir/api/reset-password";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, String> body = {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Reset Password >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return true;
    } else {
      if (kDebugMode) {
        print("Json Reset Password Error >>>> $json");
      }
      if (json["message"].toString().contains("code is invalid")) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("کد وارد شده نامعتبر است")));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      }
      return false;
    }
  }

  getAllUsers() async {
    String url = "http://fromproject.ir/api/admin/users";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Users >>>> $json");
      }
      return json['data'];
    }
  }

  changePassword({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    String url = "http://fromproject.ir/api/change-password";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, String> body = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Reset Password >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return true;
    } else {
      if (kDebugMode) {
        print("Json Change Password Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  addClub({
    required BuildContext context,
    required String name,
    required String city,
    required String address,
    required String phone,
    required double mapX,
    required double mapY,
  }) async {
    ClubModel clubModel = ClubModel();
    String url = "http://fromproject.ir/api/clubs/store";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    clubModel.name = name;
    clubModel.city = city;
    clubModel.address = address;
    clubModel.phone = phone;
    clubModel.mapX = mapX;
    clubModel.mapY = mapY;

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(clubModel.toJson()));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Add Club >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return true;
    } else {
      if (kDebugMode) {
        print("Json Add Club Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  editClub({
    required BuildContext context,
    required int id,
    required String name,
    required String city,
    required String address,
    required String phone,
    required double mapX,
    required double mapY,
  }) async {
    ClubModel clubModel = ClubModel();
    String url = "http://fromproject.ir/api/clubs/$id/edit";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    clubModel.name = name;
    clubModel.city = city;
    clubModel.address = address;
    clubModel.phone = phone;
    clubModel.mapX = mapX;
    clubModel.mapY = mapY;

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(clubModel.toJson()));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Edit Club >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return true;
    } else {
      if (kDebugMode) {
        print("Json Edit Club Error >>>> $json");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      return false;
    }
  }

  getAllMatch() async {
    String url = "http://fromproject.ir/api/matches";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Matches >>>> $json");
      }
      return json['data'];
    }
  }

  getMatchPosts({required int id}) async {
    String url = "http://fromproject.ir/api/matches/$id/positions";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Match Posts >>>> $json");
      }
      return json;
    }
  }

  getUser({required String id}) async {
    String url = "http://fromproject.ir/api/users/$id";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json User >>>> $json");
      }
      return json['data'];
    }
  }

  getClub({required String id}) async {
    String url = "http://fromproject.ir/api/clubs/$id";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Club >>>> $json");
      }
      return json['data'];
    }
  }

  acceptMatch({required int matchId, required int postId}) async {
    String url = "http://fromproject.ir/api/matches/accept";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, int> body = {
      'match_id': matchId,
      'post_id': postId,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Accept Match >>>> $json");
      }
      return true;
    }
  }

  getAllClubs() async {
    String url = "http://fromproject.ir/api/clubs";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Clubs >>>> $json");
      }

      return json['data'];
    } else {
      return false;
    }
  }

  storeMatch({
    required int clubId,
    required String matchType,
    required String matchDate,
    required String startTime,
    required String endTime,
  }) async {
    String url = "http://fromproject.ir/api/matches/store";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {
      'club_id': clubId,
      'type_of_match': matchType,
      'match_date': matchDate,
      'start_time': startTime,
      'end_time': endTime,
    };

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Store Match >>>> $json");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Store Match Error >>>> $json");
      }
      return false;
    }
  }

  getUserTickets() async {
    String url = "http://fromproject.ir/api/tickets";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json User Tickets >>>> $json");
      }

      return json['data'];
    } else {
      return false;
    }
  }

  sendTicket({required BuildContext context, required String title, required String content}) async {
    TicketModel ticket = TicketModel();
    String url = "http://fromproject.ir/api/tickets/store";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    ticket.title = title;
    ticket.content = content;

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(ticket.toJson()));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Send Ticket >>>> $json");
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json["message"])));
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Send Ticket Error >>>> $json");
      }
      return false;
    }
  }

  sendTicketUserAnswer({required int id, required String content}) async {
    String url = "http://fromproject.ir/api/tickets/answer";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {'question_id': id, 'content': content};

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Send Ticket User Answer >>>> $json");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Send Ticket User Answer Error >>>> $json");
      }
      return false;
    }
  }

  sendTicketAdminAnswer({required int id, required String content}) async {
    String url = "http://fromproject.ir/api/admin/tickets/answer";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {'question_id': id, 'content': content};

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Send Ticket Admin Answer >>>> $json");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Send Ticket Admin Answer Error >>>> $json");
      }
      return false;
    }
  }

  getUserTicket({required int id}) async {
    String url = "http://fromproject.ir/api/tickets/$id";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json User Ticket >>>> $json");
      }

      return json['data'];
    } else {
      return false;
    }
  }

  getAdminTickets() async {
    String url = "http://fromproject.ir/api/admin/tickets";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Admin Tickets >>>> $json");
      }

      return json['data'];
    } else {
      return false;
    }
  }

  getAdminMatches({String status = 'accepted'}) async {
    String url = "http://fromproject.ir/api/admin/matches?state=$status";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Admin Matches >>>> $json");
      }

      return json['data'];
    } else {
      return false;
    }
  }

  changeMatchStatus({required int id, required String status}) async {
    String url = "http://fromproject.ir/api/admin/matches/$id/change-state";

    SharedPreferences shr = await SharedPreferences.getInstance();
    String token = shr.getString('token').toString();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {'state': status};

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Change Match Status >>>> $json");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Change Match Status Error >>>> $json");
      }
      return false;
    }
  }

  deleteUser({required int id}) async {
    AppCache cache = AppCache();
    String url = "http://fromproject.ir/api/admin/users/$id/delete";

    String token = await cache.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Delete User >>>> $json");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Delete User Error >>>> $json");
      }
      return false;
    }
  }

  getUserRegisteredMatches() async {
    String url = "http://fromproject.ir/api/matches/my-matches";
    String token = await cache.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json User Matches >>>> $json");
      }
      return json['data'];
    }
  }

  confirmResult({required int id, required String firstTeamGoals, required String secondTeamGoals}) async {
    AppCache cache = AppCache();
    String url = "http://fromproject.ir/api/matches/$id/store-result";

    String token = await cache.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, String> body = {'team_goals1': firstTeamGoals, 'team_goals2': secondTeamGoals};

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Confirm Result >>>> $json");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Json Confirm Result Error >>>> $json");
      }
      return false;
    }
  }

  getUserMatch({required int id}) async {
    AppCache cache = AppCache();
    String url = "http://fromproject.ir/api/matches/$id";

    String token = await cache.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json User Match >>>> $json");
      }

      return json['data'];
    } else {
      return false;
    }
  }

  getUserAcceptedMatches() async {
    String url = "http://fromproject.ir/api/matches/my-membered-matches";
    String token = await cache.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Accepted Matches >>>> $json");
      }
      return json['data'];
    }
  }

  editeAdminUser({
    required int id,
    required String name,
    required String email,
    required String status,
  }) async {
    String url = "http://fromproject.ir/api/admin/users/$id/edit";
    String token = await cache.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {"name": name, "email": email, "status": status};

    final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

    if (kDebugMode) {
      print("statusCode >>>> ${response.statusCode}");
    }

    dynamic json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Json Edite Admin User >>>> $json");
      }
      return true;
    }
  }
}
