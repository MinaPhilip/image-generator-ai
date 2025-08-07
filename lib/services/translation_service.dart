import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  Future<String> translateArabicToEnglish(String arabicText) async {
    try {
      return await _translateWithMyMemory(arabicText);
      ;
    } catch (e) {
      return arabicText;
    }
  }

  Future<String> _translateWithMyMemory(String text) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final response = await http.get(
        Uri.parse(
            'https://api.mymemory.translated.net/get?q=$encodedText&langpair=ar|en'),
        headers: {
          'User-Agent': 'Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['responseStatus'] == 200 && data['responseData'] != null) {
          final translatedText = data['responseData']['translatedText'] ?? '';
          return translatedText;
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }
}
