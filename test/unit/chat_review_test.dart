import 'package:flutter_test/flutter_test.dart';
import 'package:skavia/features/chat/data/models/chat_message_model.dart';
import 'package:skavia/features/reviews/data/models/review_model.dart';

void main() {
  group('SKAVIA SRS Section 3.1.N — Real-Time Chat Models Unit Tests', () {
    test(
      'ChatMessageModel serialization and deserialization preserves all fields',
      () {
        final now = DateTime.now();
        final message = ChatMessageModel(
          messageId: 'msg_101',
          conversationId: 'conv_202',
          senderId: 'usr_client_01',
          messageText: 'Hello, what time can you arrive at Gulshan 2?',
          attachmentUrl: 'https://storage.skavia.com/site_photo.jpg',
          isRead: false,
          createdAt: now,
        );

        final json = message.toJson();
        expect(json['message_id'], 'msg_101');
        expect(json['conversation_id'], 'conv_202');
        expect(json['sender_id'], 'usr_client_01');
        expect(
          json['message_text'],
          'Hello, what time can you arrive at Gulshan 2?',
        );
        expect(
          json['attachment_url'],
          'https://storage.skavia.com/site_photo.jpg',
        );
        expect(json['is_read'], false);

        final deserialized = ChatMessageModel.fromJson(json);
        expect(deserialized.messageId, message.messageId);
        expect(deserialized.senderId, message.senderId);
        expect(deserialized.messageText, message.messageText);
        expect(deserialized.attachmentUrl, message.attachmentUrl);
      },
    );

    test('ConversationModel parses participants and last message details correctly', () {
      final json = {
        'conversation_id': 'conv_001',
        'service_request_id': 'req_888',
        'project_id': null,
        'participant_one': 'usr_client_01',
        'participant_two': 'usr_worker_01',
        'last_message_at': '2026-10-09T00:30:00.000Z',
        'created_at': '2026-10-09T00:00:00.000Z',
        'other_name': 'Engr. Karim Ullah',
        'other_avatar': null,
        'last_message_text': 'I am on my way to the site.',
        'unread_count': 2,
      };

      final conv = ConversationModel.fromJson(
        json,
        currentUserId: 'usr_client_01',
      );
      expect(conv.conversationId, 'conv_001');
      expect(conv.serviceRequestId, 'req_888');
      expect(conv.participantOne, 'usr_client_01');
      expect(conv.participantTwo, 'usr_worker_01');
      expect(conv.otherParticipantName, 'Engr. Karim Ullah');
      expect(conv.lastMessageText, 'I am on my way to the site.');
      expect(conv.unreadCount, 2);
    });
  });

  group(
    'SKAVIA SRS Section 3.1.M & 3.1.Q — Review & Reputation Unit Tests',
    () {
      test(
        'ReviewModel handles rating constraints and comment text correctly',
        () {
          final now = DateTime.now();
          final review = ReviewModel(
            reviewId: 'rev_501',
            workerProfileId: 'wp_001',
            serviceRequestId: 'req_001',
            clientId: 'client_001',
            rating: 5,
            comment: 'High quality electrical work. Arrived on time and fully equipped.',
            createdAt: now,
            clientName: 'Tanvir Hossain',
          );

          final json = review.toJson();
          expect(json['review_id'], 'rev_501');
          expect(json['worker_profile_id'], 'wp_001');
          expect(json['rating'], 5);
          expect(json['comment'], contains('High quality electrical work'));

          final parsed = ReviewModel.fromJson(json);
          expect(parsed.rating, 5);
          expect(parsed.comment, review.comment);
        },
      );

      test(
        'ReputationModel correctly records overall score and badge level tier',
        () {
          final json = {
            'reputation_id': 'rep_901',
            'worker_profile_id': 'wp_001',
            'overall_score': 4.95,
            'completed_jobs': 28,
            'total_ratings': 25,
            'badge_level': 'Top Rated Elite',
            'updated_at': '2026-10-09T00:00:00.000Z',
          };

          final rep = ReputationModel.fromJson(json);
          expect(rep.reputationId, 'rep_901');
          expect(rep.overallScore, 4.95);
          expect(rep.completedJobs, 28);
          expect(rep.totalRatings, 25);
          expect(rep.badgeLevel, 'Top Rated Elite');
        },
      );
    },
  );
}
