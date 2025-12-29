import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hire_me/models/interview_model.dart';
import 'package:hire_me/providers/interview_provider.dart';
import 'package:hire_me/providers/user_provider.dart';
import 'package:hire_me/providers/message_provider.dart';
import 'package:hire_me/services/firebase_interview_service.dart';
import 'package:intl/intl.dart';

/// Screen for recruiters to propose an interview to a candidate
class ProposeInterviewScreen extends ConsumerStatefulWidget {
  const ProposeInterviewScreen({required this.matchId, super.key});

  final String matchId;

  @override
  ConsumerState<ProposeInterviewScreen> createState() =>
      _ProposeInterviewScreenState();
}

class _ProposeInterviewScreenState
    extends ConsumerState<ProposeInterviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Get match details to find candidate ID
      final matches = ref.read(userMatchesProvider).value ?? [];
      final match = matches.firstWhere(
        (m) => m.id == widget.matchId,
        orElse: () => throw Exception('Match non trouvé'),
      );

      final candidateId =
          match.candidateUid == currentUser.uid ? match.recruiterUid : match.candidateUid;

      // Combine date and time
      final proposedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseInterviewService.proposeInterview(
        matchId: widget.matchId,
        recruiterId: currentUser.uid,
        candidateId: candidateId,
        proposedDateTime: proposedDateTime,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entretien proposé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposer un entretien'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Proposez une date et heure pour l\'entretien',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Date selection
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Sélectionner une date'
                      : DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                          .format(_selectedDate!),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              const SizedBox(height: 16),

              // Time selection
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  _selectedTime == null
                      ? 'Sélectionner une heure'
                      : _selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              const SizedBox(height: 24),

              // Location field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  hintText: 'Adresse ou lien de visioconférence',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez indiquer un lieu';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Détails supplémentaires sur l\'entretien',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Proposer l\'entretien',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
