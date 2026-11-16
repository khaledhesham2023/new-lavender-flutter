import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/responses/notification.dart';

void main() {
  test('NotificationModel id is a String and data.notify_id an int', () {
    final n = NotificationModel.fromJson({
      'id': '9b2f-uuid',
      'title': 'T',
      'body': 'B',
      'is_readed': 0,
      'data': {'notify_id': '15', 'notify_type': 'appointment'},
      'sending_time_ago': '1 hour ago',
    });
    expect(n.id, '9b2f-uuid');
    expect(n.data!.notifyId, 15);
    expect(n.data!.notifyType, 'appointment');
    expect(n.isReaded, false);
    expect(n.readAt, isNull);
    expect(n.sendingTimeAgo, '1 hour ago');
  });

  test('numeric id is converted to String', () {
    expect(NotificationModel.fromJson({'id': 5}).id, '5');
  });

  test('copyWith(isReaded)', () {
    const n = NotificationModel(id: 'a', isReaded: false);
    expect(n.copyWith(isReaded: true).isReaded, true);
    expect(n.copyWith().isReaded, false);
  });
}
