import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'dart:convert';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BookingPage(),
    );
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _formKey = GlobalKey<FormState>();

  void _selectService(String? service) {
    setState(() {
      _selectedService = service;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      String service = _selectedService!;
      String date = _selectedDate.toString().split(' ')[0];
      String time = _selectedTime!.format(context);

      await sendBookingNotification('recipient@example.com', service, date, time);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields')),
      );
    }
  }

  Future<void> sendBookingNotification(String recipientEmail, String service, String date, String time) async {
    final clientId = ClientId(
      dotenv.env['EMAIL_CLIENT_ID']!,
      dotenv.env['EMAIL_CLIENT_SECRET']!,
    );

    final accessCredentials = AccessCredentials(
      AccessToken(
        'Bearer',
        dotenv.env['EMAIL_REFRESH_TOKEN']!,
        DateTime.now().toUtc(),
      ),
      null,
      ['https://mail.google.com/'],
    );

    final authClient = await authenticatedClient(clientId, accessCredentials);

    final gmailApi = gmail.GmailApi(authClient);
    final message = gmail.Message()
      ..raw = base64UrlEncode(utf8.encode(
          'To: $recipientEmail\n'
              'Subject: Booking Notification\n\n'
              'Your booking details:\nService: $service\nDate: $date\nTime: $time'));

    try {
      await gmailApi.users.messages.send(message, 'me');
      print('Message sent');
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      authClient.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pexels-dmitry-demidov-515774-3784221.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    onChanged: _selectService,
                    validator: (value) => value == null ? 'Please select a service' : null,
                    items: const [
                      DropdownMenuItem(
                        value: 'Studio Session',
                        child: Text('Studio Session'),
                      ),
                      DropdownMenuItem(
                        value: 'Live Band Training',
                        child: Text('Live Band Training'),
                      ),
                      DropdownMenuItem(
                        value: 'Instruments Lessons',
                        child: Text('Instruments Lessons'),
                      ),
                      DropdownMenuItem(
                        value: 'Beat Making',
                        child: Text('Beat Making'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Select Service',
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selected Date: ${_selectedDate != null ? _selectedDate.toString().split(' ')[0] : 'Not Selected'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Selected Time: ${_selectedTime != null ? _selectedTime!.format(context) : 'Not Selected'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Select Time'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitBooking,
                    child: const Text('Book Appointment'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<AutoRefreshingAuthClient> authenticatedClient(ClientId clientId, AccessCredentials credentials) async {
  return clientViaUserConsent(clientId, ['https://mail.google.com/'], (url) {
    // The user should open the URL in their browser and grant access
    print('Please go to the following URL and grant access:');
    print('  => $url');
    print('');
  });
}
