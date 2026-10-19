import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/core/utils/formatters.dart';
import 'package:skavia/core/utils/validators.dart';
import 'package:skavia/features/team_project/data/models/project_model.dart';
import 'package:skavia/features/team_project/data/models/task_item_model.dart';
import 'package:skavia/features/worker/data/models/worker_profile_model.dart';
import 'package:skavia/features/billing/presentation/controllers/payment_controller.dart';

void main() {
  group('SKAVIA Core Utilities & Formatters Unit Tests', () {
    test(
      'Formatters.formatCurrency formats BDT amounts with standard ৳ symbol',
      () {
        expect(Formatters.formatCurrency(0), '৳ 0');
        expect(Formatters.formatCurrency(1500), '৳ 1,500');
        expect(Formatters.formatCurrency(1500, showSymbol: false), '1,500');
      },
    );

    test(
      'Validators.bdPhone strictly validates Bangladeshi mobile formats',
      () {
        expect(Validators.bdPhone('01712345678'), isNull);
        expect(Validators.bdPhone('+8801812345678'), isNull);
        expect(Validators.bdPhone('01912345678'), isNull);
        expect(Validators.bdPhone('12345'), isNotNull);
        expect(Validators.bdPhone(''), isNotNull);
      },
    );

    test('Validators.email validates typical and invalid emails', () {
      expect(Validators.email('rahman@skavia.com'), isNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });
  });

  group('SKAVIA Project & Task Models Unit Tests', () {
    test('ProjectModel serializes and deserializes accurately with budget and dates', () {
      final json = {
        'project_id': 'proj_test_01',
        'title': 'Commercial Wiring Setup',
        'description': 'Full industrial facility electrical layout',
        'client_id': 'usr_client_01',
        'team_leader_id': 'usr_worker_01',
        'status': 'In Progress',
        'budget': 75000.0,
        'start_date': '2026-10-15T09:00:00.000Z',
      };

      final model = ProjectModel.fromJson(json);
      expect(model.projectId, 'proj_test_01');
      expect(model.title, 'Commercial Wiring Setup');
      expect(model.budget, 75000.0);
      expect(model.status, 'In Progress');

      final roundtrip = model.toJson();
      expect(roundtrip['project_id'], 'proj_test_01');
      expect(roundtrip['title'], 'Commercial Wiring Setup');
      expect(roundtrip['budget'], 75000.0);
    });

    test('TaskItemModel correctly supports status mutation via copyWith', () {
      const task = TaskItemModel(
        taskId: 'tsk_101',
        projectId: 'proj_test_01',
        title: 'Install main circuit breaker',
        description: 'Verify 3-phase power supply',
        status: 'To Do',
        priority: 'Urgent',
        budgetWeight: 12000.0,
      );

      final inProgress = task.copyWith(status: 'In Progress');
      expect(inProgress.status, 'In Progress');
      expect(inProgress.priority, 'Urgent');
      expect(inProgress.taskId, 'tsk_101');

      final done = inProgress.copyWith(status: 'Done');
      expect(done.status, 'Done');
    });
  });

  group('SKAVIA Worker Profile & Financial Models Tests', () {
    test('WorkerProfileModel correctly handles JSON with rating average and hourly rate', () {
      final json = {
        'worker_profile_id': 'wp_test_99',
        'user_id': 'usr_worker_99',
        'full_name': 'Abdur Rahman',
        'title': 'Master Electrician',
        'bio': '10+ years commercial & residential electrical expertise',
        'hourly_rate': 650.0,
        'rating': 4.95,
        'reviews_count': 48,
        'is_verified': true,
        'is_available': true,
        'skills': ['Wiring', 'Switchboard', '3-Phase'],
        'service_areas': ['Dhanmondi', 'Gulshan'],
      };

      final profile = WorkerProfileModel.fromJson(json);
      expect(profile.workerProfileId, 'wp_test_99');
      expect(profile.hourlyRate, 650.0);
      expect(profile.rating, 4.95);
      expect(profile.skills.length, 3);
      expect(profile.isVerified, isTrue);
    });

    test('PaymentController computes 15% platform commission and 85% worker payout', () {
      final controller = PaymentController();
      final feeSplit = controller.calculateFeeSplit(10000.0);

      expect(feeSplit['skaviaFee'], 1500.0);
      expect(feeSplit['workerAmount'], 8500.0);
    });
  });
}
