import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/models/interview_model.dart';
import 'package:hire_me/providers/interview_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendar screen for viewing and managing interviews
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<InterviewModel> _getInterviewsForDay(
    DateTime day,
    List<InterviewModel> interviews,
  ) {
    return interviews.where((interview) {
      return isSameDay(interview.proposedDateTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Utilisateur non connecté')),
          );
        }

        final interviewsAsync = ref.watch(userInterviewsProvider(currentUser.uid));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mes entretiens'),
          ),
          body: interviewsAsync.when(
            data: (interviews) {
              final selectedDayInterviews =
                  _getInterviewsForDay(_selectedDay ?? _focusedDay, interviews);

              return Column(
                children: [
                  // Calendar widget
                  TableCalendar<InterviewModel>(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => _getInterviewsForDay(day, interviews),
                    calendarStyle: CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  const Divider(),

                  // Interviews list for selected day
                  Expanded(
                    child: selectedDayInterviews.isEmpty
                        ? Center(
                            child: Text(
                              'Aucun entretien prévu pour cette date',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: selectedDayInterviews.length,
                            itemBuilder: (context, index) {
                              final interview = selectedDayInterviews[index];
                              return _InterviewCard(
                                interview: interview,
                                currentUserId: currentUser.uid,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Erreur: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }
}

/// Card widget to display interview information
class _InterviewCard extends StatelessWidget {
  const _InterviewCard({
    required this.interview,
    required this.currentUserId,
  });

  final InterviewModel interview;
  final String currentUserId;

  Color _getStatusColor(InterviewStatus status) {
    switch (status) {
      case InterviewStatus.pending:
        return Colors.orange;
      case InterviewStatus.confirmed:
        return Colors.green;
      case InterviewStatus.declined:
        return Colors.red;
      case InterviewStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(InterviewStatus status) {
    switch (status) {
      case InterviewStatus.pending:
        return 'En attente';
      case InterviewStatus.confirmed:
        return 'Confirmé';
      case InterviewStatus.declined:
        return 'Décliné';
      case InterviewStatus.cancelled:
        return 'Annulé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecruiter = interview.recruiterId == currentUserId;
    final time = DateFormat('HH:mm').format(interview.proposedDateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Show interview details dialog
          showDialog<void>(
            context: context,
            builder: (context) => _InterviewDetailDialog(
              interview: interview,
              isRecruiter: isRecruiter,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(interview.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(interview.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(interview.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      interview.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (interview.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  interview.notes,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog showing detailed interview information
class _InterviewDetailDialog extends StatelessWidget {
  const _InterviewDetailDialog({
    required this.interview,
    required this.isRecruiter,
  });

  final InterviewModel interview;
  final bool isRecruiter;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR')
        .format(interview.proposedDateTime);

    return AlertDialog(
      title: const Text('Détails de l\'entretien'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Date et heure',
              value: dateTime,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Lieu',
              value: interview.location,
            ),
            if (interview.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.notes,
                label: 'Notes',
                value: interview.notes,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

/// Helper widget for displaying detail rows
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
