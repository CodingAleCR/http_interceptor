# 🚀 Migration guide to 0.4.0

## ❗️ Using strings instead of URIs

Since `http` dropped support for using string as url when creating requests, we had to implement an alternative way in order to keep it as close as possible to current syntax. To do this we created a new extension on String that allows you to transform any string into an URI. The function is called `toUri()` and is available anywhere with the import of `http_interceptor`.

```dart
extension ToURI on String {
  Uri toUri() => Uri.parse(this);
}
```

This method is really useful when you have different environments and that's why we tried our best to keep it as part of the library.

**0.4.0 and up**

```dart
final response =
          await client.get("$baseUrl/weather".toUri(), params: {'id': "$id"});
```

**0.3.3 and older**

```dart
final response =
          await client.get("$baseUrl/weather", params: {'id': "$id"});
```
