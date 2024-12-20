import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class QuoteController extends GetxController {
  String quote = "";

  @override
  void onInit() {
    fetchQuote();
    super.onInit();
  }

  Future<void> fetchQuote() async {
    final response = await http.get(Uri.parse("https://dummyjson.com/quotes"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      quote = data['quotes'][0]['quote'];
      update();
    }
  }
}
