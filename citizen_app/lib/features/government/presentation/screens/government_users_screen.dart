import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/auth/domain/user_model.dart';

class GovernmentUsersScreen extends StatefulWidget {
  const GovernmentUsersScreen({super.key});

  @override
  State<GovernmentUsersScreen> createState() => _GovernmentUsersScreenState();
}

class _GovernmentUsersScreenState extends State<GovernmentUsersScreen> {
  final GovernmentRepository _repository = GovernmentRepository();
  String selectedRoleFilter = 'All Roles';
  bool _isLoading = true;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _repository.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    final filteredUsers = _users.where((user) {
      if (selectedRoleFilter == 'All Roles') return true;
      return user.role.toLowerCase() == selectedRoleFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Users & Roles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Role Filter Chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: <String>['All Roles', 'admin', 'department_head', 'team_member', 'government']
                  .map((role) {
                final isSelected = selectedRoleFilter == role;
                // Display friendly label
                String label = role;
                if (role == 'department_head') label = 'Dept Head';
                if (role == 'team_member') label = 'Team Member';
                if (role == 'government') label = 'Government';
                if (role == 'admin') label = 'Admin';
                if (role == 'All Roles') label = 'All Roles';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => selectedRoleFilter = role);
                    },
                    selectedColor: primaryOrange,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? primaryOrange : Colors.grey.shade300),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // User list
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryOrange))
              : _users.isEmpty 
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isActive = true; // Replace with actual status field if added to backend

                      return FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 50 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                                    ? NetworkImage(user.avatar!)
                                    : null,
                                backgroundColor: Colors.grey.shade200,
                                child: user.avatar == null || user.avatar!.isEmpty
                                    ? Icon(Icons.person, color: Colors.grey.shade400)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // Name and role details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: primaryOrange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              user.role.toUpperCase(),
                                              style: const TextStyle(fontSize: 10, color: primaryOrange, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              user.email,
                                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: Colors.blue.shade400, size: 20),
                                      onPressed: () {},
                                      tooltip: 'Edit User',
                                    ),
                                    Switch(
                                      value: isActive,
                                      onChanged: (val) {},
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.grey.shade400,
                                      inactiveTrackColor: Colors.grey.shade200,
                                    ),
                                  ],
                                ),
                              ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
