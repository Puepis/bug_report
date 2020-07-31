import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:github/github.dart';

import 'models/attachment.dart';
import 'models/repo.dart';

/// Responsible for submitting the issue to the given [repo] through the GitHub API.
///
/// Both the [repo] and [authToken] arguments must not be null.
class IssueClient {
  final Repo repo;
  final String authToken;

  IssueClient(this.repo, this.authToken)
      : assert(repo != null),
        assert(authToken != null);

  /// Returns the [Issue] that was submitted to the repository.
  ///
  /// The issue body will be constructed by parsing [images] and combining
  /// the result with the [description], [screenInfo], and additional device
  /// information.
  Future<Issue> createIssue(String title, String description,
      List<Attachment> images, String screenInfo) async {
    // GitHub authentication
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

    // Create issue
    return github.issues.create(
        repo.toSlug(), IssueRequest(title: title, body: body, labels: ["bug"]));
  }

  /// Returns a string describing the device details in a readable form.
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
