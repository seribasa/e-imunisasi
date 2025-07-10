import 'package:eimunisasi/core/utils/assets_constant.dart';
import 'package:eimunisasi/core/utils/constant.dart';
import 'package:eimunisasi/core/utils/themes/padding_constant.dart';
import 'package:eimunisasi/core/widgets/spacer.dart';
import 'package:eimunisasi/core/widgets/text.dart';
import 'package:eimunisasi/core/widgets/top_app_bar.dart';
import 'package:eimunisasi/routers/route_paths/root_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/themes/shape.dart';
import '../../../../core/widgets/button_custom.dart';
import '../../../authentication/logic/bloc/authentication_bloc/authentication_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPeltops(title: 'Profil'),
      body: Container(
        color: Colors.pink[100],
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Shape.roundedM,
                ),
                padding: const EdgeInsets.all(AppPadding.paddingL),
                child: SvgPicture.asset(AppAssets.PROFILE_ILUSTRATION),
              ),
              VerticalSpacer(),
              Card(
                color: Colors.white,
                elevation: 0,
                child: ListTile(
                  shape: Shape.roundedRectangleM,
                  onTap: () => context.push(RootRoutePaths.profile.fullPath),
                  title: LabelText(text: 'Profil'),
                  trailing: Icon(Icons.keyboard_arrow_right_rounded),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            ButtonCustom(
              onPressed: () => context.pop(),
              child: const ButtonText(text: AppConstant.CANCEL),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.pop();
                  context.read<AuthenticationBloc>().add(LoggedOut());
                },
                child: Text(
                  AppConstant.LOGOUT_LABEL,
                  style: TextStyle(color: Colors.pink[400]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor,
      child: ListTile(
        onTap: () => _showLogoutDialog(context),
        title: LabelText(
          text: AppConstant.LOGOUT_LABEL,
          color: Colors.white,
        ),
        trailing: Icon(
          Icons.logout,
          color: Colors.white,
        ),
      ),
    );
  }
}
