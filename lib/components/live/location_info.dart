import 'package:askngo/components/live/location_map.dart';
import 'package:askngo/types/location.dart';
import 'package:flutter/material.dart';

class LocationDetails extends StatefulWidget {
  final Location location;

  const LocationDetails({
    required this.location,
    super.key,
  });

  @override
  State<LocationDetails> createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  late Location _location;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_location.name),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _detailsBody(),
        ),
      ],
    );
  }

  @override
  void initState() {
    _location = widget.location;
    _nameController.text = _location.name;
    _descriptionController.text = _location.description ?? '';
    return super.initState();
  }

  @override
  void didUpdateWidget(LocationDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.location != oldWidget.location) {
      setState(() {
        _location = widget.location;

        if (_nameController.text != widget.location.name) {
          _nameController.text = widget.location.name;
        }

        if (_descriptionController.text != (widget.location.description ?? '')) {
          _descriptionController.text = widget.location.description ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _detailsBody() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      children: [
        _NameTextField(
          controller: _nameController,
          onChanged: (value) {
            setState(() {
              _location = _location.copyWith(name: value);
            });
          },
        ),
        _DescriptionTextField(
          controller: _descriptionController,
          onChanged: (value) {
            setState(() {
              _location = _location.copyWith(description: value);
            });
          },
        ),
        _StarBar(
          rating: _location.starRating,
          onChanged: (value) {
            setState(() {
              _location = _location.copyWith(starRating: value);
            });
          },
        ),
        const _Reviews(),
      ],
    );
  }
}

class _DescriptionTextField extends StatelessWidget {
  final TextEditingController controller;

  final ValueChanged<String> onChanged;

  const _DescriptionTextField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Description',
          labelStyle: TextStyle(fontSize: 18.0),
        ),
        style: const TextStyle(fontSize: 20.0, color: Colors.black87),
        maxLines: null,
        autocorrect: true,
        controller: controller,
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }
}

class _NameTextField extends StatelessWidget {
  final TextEditingController controller;

  final ValueChanged<String> onChanged;

  const _NameTextField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Name',
          labelStyle: TextStyle(fontSize: 18),
        ),
        style: const TextStyle(fontSize: 20, color: Colors.black87),
        autocorrect: true,
        controller: controller,
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }
}

class _Reviews extends StatelessWidget {
  const _Reviews();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Reviews',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Column(
          children: StubData.reviewStrings
              .map((reviewText) => _buildSingleReview(reviewText))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSingleReview(String reviewText) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    width: 3,
                    color: Colors.grey,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  reviewText,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 8,
          color: Colors.grey[700],
        ),
      ],
    );
  }
}

class _StarBar extends StatelessWidget {
  static const int maxStars = 5;

  final int rating;
  final ValueChanged<int> onChanged;

  const _StarBar({
    required this.rating,
    required this.onChanged,
  }) : assert(rating >= 0 && rating <= maxStars);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        return IconButton(
          icon: const Icon(Icons.star),
          iconSize: 40,
          color: rating > index ? Colors.amber : Colors.grey[400],
          onPressed: () {
            onChanged(index + 1);
          },
        );
      }).toList(),
    );
  }
}
