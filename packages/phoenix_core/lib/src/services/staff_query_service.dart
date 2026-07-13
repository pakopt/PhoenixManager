import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/domain/staff.dart';

/// Query staff by club — SSOT via [clubId].
class StaffQueryService {
  const StaffQueryService(this._staff);

  final Map<StaffId, StaffMember> _staff;

  List<StaffMember> getByClubId(ClubId clubId) {
    return _staff.values.where((s) => s.clubId == clubId).toList()
      ..sort((a, b) => a.role.index.compareTo(b.role.index));
  }

  StaffMember? getByClubAndRole(ClubId clubId, StaffRole role) {
    for (final member in _staff.values) {
      if (member.clubId == clubId && member.role == role) {
        return member;
      }
    }
    return null;
  }

  int levelFor(ClubId clubId, StaffRole role) =>
      getByClubAndRole(clubId, role)?.level ?? 0;
}
