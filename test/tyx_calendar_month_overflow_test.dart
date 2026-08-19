import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timely_x/timely_x.dart';

/// Une cellule de mois est basse. Sans traitement, les événements en trop
/// étaient simplement rognés : une journée à six rendez-vous en montrait trois,
/// sans le moindre indice qu'il en manquait.
void main() {
  final day = DateTime(2026, 8, 19, 0, 0);
  // Le libellé de la pastille peut coïncider avec le numéro d'un autre
  // jour du mois : on la vise par sa clé.
  final badge = find.byKey(const ValueKey('tyx-day-count-2026-8-19'));

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

  testWidgets('les premiers rendez-vous restent visibles dans la cellule',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(6)));
    await tester.pumpAndSettle();

    // La régression corrigée : la cellule ne doit jamais se réduire au seul
    // compteur, sans aucun rendez-vous listé.
    expect(find.textContaining('Patient 0'), findsWidgets);
  });

  testWidgets('une pastille annonce le nombre de rendez-vous du jour',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(6)));
    await tester.pumpAndSettle();

    expect(badge, findsOneWidget);
    expect(
      find.descendant(of: badge, matching: find.text('6')),
      findsOneWidget,
    );
  });

  testWidgets('aucune pastille pour une journée à un seul rendez-vous',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(1)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Patient 0'), findsWidgets);
    expect(badge, findsNothing);
  });

  testWidgets('la pastille ouvre la liste complète de la journée',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(harness(eventsFor(6)));
    await tester.pumpAndSettle();

    await tester.tap(badge);
    await tester.pumpAndSettle();

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

    await tester.tap(badge);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patient 5').last);
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped!.title, 'Patient 5');
    // La liste se referme après le choix.
    expect(find.byType(AlertDialog), findsNothing);
  });
}
