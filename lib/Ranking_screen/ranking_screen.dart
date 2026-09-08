import 'package:flutter/material.dart';
import '../Feed_screen/public_profile_screen.dart';
import '../services and managers/leader_board_services.dart';
import '../services and managers/location_list_service.dart';
import '../services and managers/school_list_service.dart';
import '../widgets/fama_bottom_nav.dart';
import '../Feed_screen/post_now_popup.dart';
import '../widgets/gender_picker_drop_sheet.dart';
import '../widgets/picker_sheet.dart';
import '../services and managers/profile_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';

/// Internal unified shape used to render both the users-leaderboard
/// and videos-leaderboard grids with the same card UI.
class _LeaderboardDisplayItem {
  final int rank;
  final String name;
  final String? avatarUrl;
  final int points;
  final int userId;
  final bool isVideo;

  const _LeaderboardDisplayItem({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.userId,
    this.isVideo = false,
  });
}

/// Ranking screen — Celebrities / Videos tabs ke sath leaderboard grid.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);
  static const Color _whatsappColor = Color(0xFF298C4E);
  static const Color _rankBadgeColor = Color(0xFFE12C2C);

  bool _isCelebritiesTab = true;

  // 'Day' | 'Week' | 'Month' | 'All Time'
  String _selectedTimeFilter = 'All Time';

  // Filter chip selections
  PickerItem? _selectedLocation;
  PickerItem? _selectedSchool;
  String? _selectedGender;

  // Top bar star pill — live fama points
  int _famaPoints = 0;

  // Leaderboard data
  List<LeaderboardUserEntry> _leaderboardUsers = [];
  List<LeaderboardVideoEntry> _leaderboardVideos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFamaPoints();
      _fetchLeaderboard();
    });
  }

  // ── Fama points fetch (top bar star pill ke liye) ─────────────────────

  Future<void> _fetchFamaPoints() async {
    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) return;

    try {
      final profile = await ProfileApiService.getProfile(token: token);
      if (!mounted) return;
      setState(() => _famaPoints = profile.user.famaPoints);
    } catch (e) {
      debugPrint('RANKING DEBUG -> fama points fetch error: $e');
      // Silent fail — top bar bas 0 ya last known value dikhata rahega.
    }
  }

  // ── Leaderboard fetch ───────────────────────────────────────────────

  LeaderboardRange _rangeFromFilter(String filter) {
    switch (filter) {
      case 'Day':
        return LeaderboardRange.day;
      case 'Week':
        return LeaderboardRange.week;
      case 'Month':
        return LeaderboardRange.month;
      case 'All Time':
      default:
        return LeaderboardRange.all;
    }
  }

  Future<void> _fetchLeaderboard() async {
    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    final LeaderboardRange range = _rangeFromFilter(_selectedTimeFilter);
    final int? locationId =
    _selectedLocation != null ? int.tryParse(_selectedLocation!.id) : null;
    final int? schoolId =
    _selectedSchool != null ? int.tryParse(_selectedSchool!.id) : null;
    final String? gender = _selectedGender?.toLowerCase();

    AppHelpers.showLoader();

    try {
      if (_isCelebritiesTab) {
        final List<LeaderboardUserEntry> users =
        await LeaderboardService.fetchUsers(
          token: token,
          range: range,
          locationId: locationId,
          schoolId: schoolId,
          gender: gender,
        );
        if (!mounted) return;
        setState(() => _leaderboardUsers = users);
      } else {
        final List<LeaderboardVideoEntry> videos =
        await LeaderboardService.fetchVideos(
          token: token,
          range: range,
          locationId: locationId,
          schoolId: schoolId,
          gender: gender,
        );
        if (!mounted) return;
        setState(() => _leaderboardVideos = videos);
      }
    } catch (e) {
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      AppHelpers.hideLoader();
    }
  }

  // ── Filter pickers ──────────────────────────────────────────────────

  Future<void> _pickLocation() async {
    final result = await showSearchablePicker(
      context: context,
      title: 'Location',
      fetcher: (search) async {
        final list = await LocationService.fetchLocations(search: search);
        return list
            .map((e) => PickerItem(id: e.id.toString(), label: e.name))
            .toList();
      },
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
      _fetchLeaderboard();
    }
  }

  Future<void> _pickSchool() async {
    final result = await showSearchablePicker(
      context: context,
      title: 'School',
      fetcher: (search) async {
        final list = await SchoolService.fetchSchools(search: search);
        return list
            .map((e) => PickerItem(id: e.id.toString(), label: e.name))
            .toList();
      },
    );
    if (result != null) {
      setState(() => _selectedSchool = result);
      _fetchLeaderboard();
    }
  }

  Future<void> _pickGender() async {
    final result = await showGenderPicker(context, selected: _selectedGender);
    if (result != null) {
      setState(() => _selectedGender = result);
      _fetchLeaderboard();
    }
  }

  /// Opens the public (read-only) profile screen for [userId].
  void _openUserProfile(int userId) {
    if (userId <= 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(targetId: userId),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildTabs(),
            _buildFilterDropdowns(),
            const SizedBox(height: 10),
            _buildTimeChips(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildLeaderboardBody(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FamaBottomNav(
        currentIndex: 1,
        onTap: (index) => handleFamaNavTap(context, 1, index),
        onPostTap: () => showPostNowPopup(context),
      ),
    );
  }

  Widget _buildTopBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 20),
              const SizedBox(width: 4),
              const Text(
                'FAMA',
                style: TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkColor,
                ),
              ),
              const Spacer(),
              // Invite button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _whatsappColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/whatsapp.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Invite',
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Star count pill — ab live fama points dikhata hai
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_famaPoints',
                      style: const TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _darkColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.settings_outlined, color: _darkColor, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: _borderColor, height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabItem('Celebrities', isSelected: _isCelebritiesTab)),
        Expanded(child: _tabItem('Videos', isSelected: !_isCelebritiesTab)),
      ],
    );
  }

  Widget _tabItem(String label, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        final bool wantsCelebrities = label == 'Celebrities';
        if (wantsCelebrities == _isCelebritiesTab) return; // already on this tab
        setState(() => _isCelebritiesTab = wantsCelebrities);
        _fetchLeaderboard();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _darkColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Rob',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? _darkColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _dropdownChip(
              _selectedLocation?.label ?? 'Location',
              onTap: _pickLocation,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdownChip(
              _selectedSchool?.label ?? 'School',
              onTap: _pickSchool,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _dropdownChip(
              _selectedGender ?? 'Gender',
              onTap: _pickGender,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownChip(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _darkColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _darkColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChips() {
    final List<String> filters = ['Day', 'Week', 'Month', 'All Time'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = _selectedTimeFilter == filter;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTimeFilter == filter) return;
                setState(() => _selectedTimeFilter = filter);
                _fetchLeaderboard();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _darkColor : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rob',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _darkColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }

  // ── Leaderboard grid (dynamic, dono tabs ke liye shared) ──────────────

  List<_LeaderboardDisplayItem> _currentItems() {
    if (_isCelebritiesTab) {
      final List<_LeaderboardDisplayItem> items = [];
      for (int i = 0; i < _leaderboardUsers.length; i++) {
        final LeaderboardUserEntry entry = _leaderboardUsers[i];
        items.add(_LeaderboardDisplayItem(
          rank: i + 1,
          name: (entry.name != null && entry.name!.trim().isNotEmpty)
              ? entry.name!
              : 'Unnamed',
          avatarUrl: entry.avatarUrl,
          points: entry.points,
          userId: entry.id,
        ));
      }
      return items;
    } else {
      final List<_LeaderboardDisplayItem> items = [];
      for (int i = 0; i < _leaderboardVideos.length; i++) {
        final LeaderboardVideoEntry entry = _leaderboardVideos[i];
        items.add(_LeaderboardDisplayItem(
          rank: i + 1,
          name: (entry.userName != null && entry.userName!.trim().isNotEmpty)
              ? entry.userName!
              : 'Unnamed',
          avatarUrl: entry.thumbnailUrl,
          points: entry.points,
          userId: entry.userId,
          isVideo: true,
        ));
      }
      return items;
    }
  }

  List<List<_LeaderboardDisplayItem>> _chunk(
      List<_LeaderboardDisplayItem> items, int size) {
    final List<List<_LeaderboardDisplayItem>> chunks = [];
    for (int i = 0; i < items.length; i += size) {
      final int end = (i + size > items.length) ? items.length : i + size;
      chunks.add(items.sublist(i, end));
    }
    return chunks;
  }

  Widget _buildLeaderboardBody() {
    final List<_LeaderboardDisplayItem> items = _currentItems();

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No entries yet.',
            style: TextStyle(
              fontFamily: 'Rob',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final List<List<_LeaderboardDisplayItem>> rows = _chunk(items, 4);

    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          _buildItemRow(rows[i]),
          if (i != rows.length - 1) ...[
            const SizedBox(height: 18),
            _sectionLabel(
              'Top ${((i + 1) * 4) > items.length ? items.length : (i + 1) * 4}',
            ),
            const SizedBox(height: 14),
          ],
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemRow(List<_LeaderboardDisplayItem> items) {
    final List<Widget> children =
    items.map((item) => Expanded(child: _itemCard(item))).toList();

    // Aakhri row incomplete ho to bhi 4-column alignment barqarar rahe.
    while (children.length < 4) {
      children.add(const Expanded(child: SizedBox.shrink()));
    }

    return Row(children: children);
  }

  Widget _itemCard(_LeaderboardDisplayItem item) {
    final bool hasImage = item.avatarUrl != null && item.avatarUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => _openUserProfile(item.userId),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFFE4E8ED),
                backgroundImage: hasImage ? NetworkImage(item.avatarUrl!) : null,
                child: !hasImage
                    ? Icon(
                  item.isVideo
                      ? Icons.play_circle_fill_rounded
                      : Icons.person_rounded,
                  color: Colors.grey,
                  size: 28,
                )
                    : null,
              ),
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: _rankBadgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${item.rank}',
                      style: const TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Rob',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _darkColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC839), size: 13),
              const SizedBox(width: 2),
              Text(
                '${item.points}',
                style: const TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}