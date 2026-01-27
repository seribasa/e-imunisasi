import 'package:eimunisasi/core/extension.dart';
import 'package:eimunisasi/core/widgets/error.dart';
import 'package:eimunisasi/features/profile/presentation/screens/child_profile_screen.dart';
import 'package:eimunisasi/routers/route_paths/profile_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/top_app_bar.dart';
import '../../../../injection.dart';
import '../../data/models/child_model.dart';
import '../../logic/blocs/childBloc/child_profile_bloc.dart';

class ListChildrenScreen extends StatelessWidget {
  final Function(ChildModel?)? onSelected;

  const ListChildrenScreen({
    Key? key,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ChildProfileBloc>()..add(OnGetChildrenEvent()),
      child: Scaffold(
        appBar: AppBarPeltops(title: AppConstant.APP_BAR_CHILD_PROFILE),
        backgroundColor: Colors.pink[100],
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 0,
            child: BlocBuilder<ChildProfileBloc, ChildProfileState>(
              builder: (context, state) {
                if (state.statusGetChildren == FormzSubmissionStatus.failure) {
                  return ErrorContainer(
                    onRefresh: () {
                      context
                          .read<ChildProfileBloc>()
                          .add(OnGetChildrenEvent());
                    },
                  );
                } else if (state.statusGetChildren ==
                    FormzSubmissionStatus.inProgress) {
                  return Center(child: CircularProgressIndicator());
                } else if (state.children == null || state.children!.isEmpty) {
                  return Center(
                    child: Text(
                      'Data anak kosong, silahkan tambahkan anak',
                    ),
                  );
                }
                final data = state.children;
                return ListView.builder(
                  itemCount: data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () {
                          if (onSelected != null) {
                            onSelected!(data?[index]);
                            return;
                          }
                          context.push(
                            ProfileRoutePaths.editChildren.fullPath,
                            extra: {
                              'child': data?[index],
                              'mode': ChildProfileScreenMode.edit,
                              'bloc': context.read<ChildProfileBloc>(),
                            },
                          );
                        },
                        title: Text(
                          data?[index].nama ?? emptyString,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(data?[index].umurAnak ?? emptyString),
                        trailing: Icon(
                          Icons.keyboard_arrow_right_rounded,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<ChildProfileBloc, ChildProfileState>(
          builder: (context, state) {
            return FloatingActionButton(
              child: Icon(
                Icons.add,
                semanticLabel: 'child_profile_add_child_button',
              ),
              onPressed: () {
                context.push(
                  ProfileRoutePaths.addChildren.fullPath,
                  extra: {
                    'bloc': context.read<ChildProfileBloc>(),
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
