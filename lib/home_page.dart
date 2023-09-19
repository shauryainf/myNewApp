import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int temperature = 0;

  String _responseText = '';
  String OPENAI_API_KEY = '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';

  Future<String> makeWeatherRequest() async {
    final apiKey = 'e032255571224d3fb81121802231909';
    final location = 'Munich';

    final url = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$location&aqi=no');
    try {
      final response = await http.get(url);
      final jsonResponse = json.decode(response.body);
      temperature = jsonResponse['current']['temp_c'];

      final jsonres = jsonResponse.toString();
      setState(() {});
      return jsonres;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<void> _makeRequest() async {
    print('Making request...');
    String weather = await makeWeatherRequest();
    // print(weather);
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $OPENAI_API_KEY',
    };
    final body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content':
              'What should I wear today? Write a very short response based on the data below:\n\n$weather\n\n Format of your response: \n\nThe weather in {city} is {weather}. You should wear {type of clothes or name or clothes}'
        }
      ],
      'temperature': 0.7,
    };
    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(body));

      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      print(jsonResponse);
      final message = jsonResponse['choices'][0]['message']['content'];
      setState(() {
        _responseText = message;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: Text(
              '$temperature',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _makeRequest, child: Text('Get Weather')),
          Text(
            '$_responseText',
            style: TextStyle(fontSize: 24, fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }
}
