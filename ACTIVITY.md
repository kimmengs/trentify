# ⚜️ Trentify — Project Activity & Progress Tracker

> **Maison Trentify**: High-End Luxury E-Commerce iOS Mobile Application built with Flutter & Apple Metal Impeller GPU Backend.

---

## 📊 Project Overview & Tech Stack

- **Framework**: Flutter 3.28+ / Dart 3.7+
- **Architecture**: Dual-Engine (Cupertino iOS UI Shell + Material 3 Adaptive Theming)
- **State Management**: `Provider` (`CartProvider`, `ProductRepository`, `ThemeController`, `LocaleController`)
- **Navigation**: `GoRouter` with custom iOS slide-up, slide-right, and cross-fade page transitions
- **Localization**: 3-Language Natural Localization (`English [en]`, `Khmer [km]`, `Vietnamese [vi]`)
- **Graphics & Styling Engine**: Real-time GPU Frosted Glass Refraction (`LiquidGlassCard`), Specular Rim Lighting, and Tactile Haptics (`AppHaptics`)
- **Target Platforms**: iOS (Physical iPhone & Simulator), macOS, Web

---

## 🎨 Reusable Design System (`lib/widgets/`)

| Component | File | Description |
| :--- | :--- | :--- |
| **`LiquidGlassCard`** | [`liquid_glass_card.dart`](lib/widgets/liquid_glass_card.dart) | iOS Glassmorphism container with backdrop blur, specular border, and light/dark theme adaptation. |
| **`AppBadgePill`** | [`app_badge_pill.dart`](lib/widgets/app_badge_pill.dart) | Universal luxury status badge with 7 semantic variants (`primary`, `success`, `warning`, `error`, `neutral`, `vip`, `glass`). |
| **`AppPriceText`** | [`app_price_text.dart`](lib/widgets/app_price_text.dart) | Formatted currency display with optional discount strikethrough. |
| **`AppNetworkImage`** | [`app_network_image.dart`](lib/widgets/app_network_image.dart) | Resilient network image component with error fallbacks and smooth caching. |
| **`AppStepIndicator`** | [`app_step_indicator.dart`](lib/widgets/app_step_indicator.dart) | Multi-step progress tracker for checkout and onboarding flows. |
| **`AppHaptics`** | [`app_haptics.dart`](lib/widgets/app_haptics.dart) | Centralized tactile sensory feedback profiles (`light`, `medium`, `heavy`, `selection`, `success`, `error`). |
| **`PressableScale`** | [`pressable_scale.dart`](lib/widgets/pressable_scale.dart) | Micro-interaction spring-scaling wrapper for interactive tiles and buttons. |
| **`AnimatedEntry`** | [`animated_entry.dart`](lib/widgets/animated_entry.dart) | Staggered fade and slide entrance animation for list and screen items. |

---

## 🗓️ Chronological Activity & Changelog

### 1. Product Detail & "Add to Bag" Fix
- **Issue**: Tapping "Add to Bag" on the product detail page did not increment the cart item count or reflect in the global cart state.
- **Solution**: Connected the product detail action button to `CartProvider.instance.addToCart()`, added size/color parameter resolution, and implemented floating confirmation snackbar with tactile feedback.
- **Tests**: Created `test/product_detail_bag_test.dart`.

### 2. 3D iOS App Icon & Branding
- **Design**: Generated a luxury 3D isometric monogram app icon with frosted gold accents and obsidian leather textures.
- **Assets**: Replaced iOS icon assets in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

### 3. Modern Luxury Login Screen Redesign
- **Design**: Built an iOS porcelain/obsidian luxury login with animated logo halo, 1-tap VIP quick-access button, password visibility toggle, biometric prompt, and language switcher modal.
- **Localization**: Full 3-language translations (`en`, `km`, `vi`).

### 4. "My Orders" Screen Redesign & Tab Deduplication
- **Refinement**: Removed redundant top metrics strip and double tab bar headers.
- **Design**: Single segmented control pill (`Active (2)`, `Completed (1)`, `Canceled (1)`), interactive live delivery tracking sheet with DHL step progression, and 1-tap reorder flows.
- **Tests**: Created `test/my_order_test.dart`.

### 5. Shopping Bag / Cart Screen Redesign
- **Design**: VIP Free Shipping Progress bar with animated completion status, item quantity increment/decrement steppers, item selection toggles, promo voucher sheet, and sticky checkout footer.
- **Tests**: Added cart provider and state test coverage.

