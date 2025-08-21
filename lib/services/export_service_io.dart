// Stub implementation for non-web platforms
class Blob {
  Blob(List<List<int>> parts, String type);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  AnchorElement({String? href});
  String? target;
  String? download;
  void click() {}
  void remove() {}
}

class Document {
  Element? body;
}

class Element {
  void append(AnchorElement element) {}
}

final document = Document();