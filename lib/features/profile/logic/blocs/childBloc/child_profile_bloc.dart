import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/child_model.dart';
import '../../../data/repositories/child_repository.dart';

part 'child_profile_event.dart';

part 'child_profile_state.dart';

@injectable
class ChildProfileBloc extends Bloc<ChildProfileEvent, ChildProfileState> {
  final ChildRepository _childRepository;

  ChildProfileBloc(this._childRepository) : super(const ChildProfileState()) {
    on<OnInitialEvent>(_onInitialEvent);
    on<OnGetChildrenEvent>(_onGetChildrenEvent);
    on<OnChangeNameEvent>(_onChangeNameEvent);
    on<OnChangeIdentityNumberEvent>(_onChangeIdentityNumberEvent);
    on<OnChangePlaceOfBirthEvent>(_onChangePlaceOfBirthEvent);
    on<OnChangeDateOfBirthEvent>(_onChangeDateOfBirthEvent);
    on<OnChangeGenderEvent>(_onChangeGenderEvent);
    on<OnChangeBloodTypeEvent>(_onChangeBloodTypeEvent);
    on<UpdateProfileEvent>(_onUpdateChildEvent);
    on<CreateProfileEvent>(_onCreateChildEvent);
    on<UpdateProfilePhotoEvent>(_onUpdateAvatarEvent);
  }

  void _onInitialEvent(OnInitialEvent event, Emitter emit) {
    emit(state.copyWith(
      child: event.child,
    ));
  }

  void _onGetChildrenEvent(OnGetChildrenEvent event, Emitter emit) async {
    emit(state.copyWith(statusGetChildren: FormzSubmissionStatus.inProgress));
    try {
      final children = await _childRepository.getAllChildren();
      emit(state.copyWith(
        statusGetChildren: FormzSubmissionStatus.success,
        children: children,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          statusGetChildren: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal memuat data anak',
        ),
      );
    }
  }

  void _onChangeNameEvent(OnChangeNameEvent event, Emitter emit) {
    emit(state.copyWith(
      child: state.child?.copyWith(nama: event.name),
    ));
  }

  void _onChangeIdentityNumberEvent(
      OnChangeIdentityNumberEvent event, Emitter emit) {
    emit(state.copyWith(
      child: state.child?.copyWith(nik: event.identityNumber),
    ));
  }

  void _onChangePlaceOfBirthEvent(
      OnChangePlaceOfBirthEvent event, Emitter emit) {
    emit(state.copyWith(
      child: state.child?.copyWith(tempatLahir: event.placeOfBirth),
    ));
  }

  void _onChangeDateOfBirthEvent(OnChangeDateOfBirthEvent event, Emitter emit) {
    emit(state.copyWith(
      child: state.child?.copyWith(tanggalLahir: event.dateOfBirth),
    ));
  }

  void _onChangeGenderEvent(OnChangeGenderEvent event, Emitter emit) {
    emit(state.copyWith(
      child: state.child?.copyWith(jenisKelamin: event.gender),
    ));
  }

  void _onChangeBloodTypeEvent(OnChangeBloodTypeEvent event, Emitter emit) {
    emit(state.copyWith(
      child: state.child?.copyWith(golDarah: event.bloodType),
    ));
  }

  void _onUpdateChildEvent(UpdateProfileEvent event, Emitter emit) async {
    emit(state.copyWith(statusUpdate: FormzSubmissionStatus.inProgress));
    try {
      if (state.child == null) {
        throw FormatException('Data anak tidak boleh kosong');
      }

      if ((state.child?.nama?.length ?? 0) < 2 ||
          (state.child?.nama?.length ?? 0) > 128) {
        throw FormatException('Panjang nama harus antara 2-128 karakter');
      }

      if (state.child?.tanggalLahir == null) {
        throw FormatException('Tanggal lahir tidak boleh kosong');
      }
      await _childRepository.updateChild(state.child!);
      add(OnGetChildrenEvent());
      emit(state.copyWith(statusUpdate: FormzSubmissionStatus.success));
      emit(state.copyWith(
          child: null, statusUpdate: FormzSubmissionStatus.initial));
    } catch (e) {
      if (e is FormatException) {
        emit(
          state.copyWith(
            statusUpdate: FormzSubmissionStatus.failure,
            errorMessage: e.message,
          ),
        );
        return;
      }
      emit(state.copyWith(
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal memperbarui profil anak'));
    }
  }

  void _onCreateChildEvent(CreateProfileEvent event, Emitter emit) async {
    emit(state.copyWith(statusCreate: FormzSubmissionStatus.inProgress));
    try {
      if (state.child == null) {
        throw FormatException('Data anak tidak boleh kosong');
      }

      if ((state.child?.nama?.length ?? 0) < 2 ||
          (state.child?.nama?.length ?? 0) > 128) {
        throw FormatException('Panjang nama harus antara 2-128 karakter');
      }

      if (state.child?.tanggalLahir == null) {
        throw FormatException('Tanggal lahir tidak boleh kosong');
      }
      await _childRepository.setChild(state.child!);
      add(OnGetChildrenEvent());
      emit(
        state.copyWith(
          statusCreate: FormzSubmissionStatus.success,
          child: null,
        ),
      );
      emit(state.copyWith(statusCreate: FormzSubmissionStatus.initial));
    } catch (e) {
      if (e is FormatException) {
        emit(
          state.copyWith(
            statusCreate: FormzSubmissionStatus.failure,
            errorMessage: e.message,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          statusCreate: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal membuat profil anak',
        ),
      );
    }
  }

  void _onUpdateAvatarEvent(UpdateProfilePhotoEvent event, Emitter emit) async {
    emit(state.copyWith(
      statusUpdateAvatar: FormzSubmissionStatus.inProgress,
    ));
    try {
      final url = await _childRepository.updateChildAvatar(
        file: event.photo,
        id: event.id,
      );
      emit(state.copyWith(
        statusUpdateAvatar: FormzSubmissionStatus.success,
        child: state.child?.copyWith(photoURL: url),
      ));
      emit(state.copyWith(
        statusUpdateAvatar: FormzSubmissionStatus.initial,
      ));
      add(OnGetChildrenEvent());
    } catch (e) {
      emit(state.copyWith(
        statusUpdateAvatar: FormzSubmissionStatus.failure,
        errorMessage: 'Gagal memperbarui foto profil anak',
      ));
    }
  }
}
