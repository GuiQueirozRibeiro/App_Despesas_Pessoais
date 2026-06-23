import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';
import 'task_repository.dart';

/// Implementação do [TaskRepository] sobre o Cloud Firestore.
///
/// Toda a tradução entre a entidade de domínio [Task] e o documento do
/// Firestore (incluindo `DateTime` ↔ `Timestamp`) fica encapsulada aqui —
/// a entidade [Task] permanece livre de qualquer dependência do Firebase.
class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _db;

  FirestoreTaskRepository(this._db);

  /// Coleção raiz das tarefas. O nome bate com a regra de segurança
  /// (`match /tasks/{taskId}`).
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('tasks');

  @override
  Stream<List<Task>> watchTasks() {
    return _col.snapshots().map(
          (snapshot) => snapshot.docs.map(_taskFromDoc).toList(),
        );
  }

  @override
  Future<void> add(Task task) => _col.doc(task.id).set(_taskToMap(task));

  @override
  Future<void> update(Task task) => _col.doc(task.id).update(_taskToMap(task));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  // ── Mapeamento Task ↔ Firestore ─────────────────────────────────────────

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'name': task.name,
      // O SDK converte DateTime em Timestamp automaticamente na escrita.
      'dateTime': Timestamp.fromDate(task.dateTime),
      'latitude': task.latitude,
      'longitude': task.longitude,
      'locationLabel': task.locationLabel,
    };
  }

  Task _taskFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['dateTime'];
    return Task(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      // Tolera tanto Timestamp (Firestore real) quanto DateTime/Map.
      dateTime: ts is Timestamp ? ts.toDate() : DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationLabel: data['locationLabel'] as String?,
    );
  }
}
