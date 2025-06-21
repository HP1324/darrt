import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

import '../../helpers/mini_logger.dart';
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();

  factory GoogleSignInService() => _instance;

  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
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

  dynamic getAuthenticatedClient() async {
    return await _googleSignIn.authenticatedClient();
  }

  Future<String?> getCurrentUserEmail() async {
    return _googleSignIn.currentUser?.email;
  }

  Future<void> restoreGoogleAccount() async {
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      MiniLogger.d("Restored user: ${account.email}");
    } else {
      MiniLogger.d("No previous session found");
    }
  }
}
