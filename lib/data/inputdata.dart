import 'package:flutter/material.dart';

class SawahInputFields extends StatelessWidget {
  final TextEditingController gkgController;
  final TextEditingController luasController;

  const SawahInputFields({
    Key? key,
    required this.gkgController,
    required this.luasController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gabah Kering Giling (GKG/ton)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: gkgController,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Luas Sawah (m²)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: luasController,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
