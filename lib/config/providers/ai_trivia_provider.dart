import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stream_scout/data/models/media.dart';

// Provides fun facts/trivia for a specific media item.
final aiTriviaProvider = FutureProvider.family<List<String>, Media>((
  ref,
  media,
) async {
  final apiKey = const String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) {
    throw Exception('Gemini API Key missing');
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final prompt =
      '''
You are a movie and TV show trivia expert.
Provide 3 short, fascinating, and spoiler-free production facts or trivia about the following:
Title: ${media.title}
Year: ${media.year}
Type: ${media.type.name}

Respond ONLY with a JSON array of strings containing the 3 facts.
Format exactly like this:
```json
[
  "Fact 1",
  "Fact 2",
  "Fact 3"
]
```
''';

  final response = await model.generateContent([Content.text(prompt)]);
  final responseText = response.text ?? '';

  // Extract the JSON array
  final jsonRegex = RegExp(r'```json\s*(\[.*?\])\s*```', dotAll: true);
  final match = jsonRegex.firstMatch(responseText);

  if (match != null) {
    final jsonStr = match.group(1)!;
    final List<dynamic> data = jsonDecode(jsonStr);
    return data.map((e) => e.toString()).toList();
  }

  // Fallback if parsing fails but they still returned text
  if (responseText.isNotEmpty) {
    return [responseText];
  }

  throw Exception('Could not generate trivia.');
});
