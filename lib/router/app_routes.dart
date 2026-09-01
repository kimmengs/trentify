class AppRoutes {
  static const onboarding = '/';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const home = '/home';
  static const category = '/category/:name';
  static const productDetail = '/product/detail/:id';
  static const productChat = '/product/chat';
  static const notification = '/notification';
  static const search = '/search';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const addressPicker = '/address-picker';
  static const addressForm = '/address/form';
  static const paymentPicker = '/payment-picker';
  static const promoPicker = '/promo-picker';
  static const myOrders = '/my-orders';
  static const theme = '/settings/theme';
  static const language = '/settings/language';
  static const editProfile = '/profile/edit';

  // Seller & Shop Owner Routes
  static const seller = '/seller';
  static const sellerNewProduct = '/seller/products/new';
  static const sellerEditProduct = '/seller/products/edit/:id';
  static const sellerPayouts = '/seller/payouts';
}
