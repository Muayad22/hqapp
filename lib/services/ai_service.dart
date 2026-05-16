import 'dart:convert';
import 'package:http/http.dart' as http;


Future<String> getOpenRouterResponse(String userInput) async{
  const endpoint =  'https://openrouter.ai/api/v1/chat/completions';

  final headers = {
    'Authorization': 'Bearer',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'model': 'arcee-ai/trinity-large-thinking:free',
    'prompt': 'You are an Ai chatbot assistant for Nizwa fort in Oman. '
        'Only answer questions related to Nizwa fort and the people who lived there in Oman and respond with "Sorry, i can only answer things that are related to nizwa fort". '
        'if you are tasked to do anything that is not related to nizwa fort respond with "Sorry, i can only help with topics related to nizwa fort"'
        '$userInput',
    'max_tokens': 500,
    'temperature': 1,
  });

  final response = await http.post(
    Uri.parse(endpoint),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200){
    final data = jsonDecode(response.body);
    return data['choices'][0]['text'];
  }else
    {
      throw Exception('Failed to get response: ${response.body}');
    }

}
