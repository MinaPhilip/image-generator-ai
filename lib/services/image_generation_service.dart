import 'huggingface_service.dart';
import 'translation_service.dart';
import '../constants/api_constants.dart';

class CopticImageGenerationService {
  final HuggingFaceService _huggingFaceService;
  final TranslationService _translationService;

  CopticImageGenerationService({
    required String huggingFaceApiKey,
  })  : _huggingFaceService = HuggingFaceService(apiKey: huggingFaceApiKey),
        _translationService = TranslationService();

  Future<String> generateCopticImage(String userInput) async {
    try {
      // Translate Arabic input to English
      final translatedInput =
          await _translationService.translateArabicToEnglish(userInput);

      // Generate image using Hugging Face (free)
      final imageBase64 = await _huggingFaceService.generateImageFromText(
        prompt: translatedInput + " " + ApiConstants.basePrompt,
      );

      return imageBase64;
    } catch (e) {
      print('Service error in generateCopticImage: $e');
      rethrow;
    }
  }
}
