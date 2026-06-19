import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/home/presentation/screens/home_screen.dart';
import 'package:sadak_sevak_citizen/features/map/presentation/screens/map_screen.dart';
import 'package:sadak_sevak_citizen/features/profile/presentation/screens/profile_screen.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaints_list_screen.dart';
import 'package:sadak_sevak_citizen/features/report/presentation/screens/report_issue_screen.dart';
import 'package:sadak_sevak_citizen/features/field_team/presentation/screens/field_team_dashboard.dart';
import 'package:sadak_sevak_citizen/features/field_team/presentation/screens/my_tasks_screen.dart';
import 'package:sadak_sevak_citizen/features/field_team/presentation/screens/field_team_profile_screen.dart';
import 'package:sadak_sevak_citizen/features/field_team/presentation/screens/field_team_notifications_screen.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_dashboard_screen.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_complaints_screen.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_work_management_screen.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_more_hub_screen.dart';
import 'package:sadak_sevak_citizen/features/contractor/presentation/screens/contractor_dashboard_screen.dart';
import 'package:sadak_sevak_citizen/features/contractor/presentation/screens/contractor_jobs_screen.dart';
import 'package:sadak_sevak_citizen/features/contractor/presentation/screens/contractor_notifications_screen.dart';
import 'package:sadak_sevak_citizen/features/contractor/presentation/screens/contractor_profile_screen.dart';
import 'package:sadak_sevak_citizen/features/home/data/notification_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/socket_service.dart';

class MainLayout extends StatefulWidget {
  final String role;
  const MainLayout({super.key, this.role = 'citizen'});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  int _unreadCount = 0;
  final _notifyRepo = NotificationRepository();

