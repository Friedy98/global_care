import 'package:get/get.dart' show GetPage, Transition;
import '../modules/add_ravel_form/Views/add_travel_form.dart';
import '../modules/add_ravel_form/binding/add_travel_binding.dart';
import '../modules/fidelisation/binding/validation_Biding.dart';
import '../modules/fidelisation/views/attribute_points.dart';
import '../modules/home/views/employee_home.dart';
import '../modules/home/widgets/contact_view.dart';
import '../modules/home/widgets/fidelity_card_view.dart';
import '../modules/identity_files/Views/attachment_list.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/auth/views/verification_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/categories_view.dart';
import '../modules/e_service/bindings/e_service_binding.dart';
import '../modules/e_service/views/e_service_view.dart';
import '../modules/help_privacy/bindings/help_privacy_binding.dart';
import '../modules/help_privacy/views/help_view.dart';
import '../modules/help_privacy/views/privacy_view.dart';
import '../modules/identity_files/Views/import_identity_files_form.dart';
import '../modules/identity_files/binding/import_identity_files_binding.dart';
import '../modules/messages/binding/message_binding.dart';
import '../modules/messages/views/chats_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notification_details.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/rating/bindings/rating_binding.dart';
import '../modules/rating/views/rating_view.dart';
import '../modules/root/bindings/root_binding.dart';
import '../modules/root/views/root_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/address_picker_view.dart';
import '../modules/settings/views/addresses_view.dart';
import '../modules/settings/views/language_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/views/theme_mode_view.dart';
import '../modules/travel_inspect/bindings/travel_inspect_binding.dart';
import '../modules/travel_inspect/views/add_shipping_form.dart';
import '../modules/travel_inspect/views/travel_inspect_view.dart';
import '../modules/userBookings/views/bookings_view.dart';
import '../modules/userBookings/views/facturation.dart';
import '../modules/userBookings/views/interface_POS.dart';
import 'app_routes.dart';

class Theme1AppPages {
  static const INITIAL = Routes.SPLASH_VIEW;

  static final routes = [
    GetPage(name: Routes.SPLASH_VIEW, page: () => SplashView(), binding: AuthBinding()),
    GetPage(name: Routes.ROOT, page: () => RootView(), binding: RootBinding()),
    GetPage(name: Routes.RATING, page: () => RatingView(), binding: RatingBinding()),
    GetPage(name: Routes.CHAT, page: () => ChatsView(), binding: MessageBinding()),
    GetPage(name: Routes.SETTINGS, page: () => SettingsView(), binding: SettingsBinding()),
    GetPage(name: Routes.SETTINGS_ADDRESSES, page: () => AddressesView(), binding: SettingsBinding()),
    GetPage(name: Routes.SETTINGS_THEME_MODE, page: () => ThemeModeView(), binding: SettingsBinding()),
    GetPage(name: Routes.ADD_TRAVEL_FORM, page: () => AddTravelsView(), binding: AddTravelBinding(), transition: Transition.fadeIn),
    GetPage(name: Routes.ADD_SHIPPING_FORM, page: () => AddShippingView(), binding: TravelInspectBinding(), transition: Transition.upToDown),
    GetPage(name: Routes.IDENTITY_FILES, page: () => AttachmentView(), binding: ImportIdentityFilesBinding()),
    GetPage(name: Routes.ADD_IDENTITY_FILES, page: () => ImportIdentityFilesView(), binding: ImportIdentityFilesBinding()),
    GetPage(name: Routes.SETTINGS_LANGUAGE, page: () => LanguageView(), binding: SettingsBinding()),
    GetPage(name: Routes.SETTINGS_ADDRESS_PICKER, page: () => AddressPickerView()),
    GetPage(name: Routes.TRAVEL_INSPECT, page: () => TravelInspectView(), binding: TravelInspectBinding()),

    GetPage(name: Routes.CONTACT, page: () => ContactWidget(), transition: Transition.fadeIn),
    GetPage(name: Routes.INTERFACE_POS, page: () => InterfacePOSView(), transition: Transition.fadeIn),
    GetPage(name: Routes.EMPLOYEE_HOME, page: () => EmployeeHomeView(), transition: Transition.fadeIn),
    GetPage(name: Routes.APPOINTMENT_BOOK, page: () => BookingsView(), transition: Transition.fadeIn),
    GetPage(name: Routes.FIDELITY_CARD, page: () => FidelityCardWidget(),transition: Transition.fadeIn),
    GetPage(name: Routes.FACTURATION, page: () => EmployeeReceipt(),transition: Transition.fadeIn),

    GetPage(name: Routes.PROFILE, page: () => ProfileView(), binding: ProfileBinding(), transition: Transition.fadeIn),
    GetPage(name: Routes.CATEGORIES, page: () => CategoriesView(), binding: CategoryBinding(), transition: Transition.fadeIn),
    GetPage(name: Routes.VALIDATE_TRANSACTION, page: () => AttributionView(), binding: ValidationBinding()),
    GetPage(name: Routes.LOGIN, page: () => LoginView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.REGISTER, page: () => RegisterView(), binding: AuthBinding(), transition: Transition.zoom),
    GetPage(name: Routes.FORGOT_PASSWORD, page: () => ForgotPasswordView(), binding: AuthBinding()),
    GetPage(name: Routes.VERIFICATION, page: () => VerificationView(), binding: AuthBinding()),
    GetPage(name: Routes.E_SERVICE, page: () => EServiceView(), binding: EServiceBinding(), transition: Transition.downToUp),
    GetPage(name: Routes.PRIVACY, page: () => PrivacyView(), binding: HelpPrivacyBinding()),
    GetPage(name: Routes.HELP, page: () => HelpView(), binding: HelpPrivacyBinding()),
    //GetPage(name: Routes.GALLERY, page: () => GalleryView(), binding: GalleryBinding(), transition: Transition.fadeIn),
    GetPage(name: Routes.NOTIFICATIONS, page: () => NotificationsView(), binding: NotificationsBinding(), transition: Transition.fadeIn),
    GetPage(name: Routes.NOTIFICATION_DETAIL, page: () => NotificationDetailsView(), binding: NotificationsBinding(), transition: Transition.fadeIn),
    //GetPage(name: Routes.WALLETS, page: () => WalletsView(), binding: WalletsBinding(), middlewares: [AuthMiddleware()]),
    //GetPage(name: Routes.WALLET_FORM, page: () => WalletFormView(), binding: WalletsBinding(), middlewares: [AuthMiddleware()]),
  ];
}
