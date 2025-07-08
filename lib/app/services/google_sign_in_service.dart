import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/app/services/mini_box.dart';

import '../../helpers/mini_logger.dart';
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  factory GoogleSignInService() => _instance;

  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<auth.AuthClient?> getAuthenticatedClient() async {
    return await _googleSignIn.authenticatedClient();
  }

  Future<String?> getCurrentUserEmail() async {
    return _googleSignIn.currentUser?.email;
  }

  Future<bool> restoreGoogleAccount() async {
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      await MiniBox().write(mGoogleEmail, account.email);
      MiniLogger.d("Restored user: ${account.email}");
      return true;
    } else {
      await MiniBox().write(mGoogleEmail, null);
      MiniLogger.d("No previous session found");
      return false;
    }
  }


}
