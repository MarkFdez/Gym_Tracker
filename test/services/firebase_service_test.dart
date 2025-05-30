import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/models/workout_session_model.dart';
import 'package:gym_tracker/service/firebase_service.dart';
import 'package:mockito/mockito.dart';
import '../mocks/firebase_mocks.mocks.dart'; // Importa los mocks generados

void main() {
  group('FirebaseService', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late FirebaseService service;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      service = FirebaseService(auth: mockAuth, firestore: mockFirestore);
    });

    test('currentUser devuelve el usuario actual', () {
      final user = MockUser();
      when(mockAuth.currentUser).thenReturn(user);

      final result = service.currentUser;
      expect(result, isA<MockUser>());
    });

    test('getUserProfile obtiene perfil del usuario desde Firestore', () async {
      final perfiles = MockCollectionReference<Map<String, dynamic>>();
      final docRef = MockDocumentReference<Map<String, dynamic>>();
      final docSnap = MockDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('perfiles')).thenReturn(perfiles);
      when(perfiles.doc('uid123')).thenReturn(docRef);
      when(docRef.get()).thenAnswer((_) async => docSnap);

      final result = await service.getUserProfile('uid123');
      expect(result, docSnap);
    });

    test('getUserRoutines obtiene rutinas del usuario desde Firestore', () async {
      final rutinas = MockCollectionReference<Map<String, dynamic>>();
      final query = MockQuery<Map<String, dynamic>>();
      final querySnap = MockQuerySnapshot<Map<String, dynamic>>();

      when(mockFirestore.collection('rutinas')).thenReturn(rutinas);
      when(rutinas.where('uid', isEqualTo: 'uid123')).thenReturn(query);
      when(query.get()).thenAnswer((_) async => querySnap);

      final result = await service.getUserRoutines('uid123');
      expect(result, querySnap);
    });

    test('saveWorkoutSession guarda correctamente una sesión', () async {
  final sesiones = MockCollectionReference<Map<String, dynamic>>();
  final dummySession = WorkoutSession(
    id: 'test_id',
    uid: 'uid123',
    rutinaId: 'rutina456',
    fecha: DateTime(2024, 5, 29),
    ejercicios: [
      ExerciseRecord(
        nombre: 'Sentadillas',
        grupoMuscular: 'Piernas',
        series: 4,
        repeticiones: 10,
        peso: 80.0,
        nota: 'Buena técnica',
      ),
    ],
  );

  when(mockFirestore.collection('sesiones')).thenReturn(sesiones);
  when(sesiones.add(any)).thenAnswer((_) async => MockDocumentReference());

  final result = await service.saveWorkoutSession(dummySession);

  expect(result, isTrue);
  verify(sesiones.add(dummySession.toMap())).called(1);
});


  });
}
