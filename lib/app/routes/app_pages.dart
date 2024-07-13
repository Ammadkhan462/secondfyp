import 'package:get/get.dart';

import '../modules/CustomAppBar/bindings/custom_app_bar_binding.dart';
import '../modules/CustomAppBar/views/custom_app_bar_view.dart';
import '../modules/DashBoard/bindings/dash_board_binding.dart';
import '../modules/DashBoard/controllers/dash_board_controller.dart';
import '../modules/DashBoard/views/dash_board_view.dart';
import '../modules/Drawer/bindings/drawer_binding.dart';
import '../modules/Drawer/views/drawer_view.dart';
import '../modules/IDGenerator/bindings/i_d_generator_binding.dart';
import '../modules/IDGenerator/idconfirm/bindings/idconfirm_binding.dart';
import '../modules/IDGenerator/idconfirm/views/idconfirm_view.dart';
import '../modules/IDGenerator/views/i_d_generator_view.dart';
import '../modules/MessMenuScreen/bindings/mess_menu_screen_binding.dart';
import '../modules/MessMenuScreen/views/mess_menu_screen_view.dart';
import '../modules/accupancyalloc/bindings/accupancyalloc_binding.dart';
import '../modules/accupancyalloc/views/accupancyalloc_view.dart';
import '../modules/addhostel/bindings/addhostel_binding.dart';
import '../modules/addhostel/views/addhostel_view.dart';
import '../modules/complains/bindings/complains_binding.dart';
import '../modules/complains/views/complains_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/profiledetails/bindings/profiledetails_binding.dart';
import '../modules/profiledetails/controllers/profiledetails_controller.dart';
import '../modules/profiledetails/views/profiledetails_view.dart';
import '../modules/residentdatalist/bindings/residentdatalist_binding.dart';
import '../modules/residentdatalist/views/residentdatalist_view.dart';
import '../modules/signin/bindings/signin_binding.dart';
import '../modules/signin/views/signin_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splashscreen/bindings/splashscreen_binding.dart';
import '../modules/splashscreen/views/splashscreen_view.dart';
import '../modules/verification/bindings/verification_binding.dart';
import '../modules/verification/views/verification_view.dart';
import '../modules/verificationsignin/bindings/verificationsignin_binding.dart';
import '../modules/verificationsignin/views/verificationsignin_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SIGNIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DASH_BOARD,
      page: () => const DashBoardView(),
      binding: DashBoardBinding(),
    ),
    GetPage(
      name: _Paths.DRAWER,
      page: () => const DrawerView(),
      binding: DrawerBinding(),
    ),
    GetPage(
      name: _Paths.I_D_GENERATOR,
      page: () => IDGeneratorView(),
      binding: IDGeneratorBinding(),
      children: [
        GetPage(
          name: _Paths.IDCONFIRM,
          page: () => IdconfirmView(documentId: Get.arguments),
          binding: IdconfirmBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.MESS_MENU_SCREEN,
      page: () => const MessMenuScreenView(),
      binding: MessMenuScreenBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOM_APP_BAR,
      page: () => CustomAppBarView(
        screenTitle: '',
      ),
      binding: CustomAppBarBinding(),
    ),
    GetPage(
      name: _Paths.ADDHOSTEL,
      page: () => const AddHostelDetailsView(),
      binding: AddhostelBinding(),
    ),
    GetPage(
      name: _Paths.ACCUPANCYALLOC,
      page: () => const AccupancyallocView(),
      binding: AccupancyallocBinding(),
    ),
    GetPage(
      name: _Paths.PROFILEDETAILS,
      page: () => const ProfiledetailsView(),
      binding: ProfiledetailsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.COMPLAINS,
      page: () => ComplainsView(),
      binding: ComplainsBinding(),
    ),
    GetPage(
      name: _Paths.RESIDENTDATALIST,
      page: () => const ResidentdatalistView(),
      binding: BindingsBuilder(() => Get.lazyPut<ProfiledetailsController>(
          () => ProfiledetailsController())),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.SIGNIN,
      page: () => SignInView(),
      binding: SigninBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION,
      page: () => VerificationView(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATIONSIGNIN,
      page: () => VerificationsigninView(),
      binding: VerificationsigninBinding(),
    ),
  ];
}
