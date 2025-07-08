import 'package:flowershop/pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flowershop/pages/confirm_page.dart';
import 'package:flowershop/pages/temporary_storage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPayment = 'Pay In-Person';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Set Payment Options",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed:
              () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                ),
              },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Radio(
                      activeColor: Color.fromRGBO(250, 34, 144, 1),
                      value: 'payment options',
                      groupValue: 'payment options',
                      onChanged: (value) {},
                      toggleable: false,
                    ),
                    Text(
                      "Payment\nOptions",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                  ],
                ),
                Text(
                  "     ..........................................................     ",
                ),
                Column(
                  children: [
                    Radio(
                      value: 'Confirm',
                      groupValue: '',
                      onChanged: (value) {},
                      toggleable: false,
                      autofocus: false,
                      fillColor: WidgetStateColor.resolveWith(
                        (states) => Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                    Text(
                      "Confirm\n",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(250, 34, 144, 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(
              'Set Payment',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                'Pay In-Person',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: Radio(
                activeColor: Color.fromRGBO(250, 34, 144, 1),
                fillColor: WidgetStateColor.resolveWith(
                  (states) => Color.fromRGBO(250, 34, 144, 1),
                ),
                value: 'Pay In-Person',
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value.toString();
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'GCash',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: Radio(
                activeColor: Color.fromRGBO(250, 34, 144, 1),
                fillColor: WidgetStateColor.resolveWith(
                  (states) => Color.fromRGBO(250, 34, 144, 1),
                ),
                value: 'GCash',
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value.toString();
                  });
                },
              ),
            ),
            Divider(),
            Padding(padding: EdgeInsets.only(top: 15)),
            Text(
              'Set Pickup Schedule',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('MM/dd/yyyy').format(_selectedDate!),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context),
              ),
              trailing: Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (_selectedDate == null || _selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both date and time.'),
                    ),
                  );
                  return;
                }
                await TemporaryStorage.storePaymentOption(_selectedPayment);
                await TemporaryStorage.storePickupDate(_selectedDate!);
                await TemporaryStorage.storePickupTime(_selectedTime!);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfirmPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(250, 34, 144, 1),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Confirm Payment and Schedule',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
