import 'package:eimunisasi/core/extension.dart';
import 'package:eimunisasi/core/utils/constant.dart';
import 'package:eimunisasi/core/widgets/button_custom.dart';
import 'package:eimunisasi/core/widgets/image_picker.dart';
import 'package:eimunisasi/core/widgets/spacer.dart';
import 'package:eimunisasi/core/widgets/text_form_custom.dart';
import 'package:eimunisasi/features/profile/data/models/child_model.dart';
import 'package:eimunisasi/features/profile/logic/blocs/childBloc/child_profile_bloc.dart';
import 'package:eimunisasi/core/utils/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/pair.dart';
import '../../../../core/utils/list_constant.dart';
import '../../../../core/utils/themes/padding_constant.dart';
import '../../../../core/widgets/dropdown.dart';
import '../../../../core/widgets/picker.dart';
import '../../../../core/widgets/profile_picture.dart';
import '../../../../core/widgets/snackbar_custom.dart';
import '../../../../core/widgets/text.dart';
import '../../../../core/widgets/top_app_bar.dart';

enum ChildProfileScreenMode { add, edit }

class ChildProfileScreen extends StatelessWidget {
  final ChildProfileScreenMode mode;
  final ChildModel? child;
  const ChildProfileScreen({
    super.key,
    required this.mode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ChildProfileBloc>()
        ..add(
          OnInitialEvent(child: child),
        ),
      child: _ChildProfileScaffold(
        mode: mode,
        child: child,
      ),
    );
  }
}

class _ChildProfileScaffold extends StatelessWidget {
  final ChildProfileScreenMode mode;
  final ChildModel? child;

