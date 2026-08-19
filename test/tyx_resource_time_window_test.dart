import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timely_x/timely_x.dart';

/// Un agenda par praticien démarrait à 00:00 et courait jusqu'à 23:45 : il
/// fallait faire défiler les heures creuses pour atteindre la journée de
/// travail. La plage affichée est désormais bornée.
void main() {
  final day = DateTime(2026, 8, 19);

  Widget harness({TimeOfDay? start, TimeOfDay? end}) => MaterialApp(
        // floww affiche les heures en 24 h ; le défaut des tests est 12 h.
        home: MediaQuery(
          data: const MediaQueryData(alwaysUse24HourFormat: true),
          child: Scaffold(
          body: TyxResourceView(
            option: TyxResourceOption(
              initialDate: day,
              timeslotStartTime: start,
              timeslotEndTime: end,
              timelotSlotDuration: const Duration(minutes: 30),
              resources: [TyxResource(id: '1', name: 'Dr Martin')],
              events: const [],
            ),
          ),
        ),
        ),
      );

  testWidgets('sans bornes, la grille couvre la journée entière',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 3000));
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('23:30'), findsOneWidget);
  });

  testWidgets('bornée de 8h à 18h, rien avant ni après', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 3000));
    await tester.pumpWidget(harness(
      start: const TimeOfDay(hour: 8, minute: 0),
      end: const TimeOfDay(hour: 18, minute: 0),
    ));
    await tester.pumpAndSettle();

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('18:00'), findsOneWidget);

    // Les heures hors plage ne sont plus construites du tout.
    expect(find.text('00:00'), findsNothing);
    expect(find.text('07:30'), findsNothing);
    expect(find.text('18:30'), findsNothing);
    expect(find.text('23:30'), findsNothing);
  });

  testWidgets('une fin antérieure au début retombe sur la journée',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 3000));
    await tester.pumpWidget(harness(
      start: const TimeOfDay(hour: 18, minute: 0),
      end: const TimeOfDay(hour: 8, minute: 0),
    ));
    await tester.pumpAndSettle();

    expect(find.text('18:00'), findsOneWidget);
    expect(find.text('23:30'), findsOneWidget);
  });
}
