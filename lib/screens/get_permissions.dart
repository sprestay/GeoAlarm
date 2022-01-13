import 'package:flutter/material.dart';
import 'package:geoalarm/styles/fonts.dart';
import '../styles/info_messages.dart';
import '../widgets/MainButton.dart';
import 'package:permission_handler/permission_handler.dart';
import '../service/globals.dart' as globals;
import 'package:android_intent/android_intent.dart';
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GetPermissionsPage extends StatefulWidget {
  const GetPermissionsPage({Key? key}) : super(key: key);

  @override
  _GetPermissionsPageState createState() => _GetPermissionsPageState();
}

class _GetPermissionsPageState extends State<GetPermissionsPage>
    with WidgetsBindingObserver {
  bool secondStep = false;
  bool isGranted = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late AppLifecycleState _notification;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    /// Вызов логики, когда завершится render
    // SchedulerBinding.instance?.addPostFrameCallback((_) {
    //   if (isGranted) Navigator.of(context).pushNamed("/main");
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void _onRefresh() async {
    if (await Permission.locationAlways.isGranted) {
      Navigator.pushNamed(context, '/main');
    }
    _refreshController.refreshCompleted();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await Permission.locationAlways.isGranted) {
        // Navigator.pushNamed(context, '/main');
        Restart.restartApp();
      }
    }
  }

  /// По умолчанию статус denied. shouldShowRequestRationale работает крайне непредсказуемо,
  /// совершенно не понятно, будет показан дефолтный запрос или нет
  ///
  /// shouldShowRequestRationale при первом запуске false, после обновления разрешений вручную - true

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: _onRefresh,
      child: Scaffold(
        body: Center(
          child: Container(
            width:
                MediaQuery.of(context).size.width * globals.most_element_width,
            child: Text(
              secondStep ? 
                AppLocalizations.of(context)!.geolocation_denied_on_permission_page.replaceAll(RegExp(r'\s'), " ").trim()
              :
                AppLocalizations.of(context)!.geolocation_is_needed.replaceAll(RegExp(r'\s'), " ").trim(),
              style: AppFontStyle.inter_regular_16_black,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        floatingActionButton: MainButton(
          text: secondStep ? 
            AppLocalizations.of(context)!.give_full_access
          : 
            AppLocalizations.of(context)!.go_to_settings,
          callback: () async {
            if (await Permission.locationAlways.request().isGranted) {
              // Navigator.pushNamed(context, '/main');
              Restart.restartApp();
            } else {
              setState(() {
                secondStep = true;
              });
              AndroidIntent intent = AndroidIntent(
                action: "android.settings.APPLICATION_DETAILS_SETTINGS",
                package: "com.example.geoalarm",
                data: "package:com.example.geoalarm",
              );
              intent.launch();
            }
          },
        ),
      ),
    );
  }
}
