/// Converts sharing URLs (e.g. Google Drive) to direct image URLs.
class ImageUrlHelper {
  ImageUrlHelper._();

  static final _driveFilePattern = RegExp(
    r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)',
  );

  static final _driveOpenPattern = RegExp(
    r'drive\.google\.com/open\?id=([a-zA-Z0-9_-]+)',
  );

  /// Returns a direct-loadable image URL.
  ///
  /// Supported conversions:
  /// - `https://drive.google.com/file/d/ID/view...`
  ///   → `https://lh3.googleusercontent.com/d/ID`
  /// - `https://drive.google.com/open?id=ID`
  ///   → `https://lh3.googleusercontent.com/d/ID`
  /// - All other URLs are returned unchanged.
  static String toDirectUrl(String url) {
    if (url.isEmpty) return url;

    var match = _driveFilePattern.firstMatch(url);
    if (match != null) {
      return 'https://lh3.googleusercontent.com/d/${match.group(1)}';
    }

    match = _driveOpenPattern.firstMatch(url);
    if (match != null) {
      return 'https://lh3.googleusercontent.com/d/${match.group(1)}';
    }

    return url;
  }
}
