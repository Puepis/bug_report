/// Represents a single image that the user has attached.
///
/// The [url] indicates the cloud storage location after the image has been
/// uploaded.
///
/// The [relativeStoragePath] indicates the relative path of the image in the
/// cloud storage bucket.
///
/// The [width] and [height] parameters indicate the dimensions of the image
/// to display in the markdown body.
///
/// The [name], [relativeStoragePath], [width], and [height] must not be null.
class Attachment {
  final String name;
  final String relativeStoragePath;
  final int width;
  final int height;
  String url;
  Attachment(
      {this.name, this.relativeStoragePath, this.url, this.width, this.height})
      : assert(name != null),
        assert(relativeStoragePath != null),
        assert(width != null),
        assert(height != null);
}
