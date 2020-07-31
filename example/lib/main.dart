import 'package:bug_report/bug_report.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bug Report Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ReportIssuePage(),
    );
  }
}

class ReportIssuePage extends StatelessWidget {
  const ReportIssuePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Report an Issue"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: IssueForm(
          owner: "YOUR_GITHUB_USERNAME", // e.g. Puepis
          repositoryName: "YOUR_REPOSITORY_NAME", // e.g. bug_report
          authToken: "YOUR_PERSONAL_GITHUB_TOKEN", // keep it safe! 
        ),
      ),
    );
  }
}
