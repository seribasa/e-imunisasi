import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';

import '../../../../authentication/data/models/user_profile.dart';
import '../../../../authentication/data/repositories/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@Injectable()
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;

  ProfileBloc(this._authRepository) : super(ProfileState()) {
    on<ProfileGetEvent>(_onProfileGetEvent);
    on<ProfileUpdateEvent>(_onProfileUpdateEvent);
    on<ProfileUpdateAvatarEvent>(_onProfileUpdateAvatarEvent);
    on<VerifyEmailEvent>(_onVerifyEmailEvent);

    on<OnChangeNameEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(momName: event.name),
        ),
      );
    });
    on<OnChangePlaceOfBirthEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(placeOfBirth: event.placeOfBirth),
          statusUpdate: FormzSubmissionStatus.initial,
        ),
      );
    });
    on<OnChangeDateOfBirthEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(dateOfBirth: event.dateOfBirth),
          statusUpdate: FormzSubmissionStatus.initial,
        ),
      );
    });
    on<OnChangeIdentityNumberEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(noKTP: event.identityNumber),
          statusUpdate: FormzSubmissionStatus.initial,
        ),
      );
    });
    on<OnChangeFamilyCardNumberEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(noKK: event.familyCardNumber),
          statusUpdate: FormzSubmissionStatus.initial,
        ),
      );
    });
    on<OnChangeJobEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(momJob: event.job),
          statusUpdate: FormzSubmissionStatus.initial,
        ),
      );
    });
    on<OnChangeBloodTypeEvent>((event, emit) {
      emit(
        state.copyWith(
          user: state.user?.copyWith(momBloodType: event.bloodType),
          statusUpdate: FormzSubmissionStatus.initial,
        ),
      );
    });
  }

  void _onProfileGetEvent(
    ProfileGetEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(statusGet: FormzSubmissionStatus.inProgress));
    try {
      final user = await _authRepository.getUser();
      emit(
        state.copyWith(user: user, statusGet: FormzSubmissionStatus.success),
      );
    } catch (e) {
      emit(state.copyWith(statusGet: FormzSubmissionStatus.failure));
    }
  }

  void _onProfileUpdateEvent(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(statusUpdate: FormzSubmissionStatus.inProgress));
    try {
      if (state.user == null) {
        emit(state.copyWith(
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'User tidak ditemukan',
        ));
        return;
      }
      
      if (state.user?.isNameEmpty == true) {
        emit(state.copyWith(
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'Nama tidak boleh kosong',
        ));
        return;
      }
      await _authRepository.insertUserToDatabase(user: state.user!);
      emit(state.copyWith(statusUpdate: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(statusUpdate: FormzSubmissionStatus.failure));
    }
  }

  void _onProfileUpdateAvatarEvent(
    ProfileUpdateAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(statusUpdateAvatar: FormzSubmissionStatus.inProgress));
    try {
      final url = await _authRepository.uploadImage(event.file);
      await _authRepository.updateUserAvatar(url);
      emit(state.copyWith(statusUpdateAvatar: FormzSubmissionStatus.success));
      add(ProfileGetEvent());
    } catch (e) {
      emit(state.copyWith(statusUpdateAvatar: FormzSubmissionStatus.failure));
    }
  }

  void _onVerifyEmailEvent(
    VerifyEmailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(statusUpdate: FormzSubmissionStatus.inProgress));
    try {
      await _authRepository.verifyEmail();
      emit(state.copyWith(statusUpdate: FormzSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(statusUpdate: FormzSubmissionStatus.failure));
    }
  }
}
