
// FoodShare KuGompo - Administrator Dashboard.
// Required image: assets/images/admin_bg.jpeg (optional).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Set<String> _processingDonors = <String>{};

  static const Color _green = Color(0xFF187A45);
  static const Color _darkGreen = Color(0xFF105A34);
  static const Color _pageBackground = Color(0xFFF4F7F3);
  static const Color _orange = Color(0xFFE99A35);
  static const Color _blue = Color(0xFF3977C3);
  static const Color _red = Color(0xFFC94B4B);

  // VERIFY THAT THE SIGNED-IN USER IS AN ADMINISTRATOR.
  Future<bool> _verifyAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in again.');
      return false;
    }

    try {
      final tokenResult = await user.getIdTokenResult(true);
      final isAdmin = tokenResult.claims?['admin'] == true;

      if (!isAdmin) {
        _showMessage(
          'Access denied. Administrator permissions required.',
        );
        return false;
      }

      return true;
    } catch (error) {
      _showMessage('Could not verify administrator access: $error');
      return false;
    }
  }

  // APPROVE A DONOR.
  Future<void> _approveDonor(
    QueryDocumentSnapshot<Map<String, dynamic>> donor,
  ) async {
    if (!await _verifyAdminAccess()) return;
    if (!mounted) return;

    setState(() => _processingDonors.add(donor.id));

    try {
      await _db.collection('users').doc(donor.id).update({
        'isVerified': true,
        'approvalStatus': 'approved',
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      _showMessage('${_nameOf(donor.data())} has been approved.');
    } on FirebaseException catch (error) {
      _showMessage(
        'Could not approve donor: ${error.message ?? error.code}',
      );
    } catch (error) {
      _showMessage('Could not approve donor: $error');
    } finally {
      if (mounted) {
        setState(() => _processingDonors.remove(donor.id));
      }
    }
  }

  // REJECT A DONOR.
  Future<void> _rejectDonor(
    QueryDocumentSnapshot<Map<String, dynamic>> donor,
  ) async {
    final name = _nameOf(donor.data());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject donor application?'),
        content: Text('Are you sure you want to reject $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    if (!await _verifyAdminAccess()) return;
    if (!mounted) return;

    setState(() => _processingDonors.add(donor.id));

    try {
      await _db.collection('users').doc(donor.id).update({
        'isVerified': false,
        'approvalStatus': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      _showMessage('$name has been rejected.');
    } on FirebaseException catch (error) {
      _showMessage(
        'Could not reject donor: ${error.message ?? error.code}',
      );
    } catch (error) {
      _showMessage('Could not reject donor: $error');
    } finally {
      if (mounted) {
        setState(() => _processingDonors.remove(donor.id));
      }
    }
  }

  // SIGN OUT.
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      _showMessage('Could not sign out: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String _nameOf(Map<String, dynamic> data) {
    final name = data['fullName']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return data['email']?.toString() ?? 'Unknown donor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism_rounded, size: 25),
            SizedBox(width: 10),
            Text(
              'FoodShare Admin',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/admin_bg.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(color: _pageBackground);
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.94),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _db.collection('users').snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasError) {
                return _errorView(
                  'Unable to load users',
                  userSnapshot.error,
                );
              }

              if (!userSnapshot.hasData) {
                return _loadingView();
              }

              final users = userSnapshot.data!.docs;

              final donors = users
                  .where((doc) => doc.data()['role'] == 'Donor')
                  .toList();

              final recipients = users
                  .where((doc) => doc.data()['role'] == 'Recipient')
                  .toList();

              final approvedDonors = donors
                  .where((doc) => doc.data()['isVerified'] == true)
                  .length;

              final pendingDonors = donors.where((doc) {
                final data = doc.data();

                return data['isVerified'] != true &&
                    data['approvalStatus'] != 'rejected';
              }).toList();

              final rejectedDonors = donors
                  .where(
                    (doc) => doc.data()['approvalStatus'] == 'rejected',
                  )
                  .length;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _db.collection('food_donations').snapshots(),
                builder: (context, donationSnapshot) {
                  if (donationSnapshot.hasError) {
                    return _errorView(
                      'Unable to load donations',
                      donationSnapshot.error,
                    );
                  }

                  if (!donationSnapshot.hasData) {
                    return _loadingView();
                  }

                  final donations = donationSnapshot.data!.docs;

                  final availableDonations = donations
                      .where(
                        (doc) => doc.data()['status'] == 'available',
                      )
                      .length;

                  final collectedDonations = donations
                      .where(
                        (doc) => doc.data()['status'] == 'collected',
                      )
                      .length;

                  final soldOutDonations = donations
                      .where(
                        (doc) => doc.data()['status'] == 'sold_out',
                      )
                      .length;

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _db.collection('claims').snapshots(),
                    builder: (context, claimSnapshot) {
                      if (claimSnapshot.hasError) {
                        return _errorView(
                          'Unable to load requests',
                          claimSnapshot.error,
                        );
                      }

                      if (!claimSnapshot.hasData) {
                        return _loadingView();
                      }

                      final claims = claimSnapshot.data!.docs;

                      final pendingClaims = claims
                          .where(
                            (doc) => doc.data()['status'] == 'pending',
                          )
                          .length;

                      final collectedClaims = claims
                          .where(
                            (doc) => doc.data()['status'] == 'collected',
                          )
                          .length;

                      return RefreshIndicator(
                        color: _green,
                        onRefresh: () async {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 350),
                          );
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            20,
                            18,
                            30,
                          ),
                          children: [
                            _welcomeBanner(
                              users.length,
                              pendingDonors.length,
                            ),
                            const SizedBox(height: 20),

                            _sectionHeading(
                              'Platform overview',
                              'Live figures from your FoodShare database',
                            ),
                            const SizedBox(height: 12),

                            _statisticsGrid(
                              context,
                              totalUsers: users.length,
                              donors: donors.length,
                              recipients: recipients.length,
                              donations: donations.length,
                              claims: claims.length,
                            ),
                            const SizedBox(height: 20),

                            _chartsSection(
                              donorCount: donors.length,
                              recipientCount: recipients.length,
                              available: availableDonations,
                              collected: collectedDonations,
                              soldOut: soldOutDonations,
                            ),
                            const SizedBox(height: 22),

                            _sectionHeading(
                              'Donor applications',
                              'Review and approve people who want to donate food',
                              trailing: _countPill(
                                '${pendingDonors.length} pending',
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (pendingDonors.isEmpty)
                              _emptyState(
                                Icons.verified_rounded,
                                'No pending donor applications',
                                'New donor registrations will appear here.',
                              )
                            else
                              ...pendingDonors.map(_pendingDonorCard),

                            const SizedBox(height: 22),

                            _sectionHeading(
                              'Donor approval summary',
                              'Current donor account status',
                            ),
                            const SizedBox(height: 10),

                            _approvalSummary(
                              approved: approvedDonors,
                              pending: pendingDonors.length,
                              rejected: rejectedDonors,
                            ),
                            const SizedBox(height: 22),

                            _sectionHeading(
                              'Food and collection activity',
                              'A quick view of activity on the platform',
                            ),
                            const SizedBox(height: 10),

                            _activitySummary(
                              available: availableDonations,
                              soldOut: soldOutDonations,
                              collected: collectedDonations,
                              pendingClaims: pendingClaims,
                              collectedClaims: collectedClaims,
                            ),
                            const SizedBox(height: 18),

                            const Center(
                              child: Text(
                                'FoodShare KuGompo • Admin panel',
                                style: TextStyle(
                                  color: Color(0xFF849087),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _loadingView() {
    return const Center(
      child: CircularProgressIndicator(color: _green),
    );
  }

  Widget _errorView(String title, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 46,
              color: _red,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeBanner(int totalUsers, int pendingDonors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, _darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Administrator!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$totalUsers registered users on FoodShare KuGompo',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$pendingDonors donor${pendingDonors == 1 ? '' : 's'} awaiting review',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF20372A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF7B887F),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _statisticsGrid(
    BuildContext context, {
    required int totalUsers,
    required int donors,
    required int recipients,
    required int donations,
    required int claims,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 3 : 2;
        const spacing = 11.0;

        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final cards = <Widget>[
          _statCard(
            'Total users',
            '$totalUsers',
            Icons.people_alt_rounded,
            _blue,
          ),
          _statCard(
            'Donors',
            '$donors',
            Icons.volunteer_activism_rounded,
            _green,
          ),
          _statCard(
            'Recipients',
            '$recipients',
            Icons.people_rounded,
            _orange,
          ),
          _statCard(
            'Donations',
            '$donations',
            Icons.inventory_2_rounded,
            const Color(0xFF8062B2),
          ),
          _statCard(
            'Food requests',
            '$claims',
            Icons.receipt_long_rounded,
            const Color(0xFF268D9B),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF20372A),
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7B887F),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartsSection({
    required int donorCount,
    required int recipientCount,
    required int available,
    required int collected,
    required int soldOut,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;

        final roleChart = _chartCard(
          title: 'Community members',
          subtitle: 'Donors compared with recipients',
          child: Row(
            children: [
              SizedBox(
                width: 145,
                height: 145,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(145, 145),
                      painter: _DonutChartPainter(
                        firstValue: donorCount,
                        secondValue: recipientCount,
                        firstColor: _green,
                        secondColor: _orange,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${donorCount + recipientCount}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF20372A),
                          ),
                        ),
                        const Text(
                          'members',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7B887F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem('Donors', donorCount, _green),
                    const SizedBox(height: 13),
                    _legendItem('Recipients', recipientCount, _orange),
                  ],
                ),
              ),
            ],
          ),
        );

        final total = available + collected + soldOut;

        final donationChart = _chartCard(
          title: 'Donation status',
          subtitle: 'Current listing breakdown',
          child: Column(
            children: [
              _barItem('Available', available, _green, total),
              const SizedBox(height: 15),
              _barItem('Collected', collected, _blue, total),
              const SizedBox(height: 15),
              _barItem('Sold out', soldOut, _orange, total),
            ],
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: roleChart),
              const SizedBox(width: 12),
              Expanded(child: donationChart),
            ],
          );
        }

        return Column(
          children: [
            roleChart,
            const SizedBox(height: 12),
            donationChart,
          ],
        );
      },
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7B887F),
            ),
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }

  Widget _legendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF657269),
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _barItem(
    String label,
    int value,
    Color color,
    int total,
  ) {
    final double progress = total == 0
        ? 0.0
        : (value / total).clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF657269),
                ),
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: const Color(0xFFEDF1ED),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _pendingDonorCard(
    QueryDocumentSnapshot<Map<String, dynamic>> donor,
  ) {
    final data = donor.data();
    final name = _nameOf(data);
    final email = data['email']?.toString() ?? 'No email provided';
    final busy = _processingDonors.contains(donor.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFE5F2E9),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'D',
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B887F),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Color(0xFF9A641D),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => _rejectDonor(donor),
                  icon: const Icon(Icons.close_rounded, size: 17),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _red,
                    side: const BorderSide(
                      color: Color(0xFFE8CACA),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : () => _approveDonor(donor),
                  icon: busy
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 17),
                  label: Text(busy ? 'Saving...' : 'Approve donor'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9A641D),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyState(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _green, size: 35),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7B887F),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvalSummary({
    required int approved,
    required int pending,
    required int rejected,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _smallMetric('Approved', approved, _green),
          ),
          _verticalDivider(),
          Expanded(
            child: _smallMetric('Pending', pending, _orange),
          ),
          _verticalDivider(),
          Expanded(
            child: _smallMetric('Rejected', rejected, _red),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 38,
      width: 1,
      color: const Color(0xFFE8EEE8),
    );
  }

  Widget _smallMetric(
    String label,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7B887F),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _activitySummary({
    required int available,
    required int soldOut,
    required int collected,
    required int pendingClaims,
    required int collectedClaims,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Column(
        children: [
          _activityRow(
            Icons.inventory_2_outlined,
            'Available food listings',
            available,
            _green,
          ),
          const Divider(height: 22),
          _activityRow(
            Icons.remove_shopping_cart_outlined,
            'Sold-out listings',
            soldOut,
            _orange,
          ),
          const Divider(height: 22),
          _activityRow(
            Icons.task_alt_rounded,
            'Collected listings',
            collected,
            _blue,
          ),
          const Divider(height: 22),
          _activityRow(
            Icons.hourglass_top_rounded,
            'Pending food requests',
            pendingClaims,
            _orange,
          ),
          const Divider(height: 22),
          _activityRow(
            Icons.check_circle_outline_rounded,
            'Completed collections',
            collectedClaims,
            _green,
          ),
        ],
      ),
    );
  }

  Widget _activityRow(
    IconData icon,
    String label,
    int value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF657269),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: Color(0xFF20372A),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// DONUT CHART PAINTER.
class _DonutChartPainter extends CustomPainter {
  final int firstValue;
  final int secondValue;
  final Color firstColor;
  final Color secondColor;

  const _DonutChartPainter({
    required this.firstValue,
    required this.secondValue,
    required this.firstColor,
    required this.secondColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    const strokeWidth = 17.0;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final total = firstValue + secondValue;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEDF1ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      0,
      2 * 3.141592653589793,
      false,
      backgroundPaint,
    );

    if (total == 0) return;

    final firstSweep =
        2 * 3.141592653589793 * firstValue / total;

    final firstPaint = Paint()
      ..color = firstColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final secondPaint = Paint()
      ..color = secondColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const startAngle = -3.141592653589793 / 2;

    canvas.drawArc(
      rect,
      startAngle,
      firstSweep,
      false,
      firstPaint,
    );

    canvas.drawArc(
      rect,
      startAngle + firstSweep,
      2 * 3.141592653589793 - firstSweep,
      false,
      secondPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _DonutChartPainter oldDelegate,
  ) {
    return oldDelegate.firstValue != firstValue ||
        oldDelegate.secondValue != secondValue ||
        oldDelegate.firstColor != firstColor ||
        oldDelegate.secondColor != secondColor;
  }
}