  @override
  void initState() {
    super.initState();
    _initSocketAndListen();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notifyRepo.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  void dispose() {
    SocketService().stopListeningToNotifications();
    super.dispose();
  }

  Future<void> _initSocketAndListen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('user_id') ?? '';

    if (token.isNotEmpty && userId.isNotEmpty) {
      // Connect to the socket server
      SocketService().init(token);
      
      // Join the user-specific notifications room
      SocketService().joinUserRoom(userId);

      // Listen to push notifications
      SocketService().listenToNotifications((data) {
        if (mounted) {
          // Increment the badge counter
          setState(() => _unreadCount++);

          final title = data['title'] ?? 'Notification';
          final message = data['message'] ?? 'You have a new update';
          final type = data['type'] ?? 'status_update';

          IconData icon;
          Color color;
          switch (type) {
            case 'comment':
              icon = Icons.chat_bubble_outline_rounded;
              color = Colors.orange;
              break;
            case 'escalation':
              icon = Icons.warning_amber_rounded;
              color = Colors.red;
              break;
            case 'broadcast':
              icon = Icons.campaign_outlined;
              color = Colors.purple;
              break;
            default:
              icon = Icons.notifications_none_rounded;
              color = AppTheme.primaryColor;
          }

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF003D26), // Darker green surface
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  void navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> get _screens {
    final role = widget.role.toLowerCase();
    if (role == 'team_member') {
      return [
        const FieldTeamDashboard(),
        const MapScreen(),
        const MyTasksScreen(),
        const FieldTeamNotificationsScreen(),
        const FieldTeamProfileScreen(),
      ];
    }
    if (role == 'contractor') {
      return [
        const ContractorDashboardScreen(),
        const ContractorJobsScreen(),
        const ContractorNotificationsScreen(),
        const ContractorProfileScreen(),
      ];
    }
    if (role == 'government' || role == 'admin' || role == 'department_head') {
      return [
        const GovernmentDashboardScreen(),
        const GovernmentComplaintsScreen(),
        const GovernmentWorkManagementScreen(),
        const GovernmentMoreHubScreen(),
      ];
    }
    return [
      const HomeScreen(),
      const MapScreen(),
      const ComplaintsListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role.toLowerCase();
    debugPrint('MainLayout: Building for role: $role');
    const teamBlue = Color(0xFF4A80F0);
    const primaryOrange = Color(0xFFF4511E);

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex.clamp(0, _screens.length - 1)],
      floatingActionButton: widget.role == 'citizen'
          ? SizedBox(
              height: 65,
              width: 65,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportIssueScreen(),
                    ),
                  );
                },
                backgroundColor: AppTheme.primaryColor,
                elevation: 8,
                heroTag: 'main_fab',
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: Colors.white,
        shape: widget.role == 'citizen'
            ? const CircularNotchedRectangle()
            : null,
        notchMargin: 10,
        elevation: 20,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: role == 'team_member'
              ? [
                  _navItem(
                    0,
                    Icons.home_outlined,
                    Icons.home_rounded,
                    'Home',
                    teamBlue,
                  ),
                  _navItem(
                    1,
                    Icons.map_outlined,
                    Icons.map_rounded,
                    'Map',
                    teamBlue,
                  ),
                  _navItem(
                    2,
                    Icons.assignment_outlined,
                    Icons.assignment_rounded,
                    'Tasks',
                    teamBlue,
                  ),
                  _navItemWithBadge(
                    3,
                    Icons.notifications_outlined,
                    Icons.notifications_rounded,
                    'Alerts',
                    teamBlue,
                    badge: _unreadCount,
                    onTap: () {
                      setState(() { _selectedIndex = 3; _unreadCount = 0; });
                    },
                  ),
                  _navItem(
                    4,
                    Icons.person_outline_rounded,
                    Icons.person_rounded,
                    'Profile',
                    teamBlue,
                  ),
                ]
              : (role == 'contractor')
              ? [
                  _navItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard_rounded,
                    'Dashboard',
                    AppTheme.primaryColor,
                  ),
                  _navItem(
                    1,
                    Icons.assignment_outlined,
                    Icons.assignment_rounded,
                    'Orders',
                    AppTheme.primaryColor,
                  ),
                  _navItem(
                    2,
                    Icons.notifications_outlined,
                    Icons.notifications_rounded,
                    'Alerts',
                    AppTheme.primaryColor,
                  ),
                  _navItem(
                    3,
                    Icons.person_outline_rounded,
                    Icons.person_rounded,
                    'Profile',
                    AppTheme.primaryColor,
                  ),
                ]
              : (role == 'government' ||
                    role == 'admin' ||
                    role == 'department_head')
              ? [
                  _navItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard_rounded,
                    'Dashboard',
                    primaryOrange,
                  ),
                  _navItem(
                    1,
                    Icons.campaign_outlined,
                    Icons.campaign_rounded,
                    'Complaints',
                    primaryOrange,
                  ),
                  _navItem(
                    2,
                    Icons.construction_outlined,
                    Icons.construction_rounded,
                    'Work',
                    primaryOrange,
                  ),
                  _navItem(
                    3,
                    Icons.more_horiz_outlined,
                    Icons.more_horiz_rounded,
                    'More',
                    primaryOrange,
                  ),
                ]
              : [
                  _navItem(
                    0,
                    Icons.home_outlined,
                    Icons.home_rounded,
                    'Home',
                    AppTheme.primaryColor,
                  ),
                  _navItem(
                    1,
                    Icons.map_outlined,
                    Icons.map_rounded,
                    'Map',
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 40), // Space for FAB
                  _navItem(
                    2,
                    Icons.list_alt_outlined,
                    Icons.list_alt_rounded,
                    'My Complaints',
                    AppTheme.primaryColor,
                  ),
                  _navItem(
                    3,
                    Icons.person_outline_rounded,
                    Icons.person_rounded,
                    'Profile',
                    AppTheme.primaryColor,
                  ),
                ],
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    Color activeColor, {
    VoidCallback? onTap,
  }) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ?? () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? activeColor.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selected ? filledIcon : outlineIcon,
              color: selected ? activeColor : Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? activeColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItemWithBadge(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    Color activeColor, {
    int badge = 0,
    VoidCallback? onTap,
  }) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ?? () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? activeColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selected ? filledIcon : outlineIcon,
                  color: selected ? activeColor : Colors.grey.shade500,
                  size: 24,
                ),
              ),
              if (badge > 0)
                Positioned(
                  top: 0,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? activeColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

