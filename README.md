# bug_report

A bug-reporting tool that opens GitHub issues for Flutter mobile applications. 

## Features
* Supports image attachment (png and jpg)
* Reports device information for easier diagnosis and debugging 

## Usage
Generate a GitHub personal access token by following the steps [here](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token). To use this package, you only need to check the `repo` scope.

Keep your token safe by storing it as an environment variable. A recommended approach is using the [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) package.

Add this package as a dependency in your `pubspec.yaml` file:
```Dart
dependencies:
    bug_report: ^0.1.0
```

Import the library: 
```Dart
import 'package:bug_report/bug_report.dart';
```

Finally, use the widget:
```Dart
final issueForm = IssueForm(
    owner: "YOUR_GITHUB_USERNAME", // e.g. Puepis
    repositoryName: "YOUR_REPOSITORY_NAME", // e.g. bug_report
    authToken: "YOUR_PERSONAL_ACCESS_TOKEN", // keep it safe! 
);
```

## Examples

Check out `lib/main.dart` in the example folder for a sample usage.

## Bugs/Requests

If you encounter any bugs please feel free to open an issue [here]( https://github.com/Puepis/bug_report/issues). Suggestions for new features and contributions are also welcome!
