import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class CallManFormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CallManForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CallManForm extends StatefulWidget {
  @override
  _CallManFormState createState() => _CallManFormState();
}

class _CallManFormState extends State<CallManForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime(1970);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1D9F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF0F2E4E),
                width: double.infinity,
                child: const Text(
                  'CallMan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPhoneRow(),
                      const SizedBox(height: 15),
                      _buildTextField('Name'),
                      _buildTextField('Email'),
                      _buildTextField('Company Name'),
                      _buildTextField('Address'),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('City')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('State')),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Country')),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField('Pin Code')),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown('Source'),
                      _buildDropdown('Lead Status'),
                      const SizedBox(height: 15),
                      _buildDatePicker(context),
                      const SizedBox(height: 15),
                      _buildRemarks(),
                      _buildDropdown('Priority'),
                      const SizedBox(height: 25),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneRow() {
    return Row(
      children: [
        const SizedBox(width: 8),
        const Text(
          '+91',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField('Mobile Number', keyboardType: TextInputType.phone),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: ['Option 1', 'Option 2', 'Option 3']
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? datePicked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(1970),
          lastDate: DateTime(2100),
        );
        if (datePicked != null) {
          setState(() {
            _selectedDate = datePicked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarks() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Remarks',
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Submit logic
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F2E4E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Submit', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
