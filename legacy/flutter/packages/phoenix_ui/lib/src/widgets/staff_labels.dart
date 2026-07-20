import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';

extension StaffRoleUi on StaffRole {
  String get labelPt => switch (this) {
        StaffRole.assistant => 'Adjunto',
        StaffRole.fitnessCoach => 'Preparador físico',
        StaffRole.goalkeeperCoach => 'Treinador GR',
        StaffRole.analyst => 'Analista',
        StaffRole.sportingDirector => 'Director desportivo',
        StaffRole.doctor => 'Médico',
        StaffRole.psychologist => 'Psicólogo',
        StaffRole.nutritionist => 'Nutricionista',
        StaffRole.scout => 'Olheiro',
      };

  String get departmentPt => switch (this) {
        StaffRole.assistant ||
        StaffRole.fitnessCoach ||
        StaffRole.goalkeeperCoach ||
        StaffRole.analyst =>
          'Equipa técnica',
        StaffRole.doctor ||
        StaffRole.psychologist ||
        StaffRole.nutritionist =>
          'Departamento médico',
        StaffRole.scout => 'Scouting',
        StaffRole.sportingDirector => 'Direção',
      };

  IconData get icon => switch (this) {
        StaffRole.assistant => Icons.support_agent,
        StaffRole.fitnessCoach => Icons.fitness_center,
        StaffRole.goalkeeperCoach => Icons.sports_handball,
        StaffRole.analyst => Icons.analytics,
        StaffRole.sportingDirector => Icons.business_center,
        StaffRole.doctor => Icons.medical_services,
        StaffRole.psychologist => Icons.psychology,
        StaffRole.nutritionist => Icons.restaurant,
        StaffRole.scout => Icons.search,
      };
}

const staffDepartmentOrder = [
  'Direção',
  'Equipa técnica',
  'Departamento médico',
  'Scouting',
];
