import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:mycafe/view/widget/primary_button.dart'; 

typedef OnSaveCallback = Future<void> Function(String username, String gender);
typedef OnCancelCallback = void Function();

class InfoCard extends StatelessWidget {
  final User? currentUser;
  final String username;
  final String gender;
  final DateTime? createdAt;
  final bool isEditing;
  final bool isUpdating;
  final TextEditingController usernameController;
  final String selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final OnSaveCallback onSave;
  final OnCancelCallback onCancel;

  const InfoCard({
    super.key,
    required this.currentUser,
    required this.username,
    required this.gender,
    required this.createdAt,
    required this.isEditing,
    required this.isUpdating,
    required this.usernameController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onSave,
    required this.onCancel,
  });

  Widget _buildInfoRow(IconData icon, String label, String value) {
    const iconColor = Color.fromARGB(255, 78, 52, 46);
    const textColor = Color.fromARGB(255, 78, 52, 46);
    const valueColor = Color.fromARGB(255, 78, 52, 46);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isEditing
                ? TextField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 78, 52, 46)),
                      ),
                    ),
                  )
                : _buildInfoRow(Icons.person, 'Username', username.isEmpty ? 'Belum diatur' : username),
            const Divider(color: Colors.grey),

            _buildInfoRow(Icons.email, 'Email', currentUser!.email ?? 'N/A'),
            const Divider(color: Colors.grey),

            isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Kelamin',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      RadioListTile<String>(
                        title: const Text('Pria', style: TextStyle(color: Colors.black87)),
                        value: 'Pria',
                        groupValue: selectedGender,
                        activeColor: const Color.fromARGB(255, 78, 52, 46),
                        onChanged: onGenderChanged,
                      ),
                      RadioListTile<String>(
                        title: const Text('Wanita', style: TextStyle(color: Colors.black87)),
                        value: 'Wanita',
                        groupValue: selectedGender,
                        activeColor: const Color.fromARGB(255, 78, 52, 46),
                        onChanged: onGenderChanged,
                      ),
                    ],
                  )
                : _buildInfoRow(Icons.people, 'Jenis Kelamin', gender.isEmpty ? 'Belum diatur' : gender),
            const Divider(color: Colors.grey),

            _buildInfoRow(Icons.calendar_today, 'Tanggal Dibuat', _formatDate(createdAt)),

            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      child: PrimaryButton(
                        text: 'Batal',
                        onPressed: isUpdating ? null : onCancel,
                        isLoading: false,
                        buttonType: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: PrimaryButton(
                        text: 'Simpan',
                        onPressed: isUpdating ? null : () => onSave(usernameController.text, selectedGender),
                        isLoading: isUpdating,
                        buttonType: ButtonType.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
