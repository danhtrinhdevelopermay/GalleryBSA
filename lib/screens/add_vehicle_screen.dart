import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  // Form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _status = 'available';
  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    } catch (e) {
      _showErrorMessage('Error picking images: $e');
    }
  }

  Future<void> _pickVideos() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedVideos.addAll(
            result.paths.where((path) => path != null).map((path) => File(path!)),
          );
        });
      }
    } catch (e) {
      _showErrorMessage('Error picking videos: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would upload the files to a server and get URLs
      // For this demo, we'll use placeholder URLs
      final List<String> mediaFiles = [];
      
      // Add image placeholder URLs
      for (int i = 0; i < _selectedImages.length; i++) {
        mediaFiles.add('https://images.unsplash.com/photo-1549924231-f129b911e442?w=800&h=600&fit=crop&crop=center');
      }
      
      // Add video placeholder URLs  
      for (int i = 0; i < _selectedVideos.length; i++) {
        mediaFiles.add('https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4');
      }

      final vehicle = Vehicle(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        licensePlate: _licensePlateController.text.trim(),
        vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
        mileage: _mileageController.text.trim().isEmpty ? null : int.tryParse(_mileageController.text),
        price: _priceController.text.trim().isEmpty ? null : double.tryParse(_priceController.text),
        status: _status,
        mediaFiles: mediaFiles,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.insertVehicle(vehicle);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorMessage('Error saving vehicle: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back),
        ),
        actions: [
          CupertinoButton(
            onPressed: _isLoading ? null : _saveVehicle,
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Vehicle Information Section
            _buildSection(
              'Vehicle Information',
              [
                _buildTextFormField(
                  controller: _makeController,
                  label: 'Make',
                  placeholder: 'e.g., Toyota',
                  isRequired: true,
                ),
                _buildTextFormField(
                  controller: _modelController,
                  label: 'Model',
                  placeholder: 'e.g., Camry',
                  isRequired: true,
                ),
                _buildTextFormField(
                  controller: _yearController,
                  label: 'Year',
                  placeholder: 'e.g., 2020',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Year is required';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _licensePlateController,
                  label: 'License Plate',
                  placeholder: 'e.g., ABC-1234',
                  isRequired: true,
                ),
                _buildTextFormField(
                  controller: _vinController,
                  label: 'VIN',
                  placeholder: '17-digit VIN number',
                ),
                _buildTextFormField(
                  controller: _mileageController,
                  label: 'Mileage',
                  placeholder: 'e.g., 50000',
                  keyboardType: TextInputType.number,
                ),
                _buildTextFormField(
                  controller: _priceController,
                  label: 'Price',
                  placeholder: 'e.g., 25000',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status Section
            _buildSection(
              'Status',
              [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CupertinoSegmentedControl<String>(
                    children: const {
                      'available': Text('Available'),
                      'in-use': Text('In Use'),
                      'maintenance': Text('Maintenance'),
                      'sold': Text('Sold'),
                    },
                    groupValue: _status,
                    onValueChanged: (value) {
                      setState(() {
                        if (value != null) _status = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Media Section
            _buildSection(
              'Media',
              [
                // Images
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton.filled(
                        onPressed: _pickImages,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(CupertinoIcons.camera, size: 20),
                            SizedBox(width: 8),
                            Text('Add Images'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        onPressed: _pickVideos,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.videocam,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Videos',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Selected Images Grid
                if (_selectedImages.isNotEmpty)
                  _buildMediaGrid(
                    'Images (${_selectedImages.length})',
                    _selectedImages.map((file) => _buildImageTile(file, _selectedImages.indexOf(file))).toList(),
                  ),

                if (_selectedImages.isNotEmpty && _selectedVideos.isNotEmpty)
                  const SizedBox(height: 16),

                // Selected Videos Grid
                if (_selectedVideos.isNotEmpty)
                  _buildMediaGrid(
                    'Videos (${_selectedVideos.length})',
                    _selectedVideos.map((file) => _buildVideoTile(file, _selectedVideos.indexOf(file))).toList(),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _saveVehicle,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text('Save Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? placeholder,
    TextInputType? keyboardType,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (isRequired ? ' *' : ''),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: validator ??
                (isRequired
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '$label is required';
                        }
                        return null;
                      }
                    : null),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  Widget _buildImageTile(File file, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoTile(File file, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.play_circle_fill,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeVideo(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}