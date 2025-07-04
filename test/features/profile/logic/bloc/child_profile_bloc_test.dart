import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:eimunisasi/core/utils/list_constant.dart';
import 'package:eimunisasi/features/profile/data/models/child_model.dart';
import 'package:eimunisasi/features/profile/data/repositories/child_repository.dart';
import 'package:eimunisasi/features/profile/logic/blocs/childBloc/child_profile_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'child_profile_bloc_test.mocks.dart';

@GenerateMocks([ChildRepository])
void main() {
  const id = 'id';
  const parentId = 'parentId';
  const name = 'name';
  const placeOfBirth = 'placeOfBirth';
  final dateOfBirth = DateTime(2021, 1, 1);
  const identityNumber = '1111111111111111';
  final bloodType = ListConstant.TYPE_BLOOD[0];
  final genderType = ListConstant.GENDER[0];

  final child = ChildModel(
    id: id,
    parentId: parentId,
    nama: name,
    tempatLahir: placeOfBirth,
    tanggalLahir: dateOfBirth,
    nik: identityNumber,
    golDarah: bloodType,
    jenisKelamin: genderType,
    photoURL: '',
  );

  group("OnInitialEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      'OnInitialEvent',
      build: () => ChildProfileBloc(mockChildRepository),
      act: (bloc) => bloc.add(OnInitialEvent(child: child)),
      expect: () => [
        ChildProfileState(
          child: child,
        )
      ],
    );
  });

  group("OnGetChildrenEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () {
        when(mockChildRepository.getAllChildren())
            .thenAnswer((_) async => [child]);
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(OnGetChildrenEvent()),
      expect: () => [
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.success,
          children: [child],
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed",
      build: () {
        when(mockChildRepository.getAllChildren()).thenThrow(Exception());
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(OnGetChildrenEvent()),
      expect: () => [
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal memuat data anak',
        )
      ],
    );
  });

  group("OnChangeNameEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () => ChildProfileBloc(mockChildRepository)
        ..add(OnInitialEvent(child: child)),
      act: (bloc) => bloc.add(OnChangeNameEvent(name)),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(nama: name),
        )
      ],
    );
  });

  group("OnChangeIdentityNumberEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () => ChildProfileBloc(mockChildRepository)
        ..add(OnInitialEvent(child: child)),
      act: (bloc) => bloc.add(OnChangeIdentityNumberEvent(identityNumber)),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(nik: identityNumber),
        )
      ],
    );
  });

  group("OnChangePlaceOfBirthEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () => ChildProfileBloc(mockChildRepository)
        ..add(OnInitialEvent(child: child)),
      act: (bloc) => bloc.add(OnChangePlaceOfBirthEvent(placeOfBirth)),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(tempatLahir: placeOfBirth),
        )
      ],
    );
  });

  group("OnChangeDateOfBirthEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () => ChildProfileBloc(mockChildRepository)
        ..add(OnInitialEvent(child: child)),
      act: (bloc) => bloc.add(OnChangeDateOfBirthEvent(dateOfBirth)),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(tanggalLahir: dateOfBirth),
        )
      ],
    );
  });

  group("OnChangeGenderEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () => ChildProfileBloc(mockChildRepository)
        ..add(OnInitialEvent(child: child)),
      act: (bloc) => bloc.add(OnChangeGenderEvent(genderType)),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(jenisKelamin: genderType),
        )
      ],
    );
  });

  group("OnChangeBloodTypeEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () => ChildProfileBloc(mockChildRepository)
        ..add(OnInitialEvent(child: child)),
      act: (bloc) => bloc.add(OnChangeBloodTypeEvent(bloodType)),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(golDarah: bloodType),
        )
      ],
    );
  });

  group("OnUpdateChildEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () {
        when(mockChildRepository.updateChild(child))
            .thenAnswer((_) async => child);
        when(mockChildRepository.getAllChildren())
            .thenAnswer((_) async => [child]);
        return ChildProfileBloc(mockChildRepository)
          ..add(OnInitialEvent(child: child));
      },
      act: (bloc) => bloc.add(UpdateProfileEvent()),
      expect: () => [
        ChildProfileState(
          statusUpdate: FormzSubmissionStatus.initial,
          child: child,
        ),
        ChildProfileState(
          child: child,
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child,
          statusUpdate: FormzSubmissionStatus.success,
        ),
        ChildProfileState(
          statusUpdate: FormzSubmissionStatus.initial,
          child: child,
        ),
        ChildProfileState(
          child: child,
          statusGetChildren: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.success,
          children: [child],
          child: child,
        ),
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw default Exception",
      seed: () => ChildProfileState(child: child),
      build: () {
        when(mockChildRepository.updateChild(child)).thenThrow(Exception());
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(UpdateProfileEvent()),
      expect: () => [
        ChildProfileState(
          child: child,
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child,
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal memperbarui profil anak',
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw FormatException when child data is null",
      seed: () => ChildProfileState(child: null),
      build: () {
        when(mockChildRepository.updateChild(child)).thenThrow(
          FormatException('Data anak tidak boleh kosong'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(UpdateProfileEvent()),
      expect: () => [
        ChildProfileState(
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'Data anak tidak boleh kosong',
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw FormatException when name length is invalid",
      build: () {
        when(mockChildRepository.updateChild(child.copyWith(
          nama: 'a', // Invalid name length
        ))).thenThrow(
          FormatException('Panjang nama harus antara 2-128 karakter'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(UpdateProfileEvent()),
      seed: () => ChildProfileState(
        child: child.copyWith(nama: 'a'), // Set initial state with invalid name
      ),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(nama: 'a'),
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child.copyWith(nama: 'a'),
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'Panjang nama harus antara 2-128 karakter',
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw FormatException when date of birth is null",
      build: () {
        when(mockChildRepository.updateChild(child.copyWith(
          tanggalLahir: null, // Invalid date of birth
        ))).thenThrow(
          FormatException('Tanggal lahir tidak boleh kosong'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(UpdateProfileEvent()),
      seed: () => ChildProfileState(
        child: child.copyWith(tanggalLahir: null), // Set initial state with invalid date of birth
      ),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(tanggalLahir: null),
          statusUpdate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child.copyWith(tanggalLahir: null),
          statusUpdate: FormzSubmissionStatus.failure,
          errorMessage: 'Tanggal lahir tidak boleh kosong',
        )
      ],
    );
  });

  group("OnCreateChildEvent", () {
    late ChildRepository mockChildRepository;
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () {
        when(mockChildRepository.setChild(child))
            .thenAnswer((_) async => child);
        when(mockChildRepository.getAllChildren())
            .thenAnswer((_) async => [child]);
        return ChildProfileBloc(mockChildRepository)
          ..add(OnInitialEvent(child: child));
      },
      act: (bloc) => bloc.add(CreateProfileEvent()),
      expect: () => [
        ChildProfileState(
          child: child,
        ),
        ChildProfileState(
          child: child,
          statusCreate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child,
          statusCreate: FormzSubmissionStatus.success,
        ),
        ChildProfileState(
          statusCreate: FormzSubmissionStatus.initial,
          child: child,
        ),
        ChildProfileState(
          child: child,
          statusGetChildren: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.success,
          children: [child],
          child: child,
        ),
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw FormatException when child data is null",
      seed: () => ChildProfileState(child: null),
      build: () {
        when(mockChildRepository.setChild(child)).thenThrow(
          FormatException('Data anak tidak boleh kosong'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(CreateProfileEvent()),
      expect: () => [
        ChildProfileState(
          statusCreate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusCreate: FormzSubmissionStatus.failure,
          errorMessage: 'Data anak tidak boleh kosong',
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw FormatException when name length is invalid",
      build: () {
        when(mockChildRepository.setChild(child.copyWith(
          nama: 'a', // Invalid name length
        ))).thenThrow(
          FormatException('Panjang nama harus antara 2-128 karakter'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(CreateProfileEvent()),
      seed: () => ChildProfileState(
        child: child.copyWith(nama: 'a'), // Set initial state with invalid name
      ),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(nama: 'a'),
          statusCreate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child.copyWith(nama: 'a'),
          statusCreate: FormzSubmissionStatus.failure,
          errorMessage: 'Panjang nama harus antara 2-128 karakter',
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw Exception",
      build: () {
        when(mockChildRepository.setChild(child)).thenThrow(
          Exception('Gagal membuat profil anak'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      seed: () => ChildProfileState(child: child),
      act: (bloc) => bloc.add(CreateProfileEvent()),
      expect: () => [
        ChildProfileState(
          child: child,
          statusCreate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child,
          statusCreate: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal membuat profil anak',
        )
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed throw FormatException when date of birth is null",
      build: () {
        when(mockChildRepository.setChild(child.copyWith(
          tanggalLahir: null, // Invalid date of birth
        ))).thenThrow(
          FormatException('Tanggal lahir tidak boleh kosong'),
        );
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(CreateProfileEvent()),
      seed: () => ChildProfileState(
        child: child.copyWith(tanggalLahir: null), // Set initial state with invalid date of birth
      ),
      expect: () => [
        ChildProfileState(
          child: child.copyWith(tanggalLahir: null),
          statusCreate: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child.copyWith(tanggalLahir: null),
          statusCreate: FormzSubmissionStatus.failure,
          errorMessage: 'Tanggal lahir tidak boleh kosong',
        )
      ],
    );
  });

  group("OnUpdateAvatar", () {
    late ChildRepository mockChildRepository;
    final file = File('test');
    final url = 'url';
    setUp(() {
      mockChildRepository = MockChildRepository();
    });

    blocTest<ChildProfileBloc, ChildProfileState>(
      "success",
      build: () {
        when(mockChildRepository.updateChildAvatar(file: file, id: id))
            .thenAnswer((_) async => url);
        when(mockChildRepository.getAllChildren())
            .thenAnswer((_) async => [child.copyWith(photoURL: url)]);
        return ChildProfileBloc(mockChildRepository)
          ..add(OnInitialEvent(child: child));
      },
      act: (bloc) => bloc.add(UpdateProfilePhotoEvent(photo: file, id: id)),
      expect: () => [
        ChildProfileState(
          child: child,
        ),
        ChildProfileState(
          child: child,
          statusUpdateAvatar: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          child: child.copyWith(photoURL: url),
          statusUpdateAvatar: FormzSubmissionStatus.success,
        ),
        ChildProfileState(
          child: child.copyWith(photoURL: url),
          statusUpdateAvatar: FormzSubmissionStatus.initial,
        ),
        ChildProfileState(
          child: child.copyWith(photoURL: url),
          statusGetChildren: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusGetChildren: FormzSubmissionStatus.success,
          children: [child.copyWith(photoURL: url)],
          child: child.copyWith(photoURL: url),
        ),
      ],
    );

    blocTest<ChildProfileBloc, ChildProfileState>(
      "failed",
      build: () {
        when(mockChildRepository.updateChildAvatar(file: file, id: id))
            .thenThrow(Exception());
        return ChildProfileBloc(mockChildRepository);
      },
      act: (bloc) => bloc.add(UpdateProfilePhotoEvent(photo: file, id: id)),
      expect: () => [
        ChildProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.inProgress,
        ),
        ChildProfileState(
          statusUpdateAvatar: FormzSubmissionStatus.failure,
          errorMessage: 'Gagal memperbarui foto profil anak',
        ),
      ],
    );
  });
}
