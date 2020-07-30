import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' hide context;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'issue_client.dart';
import 'models/attachment.dart';
import 'models/repo.dart';

part './widgets/add_photo_button.dart';
part './widgets/upload_tile.dart';
part './widgets/submit_button.dart';

class IssueForm extends StatefulWidget {
  final String owner;
  final String repositoryName;
  final String authToken;
  IssueForm(
      {Key key,
      @required this.owner,
      @required this.repositoryName,
      @required this.authToken})
      : super(key: key);

  @override
  _IssueFormState createState() => _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {
  final _formKey = GlobalKey<FormState>();
  String title, description;
  final List<Future> _uploads = [];
  final List<Attachment> _images = [];
  final _uploadServiceUrl = "https://issue-image-uploader.herokuapp.com/upload";
  bool _submitting = false;

  TextStyle _headerStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16);

  TextStyle _subTitleStyle = TextStyle(
      height: 1.5,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.grey.shade600);

  SizedBox _headerSpace = const SizedBox(
    height: 7.5,
  );

  SizedBox _sectionSpace = const SizedBox(
    height: 30,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(text: 'Title ', style: _headerStyle, children: [
                  TextSpan(
                      text: '*\n',
                      style: TextStyle(fontSize: 18.0, color: Colors.red)),
                  TextSpan(text: "What's the issue?", style: _subTitleStyle)
                ]),
              ),
              _headerSpace,
              TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                onSaved: (newValue) => title = newValue.trim(),
                validator: (value) {
                  return value.isEmpty ? 'This field is required' : null;
                },
              ),
              _sectionSpace,
              RichText(
                text: TextSpan(
                    text: 'Description\n',
                    style: _headerStyle,
                    children: [
                      TextSpan(
                          text: 'Please provide any additional details',
                          style: _subTitleStyle)
                    ]),
              ),
              _headerSpace,
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                onSaved: (newValue) => description = newValue.trim(),
                validator: (_) => null,
              ),
              _sectionSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Attachments\n',
                        style: _headerStyle,
                        children: [
                          TextSpan(
                              text: '.png/.jpg format', style: _subTitleStyle)
                        ]),
                  ),
                  AddPhotoButton(
                    onPressed: _selectImage,
                  )
                ],
              ),
              _headerSpace,
              _buildAttachments(),
              _sectionSpace,
              SubmitButton(onPressed: _submitting ? () => null : _submitIssue)
            ],
          ),
        ),
      ),
    ));
  }

  /// Display list of uploaded photos
  Widget _buildAttachments() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _uploads.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: 5.0,
      ),
      itemBuilder: (context, index) {
        final future = _uploads[index];
        return UploadTile(
            images: _images,
            index: index,
            upload: future,
            cancelUpload: () {
              final path = _images[index].relativeStoragePath;
              http
                  .delete(_uploadServiceUrl, headers: {"path": path})
                  .then((value) => _showSuccess("Attachment removed"))
                  .catchError((_) => _showError("Error removing attachment"));

              setState(() {
                _uploads.remove(future);
                _images.removeAt(index);
              });
            });
      },
    );
  }

  /// Attach an image
  Future<void> _selectImage() async {
    // Select image to attach
    final _picker = ImagePicker();
    final PickedFile pickedFile =
        await _picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Scaled image dimensions to display on GitHub
      final int width = (MediaQuery.of(context).size.width * 0.4).round();
      final int height = (MediaQuery.of(context).size.height * 0.4).round();

      // Generate storage path
      final String uuid = Uuid().v1();
      final String ext = basename(file.path).split(".").last;
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        final String path =
            '${widget.owner}/${widget.repositoryName}/$uuid.$ext';
        final bytes = (await file.readAsBytes()).toList();

        // Upload image
        final uploadFuture = http.post(_uploadServiceUrl,
            body: jsonEncode({"path": path, "data": bytes.toString()}),
            headers: {"Content-Type": 'application/json'});

        setState(() {
          _uploads.add(uploadFuture);
          _images.add(new Attachment(
              name: uuid,
              relativeStoragePath: path,
              width: width,
              height: height));
        });
      } else {
        _showError("Invalid file format");
      }
    }
  }

  /// Submit the issue
  void _submitIssue() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() => _submitting = true);

      final Repo repo = Repo(widget.owner, widget.repositoryName);
      final IssueClient _client = IssueClient(repo, widget.authToken);
      final res = _client.createIssue(title, _images, screenInfo,
          description: description);

      // Handle response
      res
          .then((value) => _showSuccess("Issue submitted!"))
          .catchError((_) => _showError("Error submitting issue"))
          .whenComplete(() => _resetForm());
    }
  }

  /// Reset form details
  void _resetForm() {
    _formKey.currentState.reset();
    _uploads.clear();
    _images.clear();
    setState(() {
      title = null;
      description = null;
      _submitting = false;
    });
  }

  /// Dispay a success snackbar
  void _showSuccess(String message) => Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Row(
      children: [
        Icon(Icons.check_circle_outline, color: Colors.green),
        const SizedBox(
          width: 10,
        ),
        Text(message),
      ],
    )));

  /// Display an error snackbar
  void _showError(String error) => Scaffold.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(error),
      ],
    )));

  /// Get the screen size and orientation in a human-readable form
  String get screenInfo {
    final media = MediaQuery.of(context);
    final int width = media.size.width.round();
    final int height = media.size.height.round();
    final orientation =
        media.orientation == Orientation.landscape ? "Landscape" : "Portrait";
    return "$width x $height px, $orientation Mode";
  }
}
