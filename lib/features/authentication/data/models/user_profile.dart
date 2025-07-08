import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? uid;
  final String? momName;
  final String? dadName;
  final String? dadPhoneNumber;
  final String? momPhoneNumber;
  final String? email;
  final String? dadBloodType;
  final String? momBloodType;
  final String? dadJob;
  final String? momJob;
  final String? address;
  final String? avatarURL;
  final bool? verified;
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  final String? noKK;
  final String? noKTP;

  UserProfile({
    this.dadBloodType,
    this.momBloodType,
    this.dadJob,
    this.momJob,
    this.dadPhoneNumber,
    this.momPhoneNumber,
    this.address,
    this.momName,
    this.dadName,
    this.uid,
    this.email,
    this.avatarURL,
    this.verified,
    this.placeOfBirth,
    this.dateOfBirth,
    this.noKK,
    this.noKTP,
  });

  get isNameEmpty =>
      (momName?.isEmpty ?? false) || (dadName?.isEmpty ?? false);

  factory UserProfile.fromSeribase(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['user_id'],
      email: data['email'] ?? '',
      momName: data['mother_name'] ?? '',
      dadName: data['father_name'] ?? '',
      dadPhoneNumber: data['father_phone_number'] ?? '',
      momPhoneNumber: data['mother_phone_number'] ?? '',
      dadBloodType: data['father_blood_type'] ?? '',
      momBloodType: data['mother_blood_type'] ?? '',
      dadJob: data['father_job'] ?? '',
      momJob: data['mother_job'] ?? '',
      address: data['address'] ?? '',
      avatarURL: data['avatar_url'] ?? '',
      verified: data['verified'] ?? false,
      placeOfBirth: data['place_of_birth'] ?? '',
      dateOfBirth: () {
        try {
          return DateTime.parse(data['date_of_birth']);
        } catch (e) {
          return null;
        }
      }(),
      noKK: data['no_kartu_keluarga'] ?? '',
      noKTP: data['no_induk_kependudukan'] ?? '',
    );
  }

  Map<String, dynamic> toSeribaseMap() {
    return {
      if (uid?.isNotEmpty ?? false) "user_id": uid,
      if (momName?.isNotEmpty ?? false) "mother_name": momName,
      if (dadName?.isNotEmpty ?? false) "father_name": dadName,
      if (dadPhoneNumber?.isNotEmpty ?? false) "father_phone_number": dadPhoneNumber,
      if (momPhoneNumber?.isNotEmpty ?? false) "mother_phone_number": momPhoneNumber,
      if (dadBloodType?.isNotEmpty ?? false) "father_blood_type": dadBloodType,
      if (momBloodType?.isNotEmpty ?? false) "mother_blood_type": momBloodType,
      if (dadJob?.isNotEmpty ?? false) "father_job": dadJob,
      if (momJob?.isNotEmpty ?? false) "mother_job": momJob,
      if (address?.isNotEmpty ?? false) "address": address,
      if (avatarURL?.isNotEmpty ?? false) "avatar_url": avatarURL,
      if (placeOfBirth?.isNotEmpty ?? false) "place_of_birth": placeOfBirth,
      if (dateOfBirth != null)
        "date_of_birth": dateOfBirth?.toIso8601String(),
      if (noKK?.isNotEmpty ?? false) "no_kartu_keluarga": noKK,
      if (noKTP?.isNotEmpty ?? false) "no_induk_kependudukan": noKTP,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? momName,
    String? dadName,
    String? dadPhoneNumber,
    String? momPhoneNumber,
    String? dadBloodType,
    String? momBloodType,
    String? dadJob,
    String? momJob,
    String? address,
    String? avatarURL,
    bool? verified,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? noKK,
    String? noKTP,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      momName: momName ?? this.momName,
      dadName: dadName ?? this.dadName,
      dadPhoneNumber: dadPhoneNumber ?? this.dadPhoneNumber,
      momPhoneNumber: momPhoneNumber ?? this.momPhoneNumber,
      dadBloodType: dadBloodType ?? this.dadBloodType,
      momBloodType: momBloodType ?? this.momBloodType,
      dadJob: dadJob ?? this.dadJob,
      momJob: momJob ?? this.momJob,
      address: address ?? this.address,
      avatarURL: avatarURL ?? this.avatarURL,
      verified: verified ?? this.verified,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      noKK: noKK ?? this.noKK,
      noKTP: noKTP ?? this.noKTP,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        momName,
        dadName,
        dadPhoneNumber,
        momPhoneNumber,
        dadBloodType,
        momBloodType,
        dadJob,
        momJob,
        address,
        avatarURL,
        verified,
        placeOfBirth,
        dateOfBirth,
        noKK,
        noKTP,
      ];
}