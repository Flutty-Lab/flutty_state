import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/data/data_fetch_response.dart';
import 'package:flutty_state/ui/fetch_and_submit_page.dart';

// Modèle de données fake pour les tests
class FakeUserData {
  const FakeUserData({required this.name, required this.email});

  final String name;
  final String email;
}

void main() {
  group('FetchAndSubmitPage Widget Tests', () {
    testWidgets('should display success content after successful fetch', (
      tester,
    ) async {
      // Arrange
      Future<DataFetchingResponse<FakeUserData>> fetchData() async {
        return DataFetchSucceed(
          data: const FakeUserData(
            name: 'Jane Smith',
            email: 'jane@example.com',
          ),
        );
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FetchAndSubmitPage<FakeUserData>(
            dataFetcher: fetchData,
            builder: (data, submitter, context) => Column(
              children: [
                Text('Name: ${data.name}'),
                Text('Email: ${data.email}'),
              ],
            ),
          ),
        ),
      );

      // Attendre que le fetch soit terminé
      await tester.pumpAndSettle();

      // Assert - Vérifie que les données sont affichées
      expect(find.text('Name: Jane Smith'), findsOneWidget);
      expect(find.text('Email: jane@example.com'), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('should display error card when fetch fails', (tester) async {
      // Arrange
      const errorMessage = 'Failed to load user data';
      Future<DataFetchingResponse<FakeUserData>> fetchData() async {
        return DataFetchFailed(message: errorMessage);
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FetchAndSubmitPage<FakeUserData>(
            dataFetcher: fetchData,
            builder: (data, submitter, context) => Text('User: ${data.name}'),
          ),
        ),
      );

      // Attendre que le fetch soit terminé
      await tester.pumpAndSettle();

      // Assert - Vérifie que le message d'erreur est affiché
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('should display custom error widget when provided', (
      tester,
    ) async {
      // Arrange
      Future<DataFetchingResponse<FakeUserData>> fetchData() async {
        return DataFetchFailed(message: 'Error occurred');
      }

      const customErrorWidget = Text('Custom Error Display');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FetchAndSubmitPage<FakeUserData>(
            dataFetcher: fetchData,
            fetchFailedBuilder: (_, __, ___) => customErrorWidget,
            builder: (data, submitter, context) => Text('User: ${data.name}'),
          ),
        ),
      );

      // Attendre que le fetch soit terminé
      await tester.pumpAndSettle();

      // Assert - Vérifie que le widget d'erreur personnalisé est affiché
      expect(find.text('Custom Error Display'), findsOneWidget);
    });

    testWidgets('should refresh data on pull-to-refresh', (tester) async {
      // Arrange
      var fetchCount = 0;
      Future<DataFetchingResponse<FakeUserData>> fetchData() async {
        fetchCount++;
        return DataFetchSucceed(
          data: FakeUserData(
            name: 'User $fetchCount',
            email: 'user$fetchCount@example.com',
          ),
        );
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FetchAndSubmitPage<FakeUserData>(
            dataFetcher: fetchData,
            builder: (data, submitter, context) => Text('User: ${data.name}'),
          ),
        ),
      );

      // Attendre le premier fetch
      await tester.pumpAndSettle();
      expect(find.text('User: User 1'), findsOneWidget);

      // Simuler un pull-to-refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - Vérifie que les données ont été rafraîchies
      expect(find.text('User: User 2'), findsOneWidget);
      expect(fetchCount, 2);
    });

    testWidgets('should display appBar when appBarBuilder is provided', (
      tester,
    ) async {
      // Arrange
      Future<DataFetchingResponse<FakeUserData>> fetchData() async {
        return DataFetchSucceed(
          data: const FakeUserData(name: 'John Doe', email: 'john@example.com'),
        );
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FetchAndSubmitPage<FakeUserData>(
            dataFetcher: fetchData,
            appBarBuilder: (data, submitter, context) => AppBar(
              title: Text(data != null ? 'User: ${data.name}' : 'Loading...'),
            ),
            builder: (data, submitter, context) => Text('Email: ${data.email}'),
          ),
        ),
      );

      // Attendre que le fetch soit terminé
      await tester.pumpAndSettle();

      // Assert - Vérifie que l'AppBar est affichée avec le titre correct
      expect(find.text('User: John Doe'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
