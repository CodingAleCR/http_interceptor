import 'package:flutter/material.dart';
import 'package:http_interceptor_example/multipart_app.dart';

import 'weather_app.dart';

void main() => runApp(const ExamplesApp());

class ExamplesApp extends StatelessWidget {
  const ExamplesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExamplesMenuScreen(),
    );
  }
}

class ExamplesMenuScreen extends StatelessWidget {
  const ExamplesMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Weather Example'),
            subtitle: const Text('Simple HTTP Intercepting'),
            onTap: () => Navigator.push<void>(context, WeatherApp.route()),
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Remove Img Background Example'),
            subtitle: const Text('Multipart Intercepting'),
            onTap: () => Navigator.push<void>(context, MultipartApp.route()),
          ),
        ],
      ),
    );
  }
}
