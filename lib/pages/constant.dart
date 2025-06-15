import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF086C0C);
const Color grey = Color(0xFFEFFAF0);
const Color dustYellow = Color.fromARGB(255, 241, 223, 157);
const Color babyBlue = Color(0xFFACDBFE);


class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 36,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
      ),
    ),
  );
}
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 36,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  );
}

}
