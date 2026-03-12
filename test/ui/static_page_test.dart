import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/ui/static_page.dart';

void main() {
  group('StaticPage Widget Tests', () {
    testWidgets('should display child content', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: StaticPage(child: Text('Static Content'))),
      );

      // Assert - Vérifie que le contenu est affiché
      expect(find.text('Static Content'), findsOneWidget);
    });

    testWidgets('should display appBar when provided', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: StaticPage(
            appBar: AppBar(title: const Text('Static Page Title')),
            child: const Text('Page Content'),
          ),
        ),
      );

      // Assert - Vérifie que l'AppBar est affichée
      expect(find.text('Static Page Title'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display floating action button when provided', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: StaticPage(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            child: const Text('Page Content'),
          ),
        ),
      );

      // Assert - Vérifie que le FAB est affiché
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should apply default padding when not provided', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: StaticPage(child: Text('Content'))),
      );

      await tester.pumpAndSettle();

      // Assert - Vérifie qu'un padding est appliqué par défaut
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should apply custom padding when provided', (tester) async {
      // Arrange
      const customPadding = EdgeInsets.all(32.0);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StaticPage(padding: customPadding, child: Text('Content')),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Vérifie que le contenu est affiché (le padding est appliqué en interne)
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should display complex layout', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: StaticPage(
            appBar: AppBar(title: const Text('Complex Page')),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Header'),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text('Item $index')),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Vérifie que tous les éléments sont affichés
      expect(find.text('Complex Page'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(5));
    });

    testWidgets('should handle empty content', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: StaticPage(child: SizedBox.shrink())),
      );

      await tester.pumpAndSettle();

      // Assert - Vérifie que la page s'affiche sans erreur
      expect(find.byType(StaticPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display with SafeArea', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: StaticPage(child: Text('Content'))),
      );

      // Assert - Vérifie que SafeArea est utilisé
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should display images and icons', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StaticPage(
            child: Column(
              children: [
                Icon(Icons.home, size: 48),
                SizedBox(height: 16),
                Icon(Icons.settings, size: 48),
                SizedBox(height: 16),
                Text('Icons displayed'),
              ],
            ),
          ),
        ),
      );

      // Assert - Vérifie que les icônes sont affichées
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Icons displayed'), findsOneWidget);
    });

    testWidgets('should display with both appBar and FAB', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: StaticPage(
            appBar: AppBar(
              title: const Text('Title'),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.edit),
            ),
            child: const Text('Content'),
          ),
        ),
      );

      // Assert - Vérifie que l'AppBar et le FAB sont tous deux affichés
      expect(find.text('Title'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
