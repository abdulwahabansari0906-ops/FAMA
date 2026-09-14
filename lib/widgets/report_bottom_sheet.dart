import 'package:flutter/material.dart';

import '../services and managers/report_api_service.dart';

Future<String?> showReportBottomSheet(
    BuildContext context, {
      required String reportedType,
      required int reportedId,
      required String targetName,
    }) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),
    builder: (_) => ReportBottomSheet(
      reportedType: reportedType,
      reportedId: reportedId,
      targetName: targetName,
    ),
  );
}

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.reportedType,
    required this.reportedId,
    required this.targetName,
  });

  final String reportedType;
  final int reportedId;
  final String targetName;

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _detailsController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // The service fetches the token from SessionManager.
      final message = await ReportApiService.reportPost(
        postId: widget.reportedId,
        reason: _reasonController.text.trim(),
        details: _detailsController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop(message);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _error = error is ReportApiException
            ? error.message
            : 'Could not submit report. Please try again.';
      });
    }
  }
  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Rob',
        color: Colors.black38,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F7F9),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFFC839),
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.6,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Rob',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Report ${widget.reportedType}',
                          style: const TextStyle(
                            fontFamily: 'Rob',
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.targetName,
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _label('Reason'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    enabled: !_submitting,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      color: Colors.black87,
                    ),
                    decoration: _decoration('e.g. Spam or fake account'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a reason.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _label('Details'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detailsController,
                    enabled: !_submitting,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontFamily: 'Rob',
                      color: Colors.black87,
                    ),
                    decoration: _decoration('Tell us what happened'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please add details.';
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Semantics(
                      liveRegion: true,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontFamily: 'Rob',
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFFFC839),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
                        'Submit report',
                        style: TextStyle(
                          fontFamily: 'Rob',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}