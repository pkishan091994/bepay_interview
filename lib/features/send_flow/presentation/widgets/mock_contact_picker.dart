import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';

class MockContact {
  final String name;
  final String primaryHandle;
  final List<String> handles;
  final Color avatarColor;
  final Color textColor;

  const MockContact({
    required this.name,
    required this.primaryHandle,
    required this.handles,
    required this.avatarColor,
    required this.textColor,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : '';
  }
}

/// A custom, premium contacts directory bottom sheet.
///
/// Features dynamic search filtering and click-to-select chip layout
/// for various handles (username@bepay, emails, phone numbers, addresses).
class MockContactPicker extends StatefulWidget {
  const MockContactPicker({super.key});

  /// Displays the contact picker bottom sheet and returns the selected handle value.
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MockContactPicker(),
    );
  }

  @override
  State<MockContactPicker> createState() => _MockContactPickerState();
}

class _MockContactPickerState extends State<MockContactPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<MockContact> _contacts = const [
    MockContact(
      name: 'Emma Watson',
      primaryHandle: 'emma@bepay',
      handles: ['emma@bepay', 'emma@example.com'],
      avatarColor: Color(0xFFE8EAF6),
      textColor: Color(0xFF3F51B5),
    ),
    MockContact(
      name: 'Alex Morgan',
      primaryHandle: 'alex_m@bepay',
      handles: ['alex_m@bepay', '+919876543210'],
      avatarColor: Color(0xFFF3E5F5),
      textColor: Color(0xFF9C27B0),
    ),
    MockContact(
      name: 'David Beckham',
      primaryHandle: 'david@bepay',
      handles: ['david@bepay', '0x742d35Cc6634C0532925a3b844Bc454e4438f44e'],
      avatarColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF4CAF50),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Filter contacts based on search query
    final filteredContacts = _contacts.where((contact) {
      final query = _searchQuery.toLowerCase();
      final matchesName = contact.name.toLowerCase().contains(query);
      final matchesHandle = contact.handles.any((h) => h.toLowerCase().contains(query));
      return matchesName || matchesHandle;
    }).toList();

    return Container(
      height: screenHeight * 0.75,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Top drag handle
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Select Contact',
                  style: AppTheme.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.textSecondary,
                  splashRadius: 20.r,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: TextFormField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: AppTheme.inter(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search name, email, phone, or address',
                  hintStyle: AppTheme.inter(
                    fontSize: 13.sp,
                    color: AppTheme.textMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.textMuted,
                    size: 20.w,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: AppTheme.textMuted,
                            size: 18.w,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Directory List
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found',
                      style: AppTheme.inter(
                        color: AppTheme.textMuted,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: filteredContacts.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1.h,
                      color: AppTheme.borderColor.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 22.r,
                              backgroundColor: contact.avatarColor,
                              child: Text(
                                contact.initials,
                                style: AppTheme.outfit(
                                  color: contact.textColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),

                            // Details & handles
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: AppTheme.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  // Selection chips for handles
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 6.h,
                                    children: contact.handles.map((handle) {
                                      final isAddress = handle.startsWith('0x');
                                      final displayLabel = isAddress
                                          ? '${handle.substring(0, 6)}...${handle.substring(handle.length - 4)}'
                                          : handle;

                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop(handle);
                                        },
                                        borderRadius: BorderRadius.circular(20.r),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.background,
                                            border: Border.all(
                                              color: AppTheme.borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isAddress
                                                    ? Icons.account_balance_wallet_outlined
                                                    : handle.contains('@')
                                                        ? Icons.email_outlined
                                                        : handle.startsWith('+')
                                                            ? Icons.phone_outlined
                                                            : Icons.alternate_email_rounded,
                                                size: 12.w,
                                                color: AppTheme.textSecondary,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                displayLabel,
                                                style: AppTheme.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
