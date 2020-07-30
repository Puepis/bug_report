part of '../issue_form.dart';

class UploadTile extends StatelessWidget {
  const UploadTile(
      {Key key, this.images, this.index, this.upload, this.cancelUpload})
      : super(key: key);

  final List<Attachment> images;
  final int index;
  final Future upload;
  final VoidCallback cancelUpload;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: upload,
      builder: (context, snapshot) {
        Widget leading;
        if (snapshot.hasData) {
          if (snapshot.data.statusCode == 200) {
            final url = snapshot.data.body;
            images[index].url = url;

            leading = Icon(
              Icons.check,
              size: 34,
              color: Colors.green,
            );

            return Dismissible(
              key: Key(images[index].name.toString()),
              background: Container(
                color: Colors.grey.shade200,
              ),
              onDismissed: (_) => cancelUpload(),
              child: ListTile(
                dense: true,
                title: RichText(
                  text: TextSpan(
                      text: 'Photo #${index + 1}',
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                leading: leading,
              ),
            );
          } else {
            leading = Icon(
              Icons.close,
              color: Colors.red,
              size: 34,
            );
          }
        } else {
          leading = Container(
            height: 24,
            width: 24,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListTile(
          dense: true,
          title: RichText(
            text: TextSpan(
                text: 'Photo #${index + 1}',
                style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
          leading: leading,
        );
      },
    );
  }
}
