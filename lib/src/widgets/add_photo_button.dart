part of '../issue_form.dart';

/// Creates a [RaisedButton] that allows the user to add an attachment.
class AddPhotoButton extends StatelessWidget {
  /// The logic for adding a new attachment.
  final VoidCallback onPressed;
  const AddPhotoButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate),
          const SizedBox(
            width: 10,
          ),
          RichText(
            text: TextSpan(
                text: 'Add photo',
                style: TextStyle(color: Colors.black, fontSize: 14)),
          )
        ],
      ),
    );
  }
}
