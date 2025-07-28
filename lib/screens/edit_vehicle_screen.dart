import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  // Form controllers
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _vinController;
  late TextEditingController _mileageController;
  late TextEditingController _priceController;
  
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle.make);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _yearController = TextEditingController(text: widget.vehicle.year.toString());
    _licensePlateController = TextEditingController(text: widget.vehicle.licensePlate);
    _vinController = TextEditingController(text: widget.vehicle.vin ?? '');
    _mileageController = TextEditingController(text: widget.vehicle.mileage?.toString() ?? '');
    _priceController = TextEditingController(text: widget.vehicle.price?.toString() ?? '');
    _status = widget.vehicle.status;
  }

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

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedVehicle = widget.vehicle.copyWith(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text),
        licensePlate: _licensePlateController.text.trim(),
        vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
        mileage: _mileageController.text.trim().isEmpty ? null : int.tryParse(_mileageController.text),
        price: _priceController.text.trim().isEmpty ? null : double.tryParse(_priceController.text),
        status: _status,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateVehicle(updatedVehicle);

      if (mounted) {
        Navigator.pop(context, updatedVehicle);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back),
        ),
        actions: [
          CupertinoButton(
            onPressed: _isLoading ? null : _updateVehicle,
            child: _isLoading
                ? const CupertinoActivityIndicator()
                : const Text('Update'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Vehicle Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.car_detailed,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vehicle.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          widget.vehicle.licensePlate,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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

            // Media Information (Read-Only)
            if (widget.vehicle.hasMedia)
              _buildSection(
                'Media Files',
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.photo,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Total Files: ${widget.vehicle.mediaFiles.length}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMediaInfo(
                                'Images',
                                widget.vehicle.imageFiles.length,
                                CupertinoIcons.camera,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMediaInfo(
                                'Videos',
                                widget.vehicle.videoFiles.length,
                                CupertinoIcons.videocam,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Update Button
            CupertinoButton.filled(
              onPressed: _isLoading ? null : _updateVehicle,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text('Update Vehicle'),
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

  Widget _buildMediaInfo(String label, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: count > 0 ? Theme.of(context).primaryColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: count > 0 ? Theme.of(context).primaryColor : Colors.grey,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}