import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/constants/firestore_paths.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';
import 'package:tsiwa_mahber/core/utils/ethiopian_calendar.dart';
import 'package:tsiwa_mahber/features/members/domain/member.dart';
import 'package:tsiwa_mahber/features/leadership/domain/leader.dart';
import 'package:tsiwa_mahber/features/tsiwa/domain/tsiwa_event.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir.dart';
import 'package:tsiwa_mahber/features/edir/domain/edir_member.dart';
import 'package:tsiwa_mahber/features/edir/domain/payment.dart';
import 'package:tsiwa_mahber/features/auth/domain/app_user.dart';
import 'package:tsiwa_mahber/features/announcements/domain/announcement.dart';
import 'package:tsiwa_mahber/features/announcements/domain/read_receipt.dart';
import 'package:tsiwa_mahber/features/notifications/domain/app_notification.dart';
import 'package:tsiwa_mahber/features/notifications/data/telegram_service.dart';

void main() {
  group('AppConstants', () {
    test('default area values are correct', () {
      expect(AppConstants.defaultAreaId, 'gelan');
      expect(AppConstants.defaultAreaName, 'የገላን ፅዋ ማህበሮች');
      expect(AppConstants.defaultAreaShortName, 'ገላን');
    });

    test('Ethiopian month names has 13 entries', () {
      expect(AppConstants.ethiopianMonths.length, 13);
    });

    test('ethiopianMonthName returns correct name', () {
      expect(AppConstants.ethiopianMonthName(1), 'መስከረም');
      expect(AppConstants.ethiopianMonthName(5), 'ጥር');
      expect(AppConstants.ethiopianMonthName(13), 'ጳጉሜ');
    });

    test('tsiwaMonthCount is 12 (excludes Pagume for tsiwa)', () {
      expect(AppConstants.tsiwaMonthCount, 12);
    });

    test('ethiopianMonthName returns empty for invalid month', () {
      expect(AppConstants.ethiopianMonthName(0), '');
      expect(AppConstants.ethiopianMonthName(14), '');
    });
  });

  group('AppTheme', () {
    test('darkTheme is dark brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('darkTheme uses Material 3', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, true);
    });

    test('darkTheme has correct primary color', () {
      final theme = AppTheme.darkTheme;
      expect(theme.colorScheme.primary, AppTheme.primary);
    });
  });

  group('Widget tests', () {
    testWidgets('MaterialApp can be created with theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: Text('Tsiwa Test'),
            ),
          ),
        ),
      );

      expect(find.text('Tsiwa Test'), findsOneWidget);
    });
  });

  group('Member', () {
    test('MemberRole displayName returns Amharic', () {
      expect(MemberRole.muse.displayName, 'ሙሴ');
      expect(MemberRole.assistantMuse.displayName, 'ረዳት ሙሴ');
      expect(MemberRole.member.displayName, 'ማህበርተኛ');
      expect(MemberRole.observer.displayName, 'ታዛቢ');
    });

    test('MemberRole fromString parses correctly', () {
      expect(MemberRole.fromString('muse'), MemberRole.muse);
      expect(MemberRole.fromString('assistant_muse'), MemberRole.assistantMuse);
      expect(MemberRole.fromString('observer'), MemberRole.observer);
      expect(MemberRole.fromString('member'), MemberRole.member);
      expect(MemberRole.fromString(null), MemberRole.member);
      expect(MemberRole.fromString('unknown'), MemberRole.member);
    });

    test('Member normalizedPhone extracts last 9 digits', () {
      const m1 = Member(phone: '+251912345678');
      expect(m1.normalizedPhone, '912345678');

      const m2 = Member(phone: '0912345678');
      expect(m2.normalizedPhone, '912345678');

      const m3 = Member(phone: '912345678');
      expect(m3.normalizedPhone, '912345678');

      const m4 = Member(phone: '123');
      expect(m4.normalizedPhone, '123');
    });

    test('Member copyWith works correctly', () {
      const original = Member(
        id: '1',
        fullName: 'Test Name',
        role: MemberRole.member,
        orderIndex: 5,
      );

      final updated = original.copyWith(
        role: MemberRole.muse,
        orderIndex: 1,
      );

      expect(updated.id, '1');
      expect(updated.fullName, 'Test Name');
      expect(updated.role, MemberRole.muse);
      expect(updated.orderIndex, 1);
    });

    test('MemberRole firestoreValue maps correctly', () {
      expect(MemberRole.muse.firestoreValue, 'muse');
      expect(MemberRole.assistantMuse.firestoreValue, 'assistant_muse');
      expect(MemberRole.member.firestoreValue, 'member');
      expect(MemberRole.observer.firestoreValue, 'observer');
    });
  });

  group('FirestorePaths', () {
    test('member paths are correct', () {
      expect(
        FirestorePaths.members('gelan', 'tsiwa1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/members',
      );
      expect(
        FirestorePaths.member('gelan', 'tsiwa1', 'member1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/members/member1',
      );
    });

    test('event paths are correct', () {
      expect(
        FirestorePaths.events('gelan', 'tsiwa1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/events',
      );
      expect(
        FirestorePaths.event('gelan', 'tsiwa1', 'event1'),
        'areas/gelan/tsiwaMahbers/tsiwa1/events/event1',
      );
    });
  });

  group('EthiopianCalendar', () {
    test('converts known Gregorian date to Ethiopian', () {
      // September 11, 2024 (Gregorian) = Meskerem 1, 2017 (Ethiopian)
      final eth = EthiopianCalendar.fromGregorian(DateTime(2024, 9, 11));
      expect(eth.year, 2017);
      expect(eth.month, 1);
      expect(eth.day, 1);
    });

    test('converts Ethiopian date back to Gregorian', () {
      final greg = EthiopianCalendar.toGregorian(
        const EthiopianDate(year: 2017, month: 1, day: 1),
      );
      expect(greg.year, 2024);
      expect(greg.month, 9);
      expect(greg.day, 11);
    });

    test('round-trip conversion is consistent', () {
      final original = DateTime(2025, 1, 15);
      final eth = EthiopianCalendar.fromGregorian(original);
      final backToGreg = EthiopianCalendar.toGregorian(eth);
      expect(backToGreg.year, original.year);
      expect(backToGreg.month, original.month);
      expect(backToGreg.day, original.day);
    });

    test('EthiopianDate formatted includes month name', () {
      const date = EthiopianDate(year: 2017, month: 1, day: 15);
      expect(date.monthName, 'መስከረም');
      expect(date.shortFormatted, 'መስከረም 15');
      expect(date.formatted, 'መስከረም 15, 2017');
    });

    test('daysInMonth returns 30 for months 1-12', () {
      for (int m = 1; m <= 12; m++) {
        expect(EthiopianCalendar.daysInMonth(2017, m), 30);
      }
    });

    test('daysInMonth returns 5 or 6 for Pagume', () {
      // Ethiopian year 2019 (2019 % 4 == 3) is a leap year
      expect(EthiopianCalendar.daysInMonth(2019, 13), 6);
      // Ethiopian year 2017 (2017 % 4 == 1) is not a leap year
      expect(EthiopianCalendar.daysInMonth(2017, 13), 5);
    });

    test('daysUntilText returns correct Amharic text', () {
      expect(EthiopianCalendar.daysUntilText(0), 'ዛሬ');
      expect(EthiopianCalendar.daysUntilText(1), 'ነገ');
      expect(EthiopianCalendar.daysUntilText(5), '5 ቀናት ቀርተዋል');
      expect(EthiopianCalendar.daysUntilText(-1), '');
    });

    test('today returns a valid date', () {
      final today = EthiopianCalendar.today();
      expect(today.year, greaterThan(2010));
      expect(today.month, inInclusiveRange(1, 13));
      expect(today.day, inInclusiveRange(1, 30));
    });
  });

  group('TsiwaEvent', () {
    test('TsiwaEventType displayName returns Amharic', () {
      expect(TsiwaEventType.monthlyTsiwa.displayName, 'የወርሃዊ ፅዋ');
      expect(TsiwaEventType.yearlyZikir.displayName, 'የዓመታዊ በዓል ዝክር');
      expect(TsiwaEventType.other.displayName, 'ሌላ');
    });

    test('TsiwaEventType fromString parses correctly', () {
      expect(TsiwaEventType.fromString('monthly_tsiwa'),
          TsiwaEventType.monthlyTsiwa);
      expect(TsiwaEventType.fromString('yearly_zikir'),
          TsiwaEventType.yearlyZikir);
      expect(TsiwaEventType.fromString('zikir'),
          TsiwaEventType.yearlyZikir);
      expect(TsiwaEventType.fromString('feeding_day'),
          TsiwaEventType.yearlyZikir);
      expect(TsiwaEventType.fromString('unknown'), TsiwaEventType.other);
    });

    test('TsiwaEventStatus displayName returns Amharic', () {
      expect(TsiwaEventStatus.planned.displayName, 'የታቀደ');
      expect(TsiwaEventStatus.completed.displayName, 'የተፈጸመ');
      expect(TsiwaEventStatus.cancelled.displayName, 'የተሰረዘ');
    });

    test('TsiwaEventStatus fromString parses correctly', () {
      expect(TsiwaEventStatus.fromString('completed'),
          TsiwaEventStatus.completed);
      expect(TsiwaEventStatus.fromString('cancelled'),
          TsiwaEventStatus.cancelled);
      expect(TsiwaEventStatus.fromString('planned'),
          TsiwaEventStatus.planned);
      expect(TsiwaEventStatus.fromString(null), TsiwaEventStatus.planned);
    });

    test('TsiwaEvent copyWith works correctly', () {
      const original = TsiwaEvent(
        id: '1',
        type: TsiwaEventType.monthlyTsiwa,
        status: TsiwaEventStatus.planned,
        ethiopianYear: 2017,
      );

      final updated = original.copyWith(
        status: TsiwaEventStatus.completed,
        notes: 'Done',
      );

      expect(updated.id, '1');
      expect(updated.type, TsiwaEventType.monthlyTsiwa);
      expect(updated.status, TsiwaEventStatus.completed);
      expect(updated.notes, 'Done');
      expect(updated.ethiopianYear, 2017);
    });
  });

  group('Leader', () {
    test('LeaderRole displayName returns Amharic', () {
      expect(LeaderRole.owner.displayName, 'ባለቤት');
      expect(LeaderRole.amerar.displayName, 'አመራር');
      expect(LeaderRole.memakir.displayName, 'መማክርት');
      expect(LeaderRole.edirAmerar.displayName, 'የእድር አመራር');
      expect(LeaderRole.viewer.displayName, 'ታዛቢ');
    });

    test('LeaderRole fromString parses correctly', () {
      expect(LeaderRole.fromString('owner'), LeaderRole.owner);
      expect(LeaderRole.fromString('amerar'), LeaderRole.amerar);
      expect(LeaderRole.fromString('memakir'), LeaderRole.memakir);
      expect(LeaderRole.fromString('edir_amerar'), LeaderRole.edirAmerar);
      expect(LeaderRole.fromString('unknown'), LeaderRole.viewer);
      expect(LeaderRole.fromString(null), LeaderRole.viewer);
    });

    test('LeaderRole firestoreValue maps correctly', () {
      expect(LeaderRole.owner.firestoreValue, 'owner');
      expect(LeaderRole.amerar.firestoreValue, 'amerar');
      expect(LeaderRole.memakir.firestoreValue, 'memakir');
      expect(LeaderRole.edirAmerar.firestoreValue, 'edir_amerar');
      expect(LeaderRole.viewer.firestoreValue, 'viewer');
    });

    test('Leader copyWith works correctly', () {
      const original = Leader(
        id: '1',
        fullName: 'Test Leader',
        role: LeaderRole.amerar,
        assignedTsiwaIds: ['tsiwa1'],
      );

      final updated = original.copyWith(
        role: LeaderRole.owner,
        isActive: false,
      );

      expect(updated.id, '1');
      expect(updated.fullName, 'Test Leader');
      expect(updated.role, LeaderRole.owner);
      expect(updated.isActive, false);
      expect(updated.assignedTsiwaIds, ['tsiwa1']);
    });

    test('leader paths are correct', () {
      expect(
        FirestorePaths.leaders('gelan'),
        'areas/gelan/leaders',
      );
      expect(
        FirestorePaths.leader('gelan', 'leader1'),
        'areas/gelan/leaders/leader1',
      );
    });
  });

  group('Edir', () {
    test('Edir copyWith works correctly', () {
      const original = Edir(
        id: '1',
        name: 'Test Edir',
        monthlyContribution: 100,
        treasury: 5000,
      );

      final updated = original.copyWith(
        monthlyContribution: 200,
        penaltyAmount: 50,
      );

      expect(updated.id, '1');
      expect(updated.name, 'Test Edir');
      expect(updated.monthlyContribution, 200);
      expect(updated.penaltyAmount, 50);
      expect(updated.treasury, 5000);
    });

    test('edir paths are correct', () {
      expect(
        FirestorePaths.edirs('gelan'),
        'areas/gelan/edirs',
      );
      expect(
        FirestorePaths.edir('gelan', 'edir1'),
        'areas/gelan/edirs/edir1',
      );
      expect(
        FirestorePaths.edirMembers('gelan', 'edir1'),
        'areas/gelan/edirs/edir1/members',
      );
      expect(
        FirestorePaths.edirMember('gelan', 'edir1', 'member1'),
        'areas/gelan/edirs/edir1/members/member1',
      );
      expect(
        FirestorePaths.edirPayments('gelan', 'edir1'),
        'areas/gelan/edirs/edir1/payments',
      );
    });
  });

  group('EdirMember', () {
    test('EdirMemberStatus displayName returns Amharic', () {
      expect(EdirMemberStatus.active.displayName, 'ንቁ');
      expect(EdirMemberStatus.inactive.displayName, 'ቦዝኗል');
      expect(EdirMemberStatus.suspended.displayName, 'የታገደ');
    });

    test('EdirMemberStatus fromString parses correctly', () {
      expect(EdirMemberStatus.fromString('active'), EdirMemberStatus.active);
      expect(
          EdirMemberStatus.fromString('inactive'), EdirMemberStatus.inactive);
      expect(EdirMemberStatus.fromString('suspended'),
          EdirMemberStatus.suspended);
      expect(EdirMemberStatus.fromString(null), EdirMemberStatus.active);
      expect(EdirMemberStatus.fromString('unknown'), EdirMemberStatus.active);
    });

    test('EdirMemberStatus firestoreValue maps correctly', () {
      expect(EdirMemberStatus.active.firestoreValue, 'active');
      expect(EdirMemberStatus.inactive.firestoreValue, 'inactive');
      expect(EdirMemberStatus.suspended.firestoreValue, 'suspended');
    });

    test('EdirMember copyWith works correctly', () {
      const original = EdirMember(
        id: '1',
        fullName: 'Test Member',
        totalPaid: 500,
        paidMonths: 5,
      );

      final updated = original.copyWith(
        status: EdirMemberStatus.suspended,
        balance: 100,
      );

      expect(updated.id, '1');
      expect(updated.fullName, 'Test Member');
      expect(updated.status, EdirMemberStatus.suspended);
      expect(updated.totalPaid, 500);
      expect(updated.balance, 100);
      expect(updated.paidMonths, 5);
    });
  });

  group('Payment', () {
    test('PaymentType displayName returns Amharic', () {
      expect(PaymentType.monthly.displayName, 'ወርሃዊ');
      expect(PaymentType.penalty.displayName, 'ቅጣት');
      expect(PaymentType.other.displayName, 'ሌላ');
    });

    test('PaymentType fromString parses correctly', () {
      expect(PaymentType.fromString('monthly'), PaymentType.monthly);
      expect(PaymentType.fromString('penalty'), PaymentType.penalty);
      expect(PaymentType.fromString('other'), PaymentType.other);
      expect(PaymentType.fromString(null), PaymentType.other);
      expect(PaymentType.fromString('unknown'), PaymentType.other);
    });

    test('PaymentType firestoreValue maps correctly', () {
      expect(PaymentType.monthly.firestoreValue, 'monthly');
      expect(PaymentType.penalty.firestoreValue, 'penalty');
      expect(PaymentType.other.firestoreValue, 'other');
    });
  });

  group('AppUser', () {
    test('UserRole displayName returns Amharic', () {
      expect(UserRole.admin.displayName, 'አስተዳዳሪ');
      expect(UserRole.leader.displayName, 'አመራር');
      expect(UserRole.member.displayName, 'አባል');
      expect(UserRole.viewer.displayName, 'ታዛቢ');
    });

    test('UserRole fromString parses correctly', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('leader'), UserRole.leader);
      expect(UserRole.fromString('member'), UserRole.member);
      expect(UserRole.fromString('viewer'), UserRole.viewer);
      expect(UserRole.fromString(null), UserRole.viewer);
      expect(UserRole.fromString('unknown'), UserRole.viewer);
    });

    test('UserRole firestoreValue maps correctly', () {
      expect(UserRole.admin.firestoreValue, 'admin');
      expect(UserRole.leader.firestoreValue, 'leader');
      expect(UserRole.member.firestoreValue, 'member');
      expect(UserRole.viewer.firestoreValue, 'viewer');
    });

    test('UserRole permissions are correct', () {
      expect(UserRole.admin.canEdit, true);
      expect(UserRole.admin.canDelete, true);
      expect(UserRole.admin.canManageUsers, true);

      expect(UserRole.leader.canEdit, true);
      expect(UserRole.leader.canDelete, false);
      expect(UserRole.leader.canManageUsers, false);

      expect(UserRole.member.canEdit, false);
      expect(UserRole.member.canDelete, false);
      expect(UserRole.member.canManageUsers, false);

      expect(UserRole.viewer.canEdit, false);
      expect(UserRole.viewer.canDelete, false);
      expect(UserRole.viewer.canManageUsers, false);
    });

    test('AppUser copyWith works correctly', () {
      const original = AppUser(
        uid: '123',
        email: 'test@test.com',
        displayName: 'Test User',
        role: UserRole.viewer,
      );

      final updated = original.copyWith(
        role: UserRole.admin,
        phone: '0912345678',
      );

      expect(updated.uid, '123');
      expect(updated.email, 'test@test.com');
      expect(updated.displayName, 'Test User');
      expect(updated.role, UserRole.admin);
      expect(updated.phone, '0912345678');
    });
  });

  group('Announcement', () {
    test('AnnouncementPriority displayName returns Amharic', () {
      expect(AnnouncementPriority.normal.displayName, 'መደበኛ');
      expect(AnnouncementPriority.important.displayName, 'አስፈላጊ');
      expect(AnnouncementPriority.urgent.displayName, 'አስቸኳይ');
    });

    test('AnnouncementPriority fromString parses correctly', () {
      expect(
          AnnouncementPriority.fromString('normal'),
          AnnouncementPriority.normal);
      expect(
          AnnouncementPriority.fromString('important'),
          AnnouncementPriority.important);
      expect(
          AnnouncementPriority.fromString('urgent'),
          AnnouncementPriority.urgent);
      expect(
          AnnouncementPriority.fromString('unknown'),
          AnnouncementPriority.normal);
      expect(
          AnnouncementPriority.fromString(null),
          AnnouncementPriority.normal);
    });

    test('AnnouncementPriority firestoreValue maps correctly', () {
      expect(AnnouncementPriority.normal.firestoreValue, 'normal');
      expect(AnnouncementPriority.important.firestoreValue, 'important');
      expect(AnnouncementPriority.urgent.firestoreValue, 'urgent');
    });

    test('Announcement copyWith works correctly', () {
      final original = Announcement(
        id: 'ann1',
        title: 'ተስት',
        body: 'ዝርዝር',
        priority: AnnouncementPriority.normal,
        authorId: 'user1',
        authorName: 'Admin',
        readCount: 5,
        isActive: true,
      );

      final updated = original.copyWith(
        title: 'አዲስ ርዕስ',
        priority: AnnouncementPriority.urgent,
        readCount: 10,
      );

      expect(updated.id, 'ann1');
      expect(updated.title, 'አዲስ ርዕስ');
      expect(updated.body, 'ዝርዝር');
      expect(updated.priority, AnnouncementPriority.urgent);
      expect(updated.authorName, 'Admin');
      expect(updated.readCount, 10);
    });

    test('Announcement toCreateMap includes required fields', () {
      final announcement = Announcement(
        title: 'ተስት ማስታወቂያ',
        body: 'ይህ መልዕክት ነው',
        priority: AnnouncementPriority.important,
        authorId: 'user1',
        authorName: 'Admin',
      );

      final map = announcement.toCreateMap();

      expect(map['title'], 'ተስት ማስታወቂያ');
      expect(map['body'], 'ይህ መልዕክት ነው');
      expect(map['priority'], 'important');
      expect(map['authorId'], 'user1');
      expect(map['authorName'], 'Admin');
      expect(map['readCount'], 0);
      expect(map['isActive'], true);
    });

    test('Announcement toUpdateMap includes correct fields', () {
      final announcement = Announcement(
        id: 'ann1',
        title: 'አስተካክል',
        body: 'የተሰተከከለ',
        priority: AnnouncementPriority.urgent,
        isActive: false,
      );

      final map = announcement.toUpdateMap();

      expect(map['title'], 'አስተካክል');
      expect(map['body'], 'የተሰተከከለ');
      expect(map['priority'], 'urgent');
      expect(map['isActive'], false);
      expect(map.containsKey('authorId'), false);
    });

    test('ReadReceipt toMap includes required fields', () {
      final receipt = ReadReceipt(
        userId: 'user1',
        userName: 'Test User',
      );

      final map = receipt.toMap();

      expect(map['userId'], 'user1');
      expect(map['userName'], 'Test User');
    });

    test('Firestore paths for announcements are correct', () {
      expect(
        FirestorePaths.announcements('gelan'),
        'areas/gelan/announcements',
      );
      expect(
        FirestorePaths.announcement('gelan', 'ann1'),
        'areas/gelan/announcements/ann1',
      );
      expect(
        FirestorePaths.readReceipts('gelan', 'ann1'),
        'areas/gelan/announcements/ann1/readReceipts',
      );
      expect(
        FirestorePaths.readReceipt('gelan', 'ann1', 'user1'),
        'areas/gelan/announcements/ann1/readReceipts/user1',
      );
    });
  });

  group('AppNotification', () {
    test('NotificationType displayName returns Amharic', () {
      expect(NotificationType.announcement.displayName, 'ማስታወቂያ');
      expect(NotificationType.event.displayName, 'ክስተት');
      expect(NotificationType.payment.displayName, 'ክፍያ');
      expect(NotificationType.system.displayName, 'ስርዓት');
    });

    test('NotificationType fromString parses correctly', () {
      expect(NotificationType.fromString('announcement'),
          NotificationType.announcement);
      expect(NotificationType.fromString('event'),
          NotificationType.event);
      expect(NotificationType.fromString('payment'),
          NotificationType.payment);
      expect(NotificationType.fromString('system'),
          NotificationType.system);
      expect(NotificationType.fromString(null),
          NotificationType.system);
      expect(NotificationType.fromString('unknown'),
          NotificationType.system);
    });

    test('NotificationType firestoreValue maps correctly', () {
      expect(NotificationType.announcement.firestoreValue,
          'announcement');
      expect(NotificationType.event.firestoreValue, 'event');
      expect(NotificationType.payment.firestoreValue, 'payment');
      expect(NotificationType.system.firestoreValue, 'system');
    });

    test('AppNotification copyWith works correctly', () {
      const original = AppNotification(
        id: 'notif1',
        title: 'ሰላም',
        body: 'ዝርዝር',
        type: NotificationType.announcement,
        isRead: false,
      );

      final updated = original.copyWith(
        isRead: true,
        title: 'አዲስ ርዕስ',
      );

      expect(updated.id, 'notif1');
      expect(updated.title, 'አዲስ ርዕስ');
      expect(updated.body, 'ዝርዝር');
      expect(updated.type, NotificationType.announcement);
      expect(updated.isRead, true);
    });

    test('AppNotification toCreateMap includes required fields', () {
      const notification = AppNotification(
        title: 'ተስት',
        body: 'ሰላም',
        type: NotificationType.event,
        senderId: 'user1',
        senderName: 'Admin',
      );

      final map = notification.toCreateMap();

      expect(map['title'], 'ተስት');
      expect(map['body'], 'ሰላም');
      expect(map['type'], 'event');
      expect(map['senderId'], 'user1');
      expect(map['senderName'], 'Admin');
      expect(map['isRead'], false);
    });
  });

  group('TelegramConfig', () {
    test('fromMap creates correct config', () {
      final config = TelegramConfig.fromMap({
        'botToken': 'token123',
        'chatId': '-100123',
        'isEnabled': true,
        'sendAnnouncements': true,
        'sendEvents': false,
      });

      expect(config.botToken, 'token123');
      expect(config.chatId, '-100123');
      expect(config.isEnabled, true);
      expect(config.sendAnnouncements, true);
      expect(config.sendEvents, false);
    });

    test('toMap returns correct map', () {
      const config = TelegramConfig(
        botToken: 'abc',
        chatId: '-999',
        isEnabled: true,
        sendAnnouncements: false,
        sendEvents: true,
      );

      final map = config.toMap();

      expect(map['botToken'], 'abc');
      expect(map['chatId'], '-999');
      expect(map['isEnabled'], true);
      expect(map['sendAnnouncements'], false);
      expect(map['sendEvents'], true);
    });

    test('copyWith works correctly', () {
      const original = TelegramConfig(
        botToken: 'token',
        chatId: 'chat',
        isEnabled: false,
      );

      final updated = original.copyWith(
        isEnabled: true,
        sendEvents: true,
      );

      expect(updated.botToken, 'token');
      expect(updated.chatId, 'chat');
      expect(updated.isEnabled, true);
      expect(updated.sendAnnouncements, true);
      expect(updated.sendEvents, true);
    });

    test('default values are correct', () {
      const config = TelegramConfig();

      expect(config.botToken, '');
      expect(config.chatId, '');
      expect(config.isEnabled, false);
      expect(config.sendAnnouncements, true);
      expect(config.sendEvents, false);
    });
  });
}
