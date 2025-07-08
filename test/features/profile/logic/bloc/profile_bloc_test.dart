import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:eimunisasi/core/utils/list_constant.dart';
import 'package:eimunisasi/features/authentication/data/models/user_profile.dart';
import 'package:eimunisasi/features/authentication/data/repositories/auth_repository.dart';
import 'package:eimunisasi/features/profile/logic/blocs/parentBloc/profile_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'profile_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  const momName = 'momName';
  const placeOfBirth = 'placeOfBirth';
  final dateOfBirth = DateTime(2021, 1, 1);
  const identityNumber = '1111111111111111';
  const familyCardNumber = '2222222222222222';
  final job = ListConstant.JOB[0];
  final bloodType = ListConstant.TYPE_BLOOD[0];

  final user = UserProfile(
    momName: momName,
    placeOfBirth: placeOfBirth,
    dateOfBirth: dateOfBirth,
    noKTP: identityNumber,
    noKK: familyCardNumber,
    momJob: job,
    momBloodType: bloodType,
  );

  group("OnChangeFieldEvent", () {
    late AuthRepository mockAuthRepository;
    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    final ProfileState initialState = ProfileState(
      statusGet: FormzSubmissionStatus.initial,
      statusUpdate: FormzSubmissionStatus.initial,
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangeNameEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangeNameEvent(momName)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            momName: momName,
          ),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangePlaceOfBirthEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangePlaceOfBirthEvent(placeOfBirth)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            placeOfBirth: placeOfBirth,
          ),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangeDateOfBirthEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangeDateOfBirthEvent(dateOfBirth)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            dateOfBirth: dateOfBirth,
          ),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangeIdentityNumberEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangeIdentityNumberEvent(identityNumber)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            noKTP: identityNumber,
          ),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangeFamilyCardNumberEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangeFamilyCardNumberEvent(familyCardNumber)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            noKK: familyCardNumber,
          ),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangeJobEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangeJobEvent(job)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            momJob: job,
          ),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'OnChangeBloodTypeEvent Success',
      build: () => ProfileBloc(mockAuthRepository),
      act: (bloc) => bloc.add(OnChangeBloodTypeEvent(bloodType)),
      expect: () => [
        initialState.copyWith(
          user: initialState.user?.copyWith(
            momBloodType: bloodType,
          ),
        ),
      ],
    );
  });

  group("OnProfileGetEvent", () {
    late AuthRepository mockAuthRepository;
    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    blocTest<ProfileBloc, ProfileState>(
      "success",
      build: () {
        when(mockAuthRepository.getUser()).thenAnswer((_) async => user);
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(ProfileGetEvent()),
      expect: () => [
        ProfileState(
          statusGet: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          user: user,
          statusGet: FormzSubmissionStatus.success,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed",
      build: () {
        when(mockAuthRepository.getUser()).thenThrow(Exception());
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(ProfileGetEvent()),
      expect: () => [
        ProfileState(
          statusGet: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          statusGet: FormzSubmissionStatus.failure,
        )
      ],
    );
  });

  group("ProfileUpdateEvent", () {
    late AuthRepository mockAuthRepository;
    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    blocTest<ProfileBloc, ProfileState>(
      "success",
      build: () {
        when(mockAuthRepository.insertUserToDatabase(user: user))
            .thenAnswer((_) async => true);
        return ProfileBloc(mockAuthRepository);
      },
      seed: () => ProfileState(user: user),
      act: (bloc) => bloc.add(ProfileUpdateEvent()),
      expect: () => [
        ProfileState(
          user: user,
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          user: user,
          statusUpdate: FormzSubmissionStatus.success,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed if insertUserToDatabase throws",
      build: () {
        when(mockAuthRepository.insertUserToDatabase(user: user))
            .thenThrow(Exception());
        return ProfileBloc(mockAuthRepository);
      },
      seed: () => ProfileState(user: user),
      act: (bloc) => bloc.add(ProfileUpdateEvent()),
      expect: () => [
        ProfileState(
          user: user,
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          user: user,
          statusUpdate: FormzSubmissionStatus.failure,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed if user - mom name is empty",
      build: () {
        return ProfileBloc(mockAuthRepository);
      },
      seed: () => ProfileState(user: user.copyWith(
        momName: '',
      )),
      act: (bloc) => bloc.add(ProfileUpdateEvent()),
      expect: () => [
        ProfileState(
          user: user.copyWith(
            momName: '',
          ),
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          user: user.copyWith(
            momName: '',
          ),
          errorMessage: 'Nama tidak boleh kosong',
          statusUpdate: FormzSubmissionStatus.failure,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed if user - dad name is empty",
      build: () {
        return ProfileBloc(mockAuthRepository);
      },
      seed: () => ProfileState(user: user.copyWith(
        dadName: '',
      )),
      act: (bloc) => bloc.add(ProfileUpdateEvent()),
      expect: () => [
        ProfileState(
          user: user.copyWith(
            dadName: '',
          ),
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          user: user.copyWith(
            dadName: '',
          ),
          errorMessage: 'Nama tidak boleh kosong',
          statusUpdate: FormzSubmissionStatus.failure,
        )
      ],
    );
  });

  group("ProfileUpdateAvatarEvent", () {
    late AuthRepository mockAuthRepository;

    final File file = File('test');
    final String url = 'url';

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    blocTest<ProfileBloc, ProfileState>(
      "success",
      build: () {
        when(mockAuthRepository.uploadImage(file)).thenAnswer((_) async => url);
        when(mockAuthRepository.updateUserAvatar(url))
            .thenAnswer((_) async => true);
        when(mockAuthRepository.getUser()).thenAnswer((_) async => user);
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(ProfileUpdateAvatarEvent(file)),
      expect: () => [
        ProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.success,
        ),
        ProfileState(
          statusGet: FormzSubmissionStatus.inProgress,
          statusUpdateAvatar: FormzSubmissionStatus.success,
        ),
        ProfileState(
          user: user,
          statusGet: FormzSubmissionStatus.success,
          statusUpdateAvatar: FormzSubmissionStatus.success,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed uploadImage",
      build: () {
        when(mockAuthRepository.uploadImage(file)).thenThrow(Exception());
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(ProfileUpdateAvatarEvent(file)),
      expect: () => [
        ProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.failure,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed updateUserAvatar",
      build: () {
        when(mockAuthRepository.uploadImage(file)).thenAnswer((_) async => url);
        when(mockAuthRepository.updateUserAvatar(url)).thenThrow(Exception());
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(ProfileUpdateAvatarEvent(file)),
      expect: () => [
        ProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.failure,
        )
      ],
    );
  });

  group('VerifyEmailEvent', () {
    late AuthRepository mockAuthRepository;
    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    blocTest<ProfileBloc, ProfileState>(
      "success",
      build: () {
        when(mockAuthRepository.verifyEmail()).thenAnswer((_) async => true);
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(VerifyEmailEvent()),
      expect: () => [
        ProfileState(
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          statusUpdate: FormzSubmissionStatus.success,
        )
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      "failed",
      build: () {
        when(mockAuthRepository.verifyEmail()).thenThrow(Exception());
        return ProfileBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(VerifyEmailEvent()),
      expect: () => [
        ProfileState(
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ProfileState(
          statusUpdate: FormzSubmissionStatus.failure,
        )
      ],
    );
  });
}
