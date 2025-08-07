import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class HuggingFaceService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  final String _apiKey;
  static const String _defaultModel =
      'stabilityai/stable-diffusion-xl-base-1.0';

  HuggingFaceService({required String apiKey}) : _apiKey = apiKey;

  Future<String> generateImageFromText({
    required String prompt,
    String model = _defaultModel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$model'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'num_inference_steps': 20,
            'guidance_scale': 7.5,
            'width': 1024,
            'height': 1024,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to generate image: ${response.statusCode} - ${response.body}');
      }

      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['error'] ?? 'Unknown error'}');
      }

      final Uint8List imageBytes = response.bodyBytes;
      final String base64Image = base64Encode(imageBytes);

      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print('HuggingFace API error: $e');
      throw Exception('Failed to generate image: $e');
    }
  }
}