### 6. Wishlist Screen Redesign
- **Design**: Dual layout mode switcher (`2-Column Grid` vs `Detailed List View`), real-time search query filtering, category pills, swipe-to-remove, and 1-tap "Move All to Bag" action.
- **Tests**: Created `test/wishlist_test.dart`.

### 7. Checkout Screen Redesign
- **Design**: 3-step order progression tracker (`Bag` → `Checkout` → `Delivery`), SSL 256-bit padlock badge, address selector card (`AddressPickerPage`), DHL express courier options, collapsible order summary, and luxury processing & confirmation modal.
- **Tests**: Created `test/checkout_page_test.dart`.

### 8. Chat with Seller Feature & Storage Architecture
- **Design**: Interactive inquiry chat screen (`ProductChatPage`) with pinned product summary preview, quick suggestion chips, message bubbles, and real-time message state.
- **Architecture**: Documented single source of truth database structure (`chats/{chatId}` and `chats/{chatId}/messages/{messageId}`), local caching strategies (SQLite / Drift / SharedPreferences), and cloud sync via WebSockets / APNs push notifications.
- **Tests**: Created `test/chat_with_seller_test.dart`.

### 9. Notification Screen Redesign
- **Design**: Horizontal category filter pills (`All (6)`, `Orders (2)`, `Promos (2)`, `System (2)`), gradient glow squircle badges with unread indicator dots, relative time formatting (`5m ago`, `2h ago`), and contextual action buttons (`Track Shipment →`, `View Order`).
- **Tests**: Created `test/notification_page_test.dart`.

### 10. Liquid Glass Navigation & Account Screen (`MorePage`)
- **Navigation**: High-blur (`sigma: 32`) floating bottom navigation bar with specular rim borders and active liquid gradient capsule.
- **Account Screen**: Frosted glass profile hero card with VIP halo avatar, quick stats row (`Active Orders`, `Bag`, `Wishlist`), Shop Owner Portal card, grouped settings tiles with gradient icon badges, and liquid language picker modal.
- **Tests**: Created `test/more_page_test.dart`.

### 11. Senior Code Review & Design System Component Extraction
- **Code Quality**: Scanned the entire codebase, eliminated duplicate layout code, extracted 6 core design system components into `lib/widgets/`, and ensured strict zero-compiler-warning standards.
- **Tests**: Created `test/design_system_test.dart`.

### 12. Edit Profile Screen & Route Fix
- **Fix**: Resolved issue where tapping the pencil icon in `MorePage` redirected to `/home` due to an unregistered route.
- **Design**: Built dedicated `EditProfilePage` with VIP avatar editor, iOS photo picker sheet (`Camera` / `Library`), verified VIP Elite badge, validated personal info form (`Name`, `Username`, `Email`, `Phone`, `Gender`), and save confirmation toast.
- **Routing**: Added `AppRoutes.editProfile` (`/profile/edit`) to `app_routes.dart` and registered `GoRoute` in `app_router.dart`.
- **Tests**: Created `test/edit_profile_test.dart`.

### 13. Theme & Appearance Studio Redesign
- **Design**: Interactive live iPhone preview mockup card that updates dynamically in real-time.
- **Theme Modes**: 3 large visual selector cards:
  - ☀️ **Light Studio White**
  - 🌙 **Dark Obsidian Noir**
  - 📱 **System Auto-Match**
- **Haute Couture Palettes**: 6 luxury accent palettes with gradient rings, hex codes, and active badges:
  - 🔷 Imperial Sapphire (`#4F77FE`)
  - 🟢 Emerald Velvet (`#10B981`)
  - 🌸 Rose Gold Couture (`#EC4899`)
  - 🟣 Royal Amethyst (`#8B5CF6`)
  - 🟡 Champagne Amber (`#F59E0B`)
  - 🩵 Cyber Cyan (`#06B6D4`)
- **Engine Switches**: Toggles for real-time GPU frosted glass refraction and tactile haptic feedback.
- **Tests**: Created `test/theme_settings_test.dart`.

