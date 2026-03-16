import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_interceptor_example/common.dart';
import 'package:http_interceptor_example/credentials.dart';
import 'package:image_picker/image_picker.dart';

class MultipartApp extends StatefulWidget {
  const MultipartApp({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (ctx) => const MultipartApp());
  }

  @override
  State<MultipartApp> createState() => _MultipartAppState();
}

class _MultipartAppState extends State<MultipartApp> {
  RemoveBgRepository repository = RemoveBgRepository(
    InterceptedClient.build(
      interceptors: [
        RemoveBgApiInterceptor(),
        LoggerInterceptor(),
      ],
    ),
  );

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  Uint8List? noBgImage;

  Future<void> _onUpload() async {
    if (pickedImage == null) return;

    setState(() {
      noBgImage = null;
    });

    final data =
        await repository.removeImageBackground(pickedImage!, 'image_file');

    setState(() {
      noBgImage = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove BG App'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickedImage == null ? null : _onUpload,
        icon: const Icon(Icons.upload),
        label: const Text('Upload'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take Picture'),
              onTap: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.camera);
                setState(() {
                  pickedImage = image;
                  noBgImage = null;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  pickedImage = image;
                  noBgImage = null;
                });
              },
            ),
            if (pickedImage != null) ...[
              const Text('Before'),
              if (kIsWeb)
                Image.network(pickedImage!.path)
              else
                Image.file(
                  File(pickedImage!.path),
                ),
            ],
            if (noBgImage != null) ...[
              const Text('After'),
              Image.memory(
                noBgImage!,
              )
            ],
          ],
        ),
      ),
    );
  }
}

// const baseUrl = 'http://api.resmush.it/ws.php';
const baseUrl = 'https://api.remove.bg/v1.0/removebg';

class RemoveBgRepository {
  InterceptedClient client;

  RemoveBgRepository(this.client);

  Future<Uint8List> removeImageBackground(
    XFile imgFile,
    String fieldName,
  ) async {
    Uint8List parsedResponse;
    try {
      late MultipartFile file;
      if (kIsWeb) {
        final Uint8List bytes = await imgFile.readAsBytes();
        file = MultipartFile.fromBytes(fieldName, bytes);
      } else {
        file = await MultipartFile.fromPath(
          fieldName,
          imgFile.path,
        );
      }

      final req = MultipartRequest(
        'POST',
        Uri.parse(baseUrl),
      )..files.add(
          file,
        );

      final streamResponse = await client.send(req);
      final response = await Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        parsedResponse = response.bodyBytes;
      } else {
        return Future.error(
          'Error while fetching.',
          StackTrace.fromString('Response was not 200.'),
        );
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException catch (error) {
      log(error.toString());
      return Future.error('Bad response format 👎');
    } on Exception catch (error) {
      log(error.toString());
      return Future.error('Unexpected error 😢');
    }

    return parsedResponse;
  }
}

class RemoveBgApiInterceptor implements HttpInterceptor {
  @override
  bool shouldInterceptRequest({required BaseRequest request}) => true;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) => true;

  @override
  BaseRequest interceptRequest({required BaseRequest request}) {
    final headers = Map<String, String>.from(request.headers);
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
    headers['X-Api-Key'] = kRemoveBgApiKey;

    if (request is MultipartRequest) {
      final multipart = request;
      final newReq = MultipartRequest(request.method, request.url);
      newReq.fields.addAll(multipart.fields);
      newReq.files.addAll(multipart.files);
      newReq.headers.addAll(headers);
      return newReq;
    }

    final newReq = Request(request.method, request.url);
    newReq.headers.addAll(headers);
    return newReq;
  }

  @override
  BaseResponse interceptResponse({required BaseResponse response}) => response;
}