  const _ChildProfileScaffold({
    required this.mode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildProfileBloc, ChildProfileState>(
      listenWhen: (previous, current) =>
          previous.statusUpdate != current.statusUpdate ||
          previous.statusUpdateAvatar != current.statusUpdateAvatar ||
          previous.statusCreate != current.statusCreate,
      listener: (context, state) {
        if (state.statusUpdate.isFailure) {
          snackbarCustom(
            state.errorMessage ?? 'Gagal menyimpan data',
          ).show(context);
        } else if (state.statusUpdate.isSuccess) {
          context.pop();
          snackbarCustom('Berhasil menyimpan data').show(context);
        } else if (state.statusUpdateAvatar.isFailure) {
          snackbarCustom(
            state.errorMessage ?? 'Gagal mengubah foto',
          ).show(context);
        } else if (state.statusUpdateAvatar.isSuccess) {
          snackbarCustom(
            'Berhasil mengubah foto',
          ).show(context);
        } else if (state.statusCreate.isFailure) {
          snackbarCustom(
            state.errorMessage ?? 'Gagal menyimpan data',
          ).show(context);
        } else if (state.statusCreate.isSuccess) {
          context.pop();
          snackbarCustom(
            'Berhasil menyimpan data',
          ).show(context);
        }
      },
      child: Scaffold(
        appBar: AppBarPeltops(title: AppConstant.APP_BAR_CHILD_PROFILE),
        backgroundColor: Colors.pink[100],
        body: BlocBuilder<ChildProfileBloc, ChildProfileState>(
          builder: (context, state) {
            final bloc = context.read<ChildProfileBloc>();
            return Column(
              children: [
                if (mode == ChildProfileScreenMode.edit) ...[
                  _HeaderChildProfile(child: state.child),
                ],
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.all(AppPadding.paddingM),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.paddingM,
                      ),
                      child: ListView(
                        children: [
                          VerticalSpacer(),
                          TextFormCustom(
                            initialValue: child?.nama ?? emptyString,
                            label: AppConstant.LABEL_FULL_NAME_BY_IDENTITY,
                            onChanged: (name) {
                              bloc.add(OnChangeNameEvent(name));
                            },
                          ),
                          VerticalSpacer(),
                          TextFormCustom(
                            initialValue: child?.nik ?? emptyString,
                            keyboardType: TextInputType.number,
                            label: AppConstant.LABEL_NO_NIK,
                            onChanged: (nik) {
                              bloc.add(OnChangeIdentityNumberEvent(nik));
                            },
                          ),
                          VerticalSpacer(),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormCustom(
                                  initialValue: child?.tempatLahir,
                                  label: AppConstant.LABEL_PLACE_OF_BIRTH,
                                  onChanged: (placeOfBirth) {
                                    bloc.add(
                                      OnChangePlaceOfBirthEvent(placeOfBirth),
                                    );
                                  },
                                ),
                              ),
                              HorizontalSpacer(val: AppPadding.paddingS),
                              Expanded(
                                child: TextFormCustom(
                                  onTap: () async {
                                    final date = await Picker.pickDate(
                                      context,
                                      currentTime: state.child?.tanggalLahir,
                                    );
                                    if (date != null) {
                                      bloc.add(
                                        OnChangeDateOfBirthEvent(date),
                                      );
                                    }
                                  },
                                  readOnly: true,
                                  label: AppConstant.LABEL_DATE_OF_BIRTH,
                                  hintText: () {
                                    if (state.child?.tanggalLahir == null) {
                                      return AppConstant
                                          .LABEL_CHOICE_DATE_OF_BIRTH;
                                    }
                                    return (state.child?.tanggalLahir)
                                        .formattedDate();
                                  }(),
                                ),
                              ),
                            ],
                          ),
                          VerticalSpacer(),
                          DropdownPeltops(
                            label: AppConstant.LABEL_GENDER,
                            initialValue: child?.jenisKelamin ?? emptyString,
                            listItem: Gender.values
                                .map((e) => Pair(e.name, e.value))
                                .toList(),
                            onChanged: (val) {
                              bloc.add(OnChangeGenderEvent(val ?? emptyString));
                            },
                          ),
                          VerticalSpacer(),
                          DropdownPeltops(
                            label: AppConstant.LABEL_BLOOD_TYPE,
                            initialValue: child?.golDarah ?? emptyString,
                            listItem: BloodType.values
                                .map((e) => Pair(e.name, e.name))
                                .toList(),
                            onChanged: (val) {
                              bloc.add(
                                  OnChangeBloodTypeEvent(val ?? emptyString));
                            },
                          ),
                          VerticalSpacer(),
                          VerticalSpacer(),
                          _SaveButton(mode: mode),
                          VerticalSpacer(),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderChildProfile extends StatelessWidget {
  final ChildModel? child;

  const _HeaderChildProfile({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhotoProfile(
              url: child?.photoURL,
              id: child?.id,
            ),
            Text('Umur: ' + (child?.umurAnak ?? emptyString)),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final ChildProfileScreenMode mode;

  const _SaveButton({
    Key? key,
    required this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildProfileBloc, ChildProfileState>(
      builder: (context, state) {
        return ButtonCustom(
          loading: state.statusUpdate.isInProgress ||
              state.statusUpdateAvatar.isInProgress ||
              state.statusCreate.isInProgress,
          child: ButtonText(text: AppConstant.SAVE),
          onPressed: () async {
            dismissKeyboard(context);
            if (mode == ChildProfileScreenMode.add) {
              context.read<ChildProfileBloc>().add(CreateProfileEvent());
              return;
            }
            context.read<ChildProfileBloc>().add(UpdateProfileEvent());
          },
        );
      },
    );
  }
}

class _PhotoProfile extends StatelessWidget {
  final String? id;
  final String? url;

  const _PhotoProfile({Key? key, required this.url, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChildProfileBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.paddingS),
      child: BlocBuilder<ChildProfileBloc, ChildProfileState>(
        buildWhen: (previous, current) {
          return previous.statusUpdateAvatar != current.statusUpdateAvatar;
        },
        builder: (context, state) {
          if (state.statusUpdateAvatar.isInProgress) {
            return const CircularProgressIndicator.adaptive();
          }
          return ProfilePictureFromUrl(
            url: url,
            onPressedCamera: () async {
              ModalPickerImage.showPicker(context, (file) {
                bloc.add(UpdateProfilePhotoEvent(
                  id: id ?? emptyString,
                  photo: file,
                ));
              });
            },
          );
        },
      ),
    );
  }
}
