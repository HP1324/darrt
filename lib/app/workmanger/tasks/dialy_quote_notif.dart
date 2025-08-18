import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

class QuoteModel {
  String quote;
  String author;

  QuoteModel({required this.quote, required this.author});
}

/// Returns a record with the quote and author name
Future<QuoteModel?> fetchQuoteInBackground() async {
  MiniLogger.dp('Fetch quote function called');
  var quote = '';
  var author = '';
  try {
    MiniLogger.dp('Request will initialize now');
    final response = await http.get(
      Uri.parse('https://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=en'),
      headers: {'Accept': 'application/json'},
    );
    MiniLogger.dp('Request made');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      quote = data['quoteText']?.toString().trim() ?? '';
      author = data['quoteAuthor']?.toString().trim() ?? 'Unknown';
      if (quote.isNotEmpty) {
        quote = quote.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (quote.endsWith('.')) {
          quote = quote.substring(0, quote.length - 1);
        }
        MiniLogger.d("Quote: $quote");
        MiniLogger.d("Quote: $quote");
        return QuoteModel(quote: quote, author: author);
      }
    } else {
      throw Exception('Failed to load quote');
    }
  } catch (e, t) {
    Sentry.captureException(e, stackTrace: t);
    MiniLogger.dp('${e.toString()}, type: ${e.runtimeType}');
    return null;
  }
  return null;
}

Future<void> showQuoteNotification(QuoteModel quoteModel) async {
  MiniLogger.dp('Create quote notification function called');
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      channelKey: notifChannelKey,
      id: 1,
      title: 'Today\'s Quote',
      body: '${quoteModel.quote}\n\n— ${quoteModel.author}',
      notificationLayout: NotificationLayout.BigText,
    ),
  );
}

Future<void> scheduleTestOneOffQuoteNotification() async {
  await Workmanager().registerOneOffTask(
    mDailyQuoteNotif,
    mDailyQuoteNotif,
    constraints: Constraints(networkType: NetworkType.connected),
    initialDelay: Duration(seconds: 10),
  );
}

Future<void> scheduleDailyQuoteNotification() async {
  MiniLogger.dp('first time quote task called');
  await Workmanager().registerPeriodicTask(
    mDailyQuoteNotif,
    mDailyQuoteNotif,
    constraints: Constraints(networkType: NetworkType.connected),
    initialDelay: _timeUntil(10),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    // initialDelay: const Duration(seconds: 60),
    frequency: const Duration(days: 1),
  );
}

Future<void> cancelDailyQuoteNotification() async {
  await Workmanager().cancelByUniqueName(mDailyQuoteNotif);
}


Duration _timeUntil(int targetHour) {
  final now = DateTime.now();
  final targetTime = DateTime(now.year, now.month, now.day, targetHour);

  if (now.isAfter(targetTime)) {
    return targetTime.add(const Duration(days: 1)).difference(now);
  } else {
    return targetTime.difference(now);
  }
}
