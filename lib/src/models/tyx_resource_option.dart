import 'package:flutter/material.dart';
import 'package:timely_x/src/models/tyx_event.dart';
import 'package:timely_x/src/models/tyx_event_enhanced.dart';

import 'tyx_resource.dart';
import 'tyx_resource_enhanced.dart';

class TyxResourceOption {
  final double? timeslotHeight;
  final Duration? timelotSlotDuration;
  final DateTime? initialDate;
  final TimeOfDay? timeslotStartTime;

  /// Fin de la plage horaire affichée. Sans valeur, la grille court jusqu'à
  /// la fin de la journée — ce qui impose de faire défiler les heures creuses
  /// pour atteindre les rendez-vous.
  final TimeOfDay? timeslotEndTime;
  final double? cellWidth;
  final double? timesCellWidth;
  final double? resourceHeaderHeight;

  final List<TyxResource>? resources;
  final List<TyxEvent>? events;

  Widget Function(BuildContext context, TyxEventEnhanced item)? eventBuilder;
  Widget Function(BuildContext context, TyxResourceEnhanced item)?
      resourceBuilder;
  TyxResourceOption({
    this.timeslotHeight,
    this.timelotSlotDuration,
    this.initialDate,
    this.timeslotStartTime,
    this.timeslotEndTime,
    this.cellWidth,
    this.timesCellWidth,
    this.resourceHeaderHeight,
    this.resources,
    this.events,
    this.eventBuilder,
    this.resourceBuilder,
  });
}
