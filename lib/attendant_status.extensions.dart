import 'attendat_status.enum.dart';

extension AttendantStatusExtension on AttendantStatus {
  AttendantStatus getValue(String? value) =>
      AttendantStatus.values.firstWhere((e) => e.name == value?.toLowerCase(),
          orElse: () => AttendantStatus.unknown);
}
