import 'package:flutter/material.dart';

import '../services and managers/report_vedio_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/report_video_preview.dart';
import 'report_status_screen.dart';

class ReportedVideosScreen extends StatefulWidget {
  const ReportedVideosScreen({super.key});

  @override
  State<ReportedVideosScreen> createState() => _ReportedVideosScreenState();
}

class _ReportedVideosScreenState extends State<ReportedVideosScreen> {
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _openingStatus = false;

  String _errorMessage = '';
  List<ReportedVideo> _reports = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
      _errorMessage = '';
    });

    final token = SessionManager.accessToken;

    if (token == null || token.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = 'Session expired. Please log in again.';
      });
      return;
    }

    try {
      final reports = await ReportedVideosApiService.getReportedVideos(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = error is ReportedVideosApiException
            ? error.message
            : 'Could not load your reports. Please try again.';
      });
    }
  }

  Future<void> _openReportStatus(ReportedVideo report) async {
    if (_openingStatus) return;

    _openingStatus = true;

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ReportStatusScreen(
            reportId: report.reportId,
          ),
        ),
      );
    } finally {
      _openingStatus = false;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'approved':
      case 'action_taken':
        return const Color(0xFF2E7D32);
      case 'rejected':
      case 'dismissed':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFB07800);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'approved':
      case 'action_taken':
        return Icons.check_circle_rounded;
      case 'rejected':
      case 'dismissed':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');

    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFB),
        surfaceTintColor: const Color(0xFFFAFAFB),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Your Reports',
          style: TextStyle(
            fontFamily: 'Rob',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFFB07800),
              ),
            ),
            SizedBox(height: 14),
            Text(
              'Loading reports...',
              style: TextStyle(
                fontFamily: 'Rob',
                fontSize: 13.5,
                color: Color(0xFF60656B),
              ),
            ),
          ],
        ),
      );
    }

    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF60656B),
                  fontFamily: 'Rob',
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tap to retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC839),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Rob',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFFB07800),
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "You haven't reported anything yet.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF60656B),
                  fontFamily: 'Rob',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFB07800),
      onRefresh: _loadData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final report = _reports[index];

          return _ReportCard(
            key: ValueKey(report.reportId),
            report: report,
            statusColor: _statusColor(report.status),
            statusIcon: _statusIcon(report.status),
            formattedDate: _formatDate(report.reportedAt),
            onTap: () => _openReportStatus(report),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    super.key,
    required this.report,
    required this.statusColor,
    required this.statusIcon,
    required this.formattedDate,
    required this.onTap,
  });

  final ReportedVideo report;
  final Color statusColor;
  final IconData statusIcon;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECECEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview par tap bhi report details kholega.
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: IgnorePointer(
                    child: ReportedVideoPreview(
                      key: ValueKey(report.reportId),
                      videoUrl: report.videoUrl,
                      isContentAvailable: report.isContentAvailable,
                      width: 96,
                      height: 128,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reason.isEmpty ? 'Report' : report.reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Rob',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 13, color: statusColor),
                            const SizedBox(width: 5),
                            Text(
                              report.statusLabel.isEmpty
                                  ? report.status
                                  : report.statusLabel,
                              style: TextStyle(
                                fontFamily: 'Rob',
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (report.reportDetails != null &&
                          report.reportDetails!.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          report.reportDetails!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6B7076),
                            fontFamily: 'Rob',
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Color(0xFF9AA0A6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.creatorName.isEmpty
                                  ? 'Unknown user'
                                  : report.creatorName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Rob',
                                color: Color(0xFF9AA0A6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: Color(0xFF9AA0A6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Color(0xFF9AA0A6),
                              fontFamily: 'Rob',
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'View report details',
                                style: TextStyle(
                                  fontFamily: 'Rob',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB07800),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFFB07800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}