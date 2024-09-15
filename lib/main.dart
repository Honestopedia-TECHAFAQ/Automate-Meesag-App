// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyBessyApp());
}

class MyBessyApp extends StatelessWidget {
  const MyBessyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bessy Messaging App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BessyHomePage(),
    );
  }
}

class BessyHomePage extends StatefulWidget {
  const BessyHomePage({super.key});

  @override
  _BessyHomePageState createState() => _BessyHomePageState();
}

class _BessyHomePageState extends State<BessyHomePage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _wordFile;
  File? _namesFile;
  bool _isValidated = false;
  int _totalContacts = 0;
  int _sentMessages = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.sms,
      Permission.contacts,
    ].request();
  }

  Future<void> _selectWordFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _wordFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectNamesFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'csv', 'xlsx'],
    );

    if (result != null) {
      setState(() {
        _namesFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _validateFiles() async {
    if (_wordFile != null && _namesFile != null) {
      // Perform file validation logic here
      setState(() {
        _isValidated = true;
        _totalContacts = 100; // Example: replace with actual contact count
      });
    } else {
      _showErrorDialog('Please select both the Word file and the Names file.');
    }
  }

  bool _validateManualInput() {
    return _messageController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _nameController.text.isNotEmpty;
  }

  Future<void> _sendMessage() async {
    if (_isValidated || _validateManualInput()) {
      setState(() {
        _isSending = true;
      });

      for (int i = 0; i < _totalContacts; i++) {
        if (_isSending) {
          // Send the message logic here
          await Future.delayed(_getRandomDelay());
          setState(() {
            _sentMessages++;
          });
        } else {
          break;
        }
      }

      setState(() {
        _isSending = false;
      });

      if (_sentMessages == _totalContacts) {
        _showSuccessDialog('All messages were sent successfully.');
      } else {
        _showErrorDialog('Sending was canceled.');
      }
    } else {
      _showErrorDialog('Please validate the files or input data correctly.');
    }
  }

  Duration _getRandomDelay() {
    final random = Random();
    int randomSeconds = random.nextInt(5) + 1; // Random delay between 1-5 seconds
    return Duration(seconds: randomSeconds);
  }

  void _cancelSending() {
    setState(() {
      _isSending = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bessy Messaging App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: _selectWordFile,
                child: const Text('Select Word File'),
              ),
              ElevatedButton(
                onPressed: _selectNamesFile,
                child: const Text('Select Names File'),
              ),
              ElevatedButton(
                onPressed: _validateFiles,
                child: const Text('Validate Files'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message (Optional for Manual Entry)',
                ),
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional for Manual Entry)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Optional for Manual Entry)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_isValidated || _validateManualInput()) && !_isSending
                    ? _sendMessage
                    : null,
                child: Text(_isSending
                    ? 'Sending... ($_sentMessages/$_totalContacts)'
                    : 'Start Sending'),
              ),
              if (_isSending)
                ElevatedButton(
                  onPressed: _cancelSending,
                  child: const Text('Cancel Sending'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
