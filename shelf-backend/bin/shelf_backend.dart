import 'package:shelf_backend/shelf_backend.dart' as shelf_backend;
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';


void main() async {
  final router = Router();

  // Define a simple API route
  router.get('/users', (Request request)async {
    var res = await dio.Dio().get('https://jsonplaceholder.typicode.com/users');
    var resp = res.data;
    print(resp);


    StringBuffer htmlBuffer = StringBuffer();
    htmlBuffer.write('''
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dart Table Example</title>
      </head>
      <body>
        <table border="1">
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>User Name</th>
            <th>Email</th>
          </tr>
      ''');

          for (var item in resp) {
            htmlBuffer.write('''
          <tr>
            <td>${item['id']}</td>
            <td>${item['name']}</td>
            <td>${item['username']}</td>
            <td>${item['email']}</td>
          </tr>
      ''');
          }

          htmlBuffer.write('''
        </table>
      </body>
      </html>
      ''');

    // Print the generated HTML
    print(htmlBuffer.toString());

    final data = {'message': 'Hello from Shelf!'};
    return Response.ok(htmlBuffer.toString(), headers: {'Content-Type': 'application/json'});
  });

  // Serve static files from 'public' directory
 // final staticHandler = createStaticHandler('public', defaultDocument: 'index.html');

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware)
      .addHandler(Cascade().add(router.call).handler);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

Middleware _corsMiddleware = (Handler handler) {
  return (Request request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok('',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST,GET,OPTIONS,PUT,DELETE',
            'Access-Control-Allow-Headers':
            'Origin,Content-Type,Accept,Authorization',
          });
    }

    final response = await handler(request);

    return response.change(headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST,GET,OPTIONS,PUT,DELETE',
      'Access-Control-Allow-Headers': 'Origin,Content-Type,Accept,Authorization',
    });
  };
};