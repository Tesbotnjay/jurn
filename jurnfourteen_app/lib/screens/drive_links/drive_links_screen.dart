import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/supabase_service.dart';
import '../../../models/drive_link.dart';
import '../../../models/member.dart';

class DriveLinksScreen extends StatefulWidget {
  const DriveLinksScreen({super.key});

  @override
  State<DriveLinksScreen> createState() => _DriveLinksScreenState();
}

class _DriveLinksScreenState extends State<DriveLinksScreen> {
  List<DriveLink> _links = [];
  Member? _currentMember;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final member = await SupabaseService.getCurrentMember();
    final links = await SupabaseService.getDriveLinks();
    if (mounted) {
      setState(() {
        _currentMember = member;
        _links = links;
        _isLoading = false;
      });
    }
  }

  void _showAddLinkDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F35),
          title: const Text('Tambah Link Drive'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul (misal: Foto Liputan 14 Okt)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Link Google Drive',
                    hintText: 'https://drive.google.com/...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi / Catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
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
                if (titleCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lengkapi judul dan link Drive!')),
                  );
                  return;
                }

                await SupabaseService.createDriveLink(
                  title: titleCtrl.text.trim(),
                  driveUrl: urlCtrl.text.trim(),
                  divisiOwner: _currentMember?.divisi ?? 'Dokumentasi',
                  description: descCtrl.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Divisi yang bisa akses link: Dokumentasi (punya), Media (bisa akses), Berita (bisa akses)
    final allowedDivisi = ['Dokumentasi', 'Media', 'Berita'];
    final canView = _currentMember?.role == 'admin' ||
        _currentMember?.role == 'super_admin' ||
        allowedDivisi.contains(_currentMember?.divisi);

    return Scaffold(
      appBar: AppBar(title: const Text('Link Google Drive')),
      body: !canView
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Akses link Drive hanya untuk divisi Dokumentasi, Media, dan Berita.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _links.isEmpty
                  ? const Center(child: Text('Belum ada link Drive.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _links.length,
                      itemBuilder: (context, index) {
                        final link = _links[index];
                        return Card(
                          color: const Color(0xFF1F1F35),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.2),
                              child: const Icon(Icons.add_to_drive, color: Colors.green),
                            ),
                            title: Text(
                              link.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (link.description != null && link.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(link.description!),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Dari: ${link.createdByName} (${link.divisiOwner})',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new, color: Colors.blueAccent),
                              onPressed: () => _openLink(link.driveUrl),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: (_currentMember?.isKoor == true || _currentMember?.role == 'admin')
          ? FloatingActionButton(
              onPressed: _showAddLinkDialog,
              child: const Icon(Icons.add_link),
            )
          : null,
    );
  }
}
