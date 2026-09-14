import 'package:flutter/material.dart';

import '../services and managers/report_status_api_service.dart';
import '../widgets/app_helper.dart';

class ReportStatusScreen extends StatefulWidget {
  const ReportStatusScreen({
    super.key,
    required this.reportId,
  });

  final int reportId;

  @override
  State<ReportStatusScreen> createState() => _ReportStatusScreenState();
}

class _ReportStatusScreenState extends State<ReportStatusScreen> {
  bool _loading = false;
  String? _error;
  ReportStatus? _report;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadStatus();
    });
  }

  Future<void> _loadStatus() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final report = await ReportStatusApiService.getReportStatus(
        reportId: widget.reportId,
      );

      if (!mounted) return;

      setState(() => _report = report);
    } catch (error) {
      if (!mounted) return;

      final message = error is ReportStatusApiException
          ? error.message
          : 'Could not load report status. Please try again.';

      setState(() => _error = message);

      AppHelpers.showError(message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ----- status helpers -----

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

  String _formatDate(String value) {
    if (value.isEmpty) return '—';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '$hour:$minute $period';
  }

  // ----- UI pieces -----

  Widget _field(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFB07800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Rob',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontFamily: 'Rob',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
                size: 38,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 14.5,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _loadStatus,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
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

  Widget _buildDetails(ReportStatus report) {
    final color = _statusColor(report.status);
    final icon = _statusIcon(report.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        if (_loading)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Updating report status...',
                  style: TextStyle(
                    fontFamily: 'Rob',
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0E0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: Colors.redAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Could not refresh. Showing previously loaded details.',
                    style: TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 12.5,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Header card with gradient + status
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F2126), Color(0xFF2E3138)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFFFC839),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REPORT',
                          style: TextStyle(
                            fontFamily: 'Rob',
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          '#${report.reportId}',
                          style: const TextStyle(
                            fontFamily: 'Rob',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 7),
                    Text(
                      report.statusLabel.isNotEmpty
                          ? report.statusLabel
                          : report.status.isNotEmpty
                          ? report.status
                          : 'Unknown status',
                      style: TextStyle(
                        fontFamily: 'Rob',
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Details card
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECECEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(Icons.category_outlined, 'Content type',
                  report.reportedType),
              _field(Icons.tag_rounded, 'Reported content ID',
                  '${report.reportedId}'),
              _field(Icons.report_gmailerrorred_rounded, 'Reason',
                  report.reason),
              _field(Icons.notes_rounded, 'Details', report.details),
              _field(Icons.upload_rounded, 'Submitted at',
                  _formatDate(report.submittedAt)),
              _field(Icons.update_rounded, 'Last updated',
                  _formatDate(report.updatedAt)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final report = _report;

    if (report != null) {
      return _buildDetails(report);
    }

    if (_error != null) {
      return _buildError();
    }

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
            'Loading report details...',
            style: TextStyle(
              fontFamily: 'Rob',
              color: Colors.black54,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFB),
        surfaceTintColor: const Color(0xFFFAFAFB),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Report Details',
          style: TextStyle(
            fontFamily: 'Rob',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh status',
            onPressed: _loading ? null : _loadStatus,
            icon: AnimatedRotation(
              turns: _loading ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}