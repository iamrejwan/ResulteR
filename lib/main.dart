import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clipboard/clipboard.dart';

void main() {
  runApp(ResultApp());
}

class ResultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RESULTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ResultHomePage(),
    );
  }
}

class ResultHomePage extends StatefulWidget {
  @override
  _ResultHomePageState createState() => _ResultHomePageState();
}

class _ResultHomePageState extends State<ResultHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  bool _loading = false;

  Future<void> fetchResult(String studentId) async {
    setState(() {
      _loading = true;
      _result = "";
    });

    // Direct API URL (no base64)
    final url = Uri.parse(
      'your_api',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isNotEmpty) {
          String output = "Student ID: ${data[0]['studentId']}\n";
          output +=
              "Semester: ${data[0]['semesterName']} ${data[0]['semesterYear']}\n";
          output += "CGPA: ${data[0]['cgpa']}\n\n";

          for (var course in data) {
            output +=
                "${course['customCourseId']} – ${course['courseTitle']}\n";
            output +=
                "Credit: ${course['totalCredit']} | Grade: ${course['gradeLetter']} | Point: ${course['pointEquivalent']}\n\n";
          }

          setState(() {
            _result = output;
          });
        } else {
          setState(() {
            _result = "No data found.";
          });
        }
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Failed to load result.";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void copyToClipboard() {
    if (_result.isNotEmpty) {
      FlutterClipboard.copy(_result).then((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Result copied to clipboard!')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('RESULTER-SPRING25', style: TextStyle(letterSpacing: 1.5)),
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Student ID',
                hintText: 'Example: 111-11-111',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    fetchResult(_controller.text.trim());
                  }
                },
                child: Text('Fetch Result'),
              ),
            ),
            SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (_result.isNotEmpty)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(_result, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: copyToClipboard,
                            icon: Icon(Icons.copy),
                            label: Text('Copy to Clipboard'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
