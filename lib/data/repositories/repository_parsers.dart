import '../json/json_utils.dart';
import '../models/responses/user.dart';

/// Shared response parsers for the repositories. `ApiClient` hands them the
/// whole decoded body; each reads `body['data']`.

/// Endpoints with nothing to parse.
void parseVoid(dynamic body) {}

/// `data` is a required user object (a missing one becomes an UnknownFailure).
UserModel parseUser(dynamic body) =>
    asObject(asMap(body)?['data'], UserModel.fromJson)!;

/// `data` is an optional user object.
UserModel? parseUserOrNull(dynamic body) =>
    asObject(asMap(body)?['data'], UserModel.fromJson);
