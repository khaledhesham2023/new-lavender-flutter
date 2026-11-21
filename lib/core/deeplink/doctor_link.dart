/// Doctor id of a shared doctor link (`https://<HOST>/doctor/<id>`), or null.
///
/// Port of `MainActivity.extractNumberFromPath` (regex on the path). The regex
/// is not anchored, like Android's, so `/x/doctor/5` also yields 5 (the
/// manifest filters decide which hosts and prefixes reach the app at all).
int? parseDoctorId(Uri uri) {
  final match = RegExp(r'/doctor/(\d+)').firstMatch(uri.path);
  return match == null ? null : int.tryParse(match.group(1)!);
}
