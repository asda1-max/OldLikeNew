import 'package:get/get.dart';

import '../modules/auction_detail/bindings/auction_detail_binding.dart';
import '../modules/auction_detail/views/auction_detail_view.dart';
import '../modules/auctions/bindings/auctions_binding.dart';
import '../modules/auctions/views/auctions_view.dart';
import '../modules/auth/login/bindings/auth_login_binding.dart';
import '../modules/auth/login/views/auth_login_view.dart';
import '../modules/auth/register/bindings/auth_register_binding.dart';
import '../modules/auth/register/views/auth_register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/sell/bindings/sell_binding.dart';
import '../modules/sell/views/sell_view.dart';
import '../modules/transactions/bindings/transactions_binding.dart';
import '../modules/transactions/views/transactions_view.dart';
import '../modules/my_items/bindings/my_items_binding.dart';
import '../modules/my_items/views/my_items_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final INITIAL = Routes.AUTH_REGISTER;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTHREGISTER,
      page: () => const AuthRegisterView(),
      binding: AuthRegisterBinding(),
    ),
    GetPage(
      name: _Paths.AUTH + _Paths.AUTH_REGISTER,
      page: () => const AuthRegisterView(),
      binding: AuthRegisterBinding(),
    ),
    GetPage(
      name: _Paths.AUTH + _Paths.AUTH_LOGIN,
      page: () => const AuthLoginView(),
      binding: AuthLoginBinding(),
    ),
    GetPage(
      name: _Paths.AUCTIONS,
      page: () => const AuctionsView(),
      binding: AuctionsBinding(),
    ),
    GetPage(
      name: _Paths.SELL,
      page: () => const SellView(),
      binding: SellBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.TRANSACTIONS,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: _Paths.AUCTION_DETAIL,
      page: () => const AuctionDetailView(),
      binding: AuctionDetailBinding(),
    ),
    GetPage(
      name: _Paths.MY_ITEMS,
      page: () => const MyItemsView(),
      binding: MyItemsBinding(),
    ),
  ];
}
