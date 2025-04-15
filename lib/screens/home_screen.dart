import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for the main body
      appBar: AppBar(
        title: Text('SmartVision', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 90, // Adjusted height for a better look
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C0E47), Color(0xFF3A4D8A)], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 30.0), // Added top padding for better alignment
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HomeButton(
              icon: Icons.visibility,
              label: 'Detection',
              onTap: () {
                // Navigate to Object & Face Detection
              },
            ),
            SizedBox(height: 25), // More spacing between buttons
            HomeButton(
              icon: Icons.phone,
              label: 'Call Help',
              onTap: () {
                // Navigate to Call Help or trigger emergency call
              },
            ),
            SizedBox(height: 25), // More spacing between buttons
            HomeButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                // Navigate to Settings
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 50), // Larger icon size for better visual impact
      label: Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // Larger and bold font for readability
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 70), // Larger button size
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 18), // Vertical padding for better touch area
        elevation: 5, // Added shadow for depth
      ),
    );
  }
}