### 14. Dark Theme Active Colors & High-Contrast Visual Fixes
- **Root Cause**: Material 3 desaturated seed generation caused active elements in Dark mode to appear washed-out or misaligned with the selected accent palette.
- **Fix**: Upgraded `buildMaterialTheme` and `buildCupertinoTheme` with explicit `primaryColor`, unified `#090D14` obsidian background, high-contrast `#CBD5E1` text on dark surfaces, and glowing active shadows on all buttons, tabs, pills, and badges.

### 15. Physical Device & Simulator Deployment
- **Simulator**: Verified live on **iPhone 17 Pro** (iOS 26.5).
- **Physical Device**: Verified, signed (`Apple Development: Kimmeng Soueng`), and run in both **Debug** and **Profile (AOT Compiled • 120Hz ProMotion)** modes on **iPhone Kimmeng** (iOS 26.4.1) with Metal Impeller GPU backend.

### 16. App Rebranding to "WeBuy UAT"
- **App Display Name**: Updated `CFBundleDisplayName` in `ios/Runner/Info.plist` and `android:label` in `AndroidManifest.xml` to **"WeBuy UAT"**.
- **Branding & Localization**: Updated localized brand strings across `English`, `Khmer`, and `Vietnamese` in `lib/l10n/app_localizations.dart` and Theme Studio preview.

---

### 17. High-Definition Client Showcase Video (Autonomous Director)
- **File**: [`webuy_uat_demo_showcase.mp4`](webuy_uat_demo_showcase.mp4) (36 MB, 1206x2622 Native Retina Resolution, 85s Duration).
- **Execution Script**: [`record_showcase.sh`](record_showcase.sh) + [`lib/demo_showcase.dart`](lib/demo_showcase.dart).
- **Features Captured**:
  1. `🔐 VIP AUTHENTICATION • 1-TAP ACCESS` (Modern luxury login & brand halo)
  2. `🛍️ BUYER HUB • LIQUID GLASS FEED` (Home feed with floating glass nav bar)
  3. `💎 HAUTE COUTURE • PRODUCT SHOWCASE` (Product details, photos & ratings)
  4. `💬 DIRECT CONCIERGE • CHAT WITH SELLER` (Live inquiry chat with pinned product card)
  5. `❤️ CURATED WISHLIST • DUAL LAYOUT` (Grid and detailed list layout switcher)
  6. `👜 SHOPPING BAG • VIP SHIPPING TRACKER` (Free shipping tracker & vouchers)
  7. `💳 3-STEP CHECKOUT • DHL PRIORITY` (Address, payment, and DHL Express courier)
  8. `📦 ORDER MANAGEMENT • LIVE DHL TRACKING` (Active orders & live delivery steps)
  9. `🏪 SELLER CENTER • REVENUE & ESCROW` (Analytics charts, inventory & payouts)
  10. `👤 VIP ELITE PROFILE & MEMBERSHIP` (VIP tier badge & verified profile editor)
  11. `🎨 THEME STUDIO • DARK OBSIDIAN NOIR` (Live mockup preview, Dark mode & palettes)
  12. `✨ FINALE • MAISON LUXURY MARKETPLACE` (Live home feed in Dark Obsidian)

---

## 🧪 Test Suite & Code Quality Metrics

- **Static Analyzer**: `flutter analyze` — **0 issues found** (100% clean).
- **Automated Tests**: `flutter test` — **44 / 44 test suites passing (100% pass rate)**.

---

## 🚀 Current Status & Next Steps

| Milestone | Status | Details |
| :--- | :---: | :--- |
| **All Core Screen Redesigns** | ✅ Complete | Home, Product Detail, Cart, Checkout, Wishlist, Orders, Notifications, Profile, Theme Studio |
| **Design System Extraction** | ✅ Complete | Reusable components established in `lib/widgets/` |
| **3-Language Localization** | ✅ Complete | English, Khmer, Vietnamese |
| **Dark Theme Color System** | ✅ Complete | High-contrast obsidian background & glowing active states |
| **Physical Device Verification** | ✅ Complete | Tested live on iPhone Kimmeng with Metal Impeller |
| **App Name Rebranding** | ✅ Complete | Updated to **WeBuy UAT** on iOS & Android |
| **Project Tracking (`ACTIVITY.md`)** | ✅ Complete | Fully documented project progress and architecture |
| **Client Demo Video Recording** | ✅ Complete | Output saved to `webuy_uat_demo_showcase.mp4` |

---

*Last Updated: 2026-08-30 by Senior Mobile Engineering Team*
