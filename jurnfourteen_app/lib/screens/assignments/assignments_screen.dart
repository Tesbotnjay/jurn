import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../models/assignment.dart';
import '../../../models/member.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  List<Assignment> _assignments = [];
  Member? _currentMember;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final member = await SupabaseService.getCurrentMember();
    List<Assignment> list = [];
    if (member != null) {
      if (member.isKoor || member.role == 'admin') {
        list = await SupabaseService.getDivisiAssignments(member.divisi ?? 'Dokumentasi');
      } else {
        list = await SupabaseService.getMyAssignments();
      }
    }
    if (mounted) {
      setState(() {
        _currentMember = member;
        _assignments = list;
        _isLoading = false;
      });
    }
  }

  void _showCreateAssignmentDialog() async {
    if (_currentMember?.divisi == null) return;

    final members = await SupabaseService.getMembersByDivisi(_currentMember!.divisi!);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedMemberIds = <String>{};

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F35),
              title: Text('Tugaskan Anggota (${_currentMember?.divisi})'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Tugas (misal: Dokumentasi Senin)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi / Instruksi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Pilih Anggota:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    ...members.map((m) {
                      final isSelected = selectedMemberIds.contains(m.id);
                      return CheckboxListTile(
                        title: Text(m.fullName),
                        value: isSelected,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedMemberIds.add(m.id);
                            } else {
                              selectedMemberIds.remove(m.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        descController.text.isEmpty ||
                        selectedMemberIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lengkapi judul, instruksi, dan centang anggota!')),
                      );
                      return;
                    }

                    await SupabaseService.createAssignment(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      divisi: _currentMember!.divisi!,
                      memberIds: selectedMemberIds.toList(),
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  },
                  child: const Text('KIRIM PENUGASAN'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penugasan Divisi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assignments.isEmpty
              ? const Center(child: Text('Belum ada penugasan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final item = _assignments[index];
                    return Card(
                      color: const Color(0xFF1F1F35),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Ditugaskan kepada: ${item.assignedToName}'),
                            const SizedBox(height: 4),
                            Text('Instruksi: ${item.description}', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: item.status == 'completed'
                              ? Colors.green
                              : (item.status == 'in_progress' ? Colors.orange : Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: (_currentMember?.isKoor == true || _currentMember?.role == 'admin')
          ? FloatingActionButton.extended(
              onPressed: _showCreateAssignmentDialog,
              icon: const Icon(Icons.add_task),
              label: const Text('Tugaskan Anggota'),
            )
          : null,
    );
  }
}
