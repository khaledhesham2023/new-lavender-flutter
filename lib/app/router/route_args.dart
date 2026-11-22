import 'package:equatable/equatable.dart';

import '../../data/models/requests/booking_draft.dart';
import '../../data/models/responses/offer.dart';
import '../../features/search_details/search_filter.dart';

/// Typed arguments passed in route `extra` (paths live in routes.dart).
/// Where an OTP screen was opened from (decides what happens after verifying).
enum OtpDestination {
  login,
  register,
  resetPassword,
  editProfile,
  editProfileAddNewPassword,
}

class OtpArgs extends Equatable {
  final String phone;
  final String phoneCode;
  final OtpDestination fromDestination;

  const OtpArgs({
    required this.phone,
    required this.phoneCode,
    required this.fromDestination,
  });

  @override
  List<Object?> get props => [phone, phoneCode, fromDestination];
}

class NewPasswordArgs extends Equatable {
  final String phone;
  final String phoneCode;
  final String otp;

  const NewPasswordArgs({
    required this.phone,
    required this.phoneCode,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, phoneCode, otp];
}

class ChangePasswordArgs extends Equatable {
  final String phone;
  final String code;

  const ChangePasswordArgs({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}

class BookWithOfferArgs extends Equatable {
  final BookingDraft draft;
  final OfferModel offer;

  const BookWithOfferArgs({required this.draft, required this.offer});

  @override
  List<Object?> get props => [draft, offer];
}

/// Opens the Filter screen (T21) from Search details; it pops a `SearchFilter`.
class FilterArgs extends Equatable {
  final int specialtyId;
  final SearchFilter current;

  const FilterArgs(this.specialtyId, this.current);

  @override
  List<Object?> get props => [specialtyId, current];
}
