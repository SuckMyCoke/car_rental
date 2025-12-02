import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../services/services.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Data
  String _make = '';
  String _model = '';
  String _year = '';
  String _price = '';
  String _desc = '';
  File? _imageFile;
  bool _isUploading = false;

  // Features Selection
  final List<String> _availableFeatures = ['Bluetooth', 'GPS', 'Leather', 'Sunroof', 'Dashcam', 'Auto'];
  final List<String> _selectedFeatures = [];

  // Image Picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // Submit Logic
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add a photo of the car"))
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isUploading = true);

    try {
      await DatabaseService.addCarListing(
        make: _make,
        model: _model,
        year: int.parse(_year),
        price: double.parse(_price),
        description: _desc,
        features: _selectedFeatures,
        imageFile: _imageFile,
      );

      if (mounted) {
        Navigator.pop(context); // Go back to dashboard
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Car Listed Successfully!"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Your Car")),
      body: _isUploading
          ? const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Uploading car data...")
        ],
      ))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null
                ),
                child: _imageFile == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Tap to add Hero Image", style: TextStyle(color: Colors.grey))
                  ],
                )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Text Fields
            Row(children: [
              Expanded(child: _buildField("Make", (v) => _make = v!, "e.g. Toyota")),
              const SizedBox(width: 16),
              Expanded(child: _buildField("Model", (v) => _model = v!, "e.g. Vios")),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildField("Year", (v) => _year = v!, "2023", isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildField("Price/Hr (RM)", (v) => _price = v!, "15.00", isNumber: true)),
            ]),
            const SizedBox(height: 16),
            _buildField("Description", (v) => _desc = v!, "Describe condition, rules...", maxLines: 3),
            const SizedBox(height: 24),

            // Features Chips
            const Text("Features", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableFeatures.map((f) {
                final isSelected = _selectedFeatures.contains(f);
                return FilterChip(
                  label: Text(f),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedFeatures.add(f) : _selectedFeatures.remove(f);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("List Vehicle"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, FormFieldSetter<String> onSaved, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      onSaved: onSaved,
    );
  }
}