import 'package:darrt/app/exceptions.dart';
import 'package:darrt/app/services/backup_service.dart';
import 'package:darrt/app/services/google_sign_in_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/app/workmanger/tasks/auto_backup.dart';
import 'package:darrt/app/workmanger/tasks/dialy_quote_notif.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class WorkmanagerTasks {
  static Future<void> autoBackup() async {
    try {
      await ObjectBox().init();
      MiniBox().initStorage();

      final isSignedIn = await GoogleSignInService().restoreGoogleAccount();
      if (!isSignedIn) throw GoogleClientNotAuthenticatedError();
      await BackupService().performBackup();
      await createBackupSuccessNotification();
      MiniBox().write(mLastBackupDate, DateTime.now());
      ObjectBox().close();
    } on InternetOffError catch (e) {
      MiniLogger.dp("internet off");
      await Sentry.captureException(e);
      await createBackupFailureNotification(e.userMessage!);
    } on GoogleClientNotAuthenticatedError catch (e) {
      MiniLogger.dp("client not authenticated");
      await Sentry.captureException(e);
      await createBackupFailureNotification(e.userMessage!);
    } catch (e, t) {
      await Sentry.captureException(e, stackTrace: t);
      MiniLogger.dp('${e.toString()}, type: ${e.runtimeType}');
      MiniLogger.dp(t.toString());
      await createBackupFailureNotification('Something went wrong');
    }
  }

  static Future<void> dailyQuoteNotif() async{
    final QuoteModel? quoteModel = await fetchQuoteInBackground();
    if(quoteModel == null) return;
    await showQuoteNotification(quoteModel);
  }
}
