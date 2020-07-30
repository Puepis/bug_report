part of '../issue_form.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SubmitButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        height: MediaQuery.of(context).size.height * 0.06,
        color: Colors.grey.shade300,
        elevation: 3.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: onPressed,
        child: RichText(
          text: TextSpan(
            text: 'Submit',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22.0),
          ),
        ),
      ),
    );
  }
}
