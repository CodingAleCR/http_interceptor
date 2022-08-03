import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_interceptor_example/common.dart';
import 'package:http_interceptor_example/credentials.dart';
import 'package:image_picker/image_picker.dart';

class MultipartApp extends StatefulWidget {
  const MultipartApp({Key? key}) : super(key: key);

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
  ui.Image? noBgImage;

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
              Image.file(File(pickedImage!.path)),
            ],
            if (noBgImage != null) ...[
              const Text('After'),
              RawImage(
                image: noBgImage!, // this is a dart:ui Image object
                scale: 1.0,
              ),
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

  Future<ui.Image> removeImageBackground(
    XFile imgFile,
    String fieldName,
  ) async {
    ui.Image parsedResponse;
    try {
      final req = MultipartRequest(
        HttpMethod.POST.asString,
        Uri.parse(baseUrl),
      )..files.add(
          await MultipartFile.fromPath(
            fieldName,
            imgFile.path,
          ),
        );

      final response = await client.send(req);
      if (response.statusCode == 200) {
        final respBytes = await response.stream.first;
        final image = await decodeImageFromList(Uint8List.fromList(respBytes));

        parsedResponse = image;
      } else {
        return Future.error(
          'Error while fetching.',
          StackTrace.fromString(''),
        );
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException {
      return Future.error('Bad response format 👎');
    } on Exception catch (error) {
      log(error.toString());
      return Future.error('Unexpected error 😢');
    }

    return parsedResponse;
  }
}

class RemoveBgApiInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({
    required BaseRequest request,
  }) async {
    final Map<String, String> headers = Map.from(request.headers);
    headers[HttpHeaders.contentTypeHeader] = 'application/json';
    headers['X-Api-Key'] = kRemoveBgApiKey;

    return request.copyWith(
      headers: headers,
    );
  }

  @override
  Future<BaseResponse> interceptResponse({
    required BaseResponse response,
  }) async =>
      response;
}
