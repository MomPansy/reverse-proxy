import 'package:flutter/material.dart';
import '../Constants/form_options.dart';
import 'expandable_section.dart';

class CreateTripForm extends StatefulWidget {
  const CreateTripForm({super.key});

  @override
  State<CreateTripForm> createState() => _CreateTripFormState();
}

class _CreateTripFormState extends State<CreateTripForm> {
  final TextEditingController _notesController = TextEditingController();
  bool _isAccommodationExpanded = true;
  bool _isDietaryExpanded = true;
  bool _isTransportExpanded = true;
  bool _isActivitiesExpanded = true;

  final Map<String, bool> _accommodationOptions = accommodationOptions;
  final Map<String, bool> _dietaryOptions = dietaryOptions;
  final Map<String, bool> _transportOptions = transportOptions;
  final Map<String, bool> _activitiesOptions = activitiesOptions;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateOption(
    Map<String, bool> options,
    String option,
    bool value,
  ) {
    setState(() {
      options[option] = value;
    });
  }

  void _onSubmit() {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                ExpandableSection(
                  title: 'Accommodation',
                  isExpanded: _isAccommodationExpanded,
                  onExpansionChanged: (isExpanded) {
                    setState(() {
                      _isAccommodationExpanded = isExpanded;
                    });
                  },
                  options: _accommodationOptions,
                  onOptionChanged: (option, value) =>
                      _updateOption(_accommodationOptions, option, value),
                  columnCount: 2,
                ),
                ExpandableSection(
                  title: 'Dietary',
                  isExpanded: _isDietaryExpanded,
                  onExpansionChanged: (isExpanded) {
                    setState(() {
                      _isDietaryExpanded = isExpanded;
                    });
                  },
                  options: _dietaryOptions,
                  onOptionChanged: (option, value) =>
                      _updateOption(_dietaryOptions, option, value),
                  columnCount: 2,
                ),
                ExpandableSection(
                  title: 'Transport',
                  isExpanded: _isTransportExpanded,
                  onExpansionChanged: (isExpanded) {
                    setState(() {
                      _isTransportExpanded = isExpanded;
                    });
                  },
                  options: _transportOptions,
                  onOptionChanged: (option, value) =>
                      _updateOption(_transportOptions, option, value),
                  columnCount: 2,
                ),
                ExpandableSection(
                  title: 'Activities',
                  isExpanded: _isActivitiesExpanded,
                  onExpansionChanged: (isExpanded) {
                    setState(() {
                      _isActivitiesExpanded = isExpanded;
                    });
                  },
                  options: _activitiesOptions,
                  onOptionChanged: (option, value) =>
                      _updateOption(_activitiesOptions, option, value),
                  columnCount: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Additional Notes',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _onSubmit(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
