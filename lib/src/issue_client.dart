import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:github/github.dart';

import 'models/attachment.dart';
import 'models/repo.dart';

class IssueClient {
  final Repo repo;
  final String authToken;

  IssueClient(this.repo, this.authToken);

  Future<Issue> createIssue(
      String title, List<Attachment> images, String screenInfo,
      {String description}) async {
    // Github authentication
    final github = GitHub(auth: Authentication.withToken(authToken));

    // Generate details
    final String deviceDetails = await _getDeviceDetails();
    final String links = images
        .where((img) => img.url != null)
        .map((img) =>
            "<img src='${img.url}' width='${img.width}' height='${img.height}'>")
        .join(" ");

    // Construct body text
    final String body = [
      description.isNotEmpty ? "**Description**" : description,
      description,
      images.isNotEmpty ? "\n**Attachments**" : "",
      links,
      "\n**Device Information**",
      screenInfo,
      deviceDetails
    ].join("\n");

    return github.issues.create(RepositorySlug("Puepis", "issue-test"),
        IssueRequest(title: title, body: body, labels: ["bug"]));
  }

  Future<String> _getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String details;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final String release = androidInfo.version.release;
      final int sdk = androidInfo.version.sdkInt;
      final String manufacturer = androidInfo.manufacturer;
      final String model = androidInfo.model;
      details = 'Android $release (SDK $sdk), $manufacturer $model';
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      final String systemName = iosInfo.systemName;
      final String version = iosInfo.systemVersion;
      final String deviceName = iosInfo.name;
      final String model = iosInfo.model;
      details = '$systemName $version, $deviceName $model';
    }
    return details;
  }
}
