import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timely_x/timely_x.dart';

/// Une cellule de mois est basse. Sans traitement, les événements en trop
/// étaient simplement rognés : une journée à six rendez-vous en montrait trois,
/// sans le moindre indice qu'il en manquait.
void main() {
  final day = DateTime(2026, 8, 19, 0, 0);

  List<TyxEvent> eventsFor(int count) => List.generate(
        count,
        (i) => TyxEvent(
          id: '$i',
          title: 'Patient $i',
          start: DateTime(2026, 8, 19, 9 + i),
          end: DateTime(2026, 8, 19, 9 + i, 30),
          color: Colors.blue,
        ),
      );

  Widget harness(List<TyxEvent> events, {Size size = const Size(1200, 800)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: TyxCalendarView(
            option: TyxCalendarOption(
              initialView: TyxView.month,
              initialDate: day,
              events: events,
              startWeekDay: 1,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('affiche un compteur quand tous les événements ne tiennent pas',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(6)));
    await tester.pumpAndSettle();

    // Le compteur nomme précisément ce qui est masqué.
    final more = find.textContaining(RegExp(r'^\+\d+$'));
    expect(more, findsOneWidget);

    final label = tester.widget<Text>(more).data!;
    final hidden = int.parse(label.substring(1));
    expect(hidden, greaterThan(0));
    expect(hidden, lessThan(6));

    // Les événements visibles plus les masqués rendent bien compte des six.
    final visible = find.textContaining('Patient').evaluate().length;
    expect(visible + hidden, 6);
  });

  testWidgets('aucun compteur quand tout tient', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(1)));
    await tester.pumpAndSettle();

    expect(find.textContaining(RegExp(r'^\+\d+$')), findsNothing);
    expect(find.textContaining('Patient 0'), findsOneWidget);
  });

  testWidgets('le compteur ouvre la liste complète de la journée',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(6)));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(RegExp(r'^\+\d+$')));
    await tester.pumpAndSettle();

    // Les six rendez-vous sont désormais atteignables.
    for (var i = 0; i < 6; i++) {
      expect(find.text('Patient $i'), findsWidgets);
    }
  });

  testWidgets('toucher un événement de la liste le remonte à l\'hôte',
      (tester) async {
    TyxEvent? tapped;

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TyxCalendarView(
            option: TyxCalendarOption(
              initialView: TyxView.month,
              initialDate: day,
              events: eventsFor(6),
              startWeekDay: 1,
            ),
            onEventTapped: (e) => tapped = e,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(RegExp(r'^\+\d+$')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patient 5').last);
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped!.title, 'Patient 5');
    // La liste se referme après le choix.
    expect(find.byType(AlertDialog), findsNothing);
  });
}
