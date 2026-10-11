import 'package:flutter_test/flutter_test.dart';
import 'package:jurnfourteen_app/models/task_drive_link.dart';

void main() {
  test('valid Google Drive URL creates a task-linked drive link', () {
    final link = TaskDriveLink.fromTask(
      taskTitle: 'Liputan Rapat',
      url: 'https://drive.google.com/folder/test',
      description: 'Upload foto rapat',
      divisi: 'Dokumentasi',
    );

    expect(link, isNotNull);
    expect(link!.title, 'Lampiran tugas: Liputan Rapat');
    expect(link.driveUrl, 'https://drive.google.com/folder/test');
    expect(link.divisiOwner, 'Dokumentasi');
  });

  test('empty URL does not create a drive link', () {
    expect(
      TaskDriveLink.fromTask(
        taskTitle: 'Liputan Rapat',
        url: '   ',
        description: 'Upload foto rapat',
        divisi: 'Dokumentasi',
      ),
      isNull,
    );
  });

  test('non Google Drive URL is rejected before a task is sent', () {
    expect(
      () => TaskDriveLink.fromTask(
        taskTitle: 'Liputan Rapat',
        url: 'https://example.com/file',
        description: 'Upload foto rapat',
        divisi: 'Dokumentasi',
      ),
      throwsFormatException,
    );
  });
}
