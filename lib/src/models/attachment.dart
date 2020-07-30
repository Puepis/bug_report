class Attachment {
  final String name;
  final String relativeStoragePath;
  final int width;
  final int height;
  String url;
  Attachment(
      {this.name, this.relativeStoragePath, this.url, this.width, this.height});
}