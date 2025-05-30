import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/screens/auth/login_screen.dart';
import 'package:mockito/mockito.dart';
import '../mocks/firebase_mocks.mocks.dart';




void main() {
  group('LoginScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockUserCredential mockCredential;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockCredential = MockUserCredential();
      mockUser = MockUser();

      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockCredential);

      when(mockCredential.user).thenReturn(mockUser);
    });

    Future<void> buildLoginScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/auth': (context) => const Placeholder(), 
      },
      home: LoginScreen(auth: mockAuth),
    ),
  );
}


    testWidgets('muestra errores si los campos están vacíos', (tester) async {
      await buildLoginScreen(tester);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Campo obligatorio'), findsNWidgets(2));
    });

    testWidgets('muestra error si el correo es inválido', (tester) async {
      await buildLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).first, 'correo@invalido');
      await tester.enterText(find.byType(TextFormField).last, '123456');

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Correo inválido'), findsOneWidget);
    });

    testWidgets('muestra error si la contraseña es muy corta', (tester) async {
      await buildLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).first, 'usuario@mail.com');
      await tester.enterText(find.byType(TextFormField).last, '123');

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

  testWidgets('no muestra errores con datos válidos', (tester) async {
  final mockUser = MockUser();

  when(mockCredential.user).thenReturn(mockUser);
  when(mockAuth.signInWithEmailAndPassword(
    email: anyNamed('email'),
    password: anyNamed('password'),
  )).thenAnswer((_) async => mockCredential);

  await buildLoginScreen(tester);

  await tester.enterText(find.byType(TextFormField).first, 'usuario@mail.com');
  await tester.enterText(find.byType(TextFormField).last, '123456');

  await tester.tap(find.text('Iniciar sesión'));
  await tester.pump();

  expect(find.text('Campo obligatorio'), findsNothing);
  expect(find.text('Correo inválido'), findsNothing);
  expect(find.text('Mínimo 6 caracteres'), findsNothing);
});
  });
}
