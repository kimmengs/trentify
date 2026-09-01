# ⚜️ Trentify — Project Activity & Progress Tracker

> **Maison Trentify**: High-End Luxury E-Commerce iOS Mobile Application built with Flutter & Apple Metal Impeller GPU Backend.

---

## 📊 Project Overview & Tech Stack

- **Framework**: Flutter 3.28+ / Dart 3.7+
- **Architecture**: Dual-Engine (Cupertino iOS UI Shell + Material 3 Adaptive Theming)
- **State Management**: `Provider` (`AddressProvider`, `CartProvider`, `WishlistProvider`, `OrderProvider`, `SellerProvider`, `ThemeController`, `LocaleController`)
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
| **`CategoryPillsWidget`** | [`category_pill_widget.dart`](lib/screens/home/widget/category_pill_widget.dart) | Horizontally scrollable capsule filter selector with centered typography, spring touch feedback, and zero-clipping vertical layout. |
| **`LuxurySortFilterBar`** | [`sort_filter_widget.dart`](lib/widgets/sort_filter/sort_filter_widget.dart) | Ultra-clean floating frosted glass capsule bar with centered layout, live active filter badges, active sort indicator dots, and 1-tap quick reset action. |
| **`LuxurySortSheet`** | [`luxury_sort_sheet.dart`](lib/widgets/sort_filter/luxury_sort_sheet.dart) | High-end frosted glass sorting modal with descriptive subheadings & active rings. |
| **`LuxuryFilterSheet`** | [`luxury_filter_sheet.dart`](lib/widgets/sort_filter/luxury_filter_sheet.dart) | Comprehensive filter modal with category chips, price sliders, presets, ratings, sizes, and color palettes. |

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
- **Code Quality**: Scanned the entire codebase, eliminated duplicate layout code, extracted core design system components into `lib/widgets/`, and ensured strict zero-compiler-warning standards.
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

### 17. High-Definition Client Showcase Video (Autonomous Director)
- **File**: [`webuy_uat_demo_showcase.mp4`](webuy_uat_demo_showcase.mp4) (36 MB, 1206x2622 Native Retina Resolution, 85s Duration).
- **Execution Script**: [`record_showcase.sh`](record_showcase.sh) + [`lib/demo_showcase.dart`](lib/demo_showcase.dart).

---

### 18. Interactive Real-Time Search Hub (`/search`)
- **Real-Time Filtering**: Dynamic search query filtering across catalog titles, categories, and tags with animated result grids.
- **Search History**: Recent searches tags with individual cross button removal and "Clear All" action.
- **Trending Searches**: Luxury fashion search chips with flame icons.
- **Category Filter Tabs**: Quick filtering across All, Clothing, Shoes, Bags, and Haute Couture.
- **Global Wiring**: Connected to Home search bar, top header search icon, and Category screen search buttons.
- **Tests**: Created `test/search_page_test.dart`.

### 19. Sizing & Fit Guide Modal (`SizingGuideSheet`)
- **Unit Switcher**: Instant unit conversion between **CM** and **INCH**.
- **Smart Fit AI Recommender**: Interactive height and weight sliders calculating recommended size in real-time.
- **Fit Preference Selector**: Options for *Slim Fit*, *Regular Fit*, and *Oversized*.
- **Garment Dimensions Table**: Clean structured size breakdown with dynamic unit values.
- **Trigger**: Connected directly to the "Size Guide" action on the Product Detail Page.

### 20. Customer Write Review & 5-Star Rating Modal (`WriteReviewSheet`)
- **Interactive Review Flow**: 1–5 star rating picker, fit feedback tags (*Runs Small*, *True to Size*, *Runs Large*), multi-line review text input, and photo attachments.
- **VIP Gamification**: Automatic reward of **+50 VIP Points** upon submission.
- **Live PDP Reviews Insertion**: Submitted reviews are dynamically prepended to the customer reviews section with author badge and timestamp.

### 21. 1-Tap Direct Checkout ("Buy Now")
- **Dual Action Bottom Bar**: Clean layout pairing ghost "Add to Bag" and primary gradient "Buy Now" CTA buttons.
- **Direct Order Initialization**: Bypasses the shopping bag screen to initialize checkout immediately with the selected variant (size, color, quantity).

### 22. VIP Haute Club & Loyalty Rewards Hub (`VipRewardsSheet`)
- **VIP Gold Card**: Live points balance display (**2,450 pts ≈ \$24.50 Credit**) and tier progression bar toward *Royal Black*.
- **Elite Privileges**: Free DHL Express priority courier, 24/7 private concierge, private runway early drops, and birthday gift voucher.
- **Referral Invitation Code**: Custom code `TRENTIFY-VIP-ALEX` with 1-tap clipboard copy and native iOS social share dialog (`SharePlus`).
- **Entry Points**: Accessible from profile hero card badge and settings menu in `MorePage`.

### 23. Dynamic Order Lifecycle Management (`OrderProvider`)
- **Checkout-to-Order Flow**: Completing checkout creates an order in `OrderProvider` and clears the purchased items from `CartProvider`.
- **Order Operations**: Supports dynamic order cancellation with confirmation sheet, 1-tap reordering back into cart, and "Rate & Review" on completed orders.

### 24. Global Wishlist State Sync (`WishlistProvider`)
- **Live Heart Toggle**: Synchronized across Home and Category product cards and PDP AppBar favorite button.
- **Wishlist Hub Actions**: Batch "Move All to Bag", single-item transfer, and dynamic removal.

### 25. Luxury Sort & Filter Architecture & UI/UX Redesign
- **Redesign Rationale**: Upgraded previously basic action sheet and static dialog to a luxury frosted glass modal system that performs real-time reactive filtering and sorting.
- **`LuxurySortSheet`**: 7 rich sorting choices (*Curated For You*, *Popularity & Trending*, *Top Customer Rated*, *Price Low-to-High*, *Price High-to-Low*, *Newest Arrivals*, *Special Privileges*) featuring semantic icon badges, descriptive subtitles, and active checkmark rings.
- **`LuxuryFilterSheet`**: Interactive filter sheet featuring category tags, real-time dual-thumb price range slider + quick presets (*Under \$100*, *\$100–\$250*, *\$250–\$500*, *\$500+ Luxury*), 5-star customer rating pills, size grid selectors (*XS–XXL*), and circular color swatches with glow indicators.
- **`LuxurySortFilterBar`**: Floating frosted capsule bar with active filter badge counters and current sort status indicators.
- **Real-Time Reactive State**: Integrated directly into both `WishListPage` and `CategoryPage` so products sort and filter dynamically in memory.
- **Tests**: Created `test/luxury_sort_filter_test.dart`.

---

### 26. Expanded Luxury Product Catalog & Dynamic Category Filtering
- **Rich 30+ Product Catalog**: Populated `DemoDb.allProducts` with realistic high-resolution fashion products across 8 major categories: **Women, Men, Shoes, Bags, Luxury / Haute Couture, Kids, Sports, Beauty**.
- **Dynamic Category Filtering on Home**: Tapping any Category tab on the Home Screen (*Women, Men, Shoes, Bags, Luxury, Kids*) dynamically switches to a filtered 2-column grid of curated pieces with animated entry and pieces count header.
- **Dynamic Product Detail Routing**: Product cards pass `product.effectiveId` to dynamically load specific images, titles, pricing, and reviews.
- **Tests**: Created `test/home_category_filter_test.dart`.

---

### 27. Category Screen & Sort/Filter Button Modernization Redesign
- **Category Top Bar Redesign**: Frosted glass iOS header with circular frosted back button, centered category title & subtitle, circular search shortcut button, and **2-Column Grid vs 1-Column High-Detail Editorial View mode switcher** (`CupertinoIcons.square_grid_2x2` / `CupertinoIcons.rectangle_grid_1x2`).
- **Category Hero Spotlight Card**: Curated collection banner with brand tagline (*"MAISON TRENTIFY"*, *"Elevated Silhouettes & Pure Silk"*) and live available piece counter badge.
- **Subcategory Quick Filter Chips**: Dynamic horizontal chips tailored per category (*All Pieces, Dresses, Knitwear, Trench Coats, Blazers, Skirts*) for instant 1-tap filtering.
- **Redesigned Modern Floating Sort & Filter Capsule (`LuxurySortFilterBar`)**:
  - Centered floating frosted capsule with backdrop blur (`sigma: 24`) and specular border.
  - Ultra-clean modern **Sort** button with active dot indicator.
  - Vibrant **Filter** button with active counter badge.
  - **1-Tap Quick Reset** button (`x`) that appears when filters or sorts are modified.
- **Empty State**: Refined illustration with clear explanation and a single-tap "Reset All Filters" CTA.

---

### 28. Wishlist Category Pills Text Clipping Fix
- **Root Cause**: In `WishListPage`, `CategoryPillsWidget` was bounded within a restrictive `SizedBox(height: 48)`. With inner `ListView` padding (`vertical: 8`) plus container padding (`vertical: 10`), the remaining vertical space was only `10px`, which clipped the bottom descenders of letters in `"All Items"`, `"Clothing"`, `"Shoes"`, `"Bags"`, `"Luxury"`.
- **Fix**:
  - Refactored `CategoryPillsWidget` (`category_pill_widget.dart`) to use minimal `vertical: 2` padding on the outer `ListView`, and aligned the pill text with centered vertical geometry.
  - Sized the pills to have unconstrained vertical breathing room with clean text baseline alignment.
  - Upgraded category matching in `_filterProducts` (`wish_list.dart`) to inspect `Product.category` directly in addition to title keywords for 100% precision.

---

### 29. Spacious Modern Luxury Product Detail Bottom Bar Redesign
- **Clean Luxury Architecture**: Eliminated the cluttered, narrow 4-item horizontal row by removing duplicate price clutter (since the prominent price is displayed prominently in the top header).
- **Stylist Concierge Button**: 52×52 frosted glass squircle with 18px smooth radius, modern message icon (`chat_bubble_2_fill`), and emerald live online pulse indicator.
- **Spacious "Add to Bag" Button**: Generous 52px height, 18px radius, frosted glass with primary tint, shopping bag icon (`bag_fill`), tactile haptics, and smooth animated `"Added ✓"` confirmation state.
- **Spacious "Buy Now" CTA Button**: Generous 52px height, 18px radius, radiant Haute Couture linear gradient with lightning bolt icon (`bolt_fill`), high-contrast typography, and radiant ambient drop shadow.

---

### 30. Buyer Delivery & Shipping Address Management Feature
- **`AddressProvider`**: Centralized state management for buyer delivery addresses with support for `addAddress()`, `updateAddress()`, `deleteAddress()`, and `setPrimary()`.
- **Profile Hub Wiring (`MorePage`)**: Added a dedicated **"Shipping & Delivery Addresses"** settings tile showing the live count of saved addresses and current default address label.
- **Luxury Address Management Screen (`AddressPickerPage`)**: Frosted glass address cards displaying recipient details, phone, full address, `"DEFAULT"` gold status badge, 1-tap "Set as Default" button, edit button (`pencil`), and delete dialog (`trash`).
- **Modern Address Editor Form (`AddressFormPage`)**: Category label chips (*Home, Office, Apartment, Villa, Studio*), validated contact info, street & postal code input, delivery notes for courier, and "Set As Default Address" toggle (`CupertinoSwitch`).
- **Checkout Integration**: Checkout directly synchronizes with the buyer's default or selected address from `AddressProvider`.
- **Tests**: Created comprehensive test suite `test/address_management_test.dart`.

---

## 🧪 Test Suite & Code Quality Metrics

- **Static Analyzer**: `flutter analyze` — **0 issues found** (100% clean).
- **Automated Tests**: `flutter test` — **60 / 60 test suites passing (100% pass rate)**.
- **Simulator Execution**: Active and running on **iPhone 17 iOS Simulator** with Impeller Metal GPU backend and live hot reload.

---

## 🚀 Milestones Status

| Milestone | Status | Details |
| :--- | :---: | :--- |
| **All Core Screen Redesigns** | ✅ Complete | Home, Product Detail, Cart, Checkout, Wishlist, Orders, Notifications, Profile, Theme Studio |
| **Buyer Address Management** | ✅ Complete | AddressProvider, Profile Settings tile, Luxury Address Manager, Add/Edit Address Form |
| **Spacious PDP Bottom Bar Redesign** | ✅ Complete | 52px wide action buttons, 52x52 concierge squircle, zero horizontal cramping |
| **Category Screen Modern Redesign** | ✅ Complete | Glass top bar, Hero Spotlight card, subcategory selector, Grid/List view modes |
| **Sort & Filter Button Modernization** | ✅ Complete | Centered frosted glass capsule with active indicators and 1-tap reset action |
| **Wishlist Category Pills Text Fix** | ✅ Complete | Eliminated text clipping on "All Items" and all pill labels |
| **Design System Extraction** | ✅ Complete | Reusable components established in `lib/widgets/` |
| **3-Language Localization** | ✅ Complete | English, Khmer, Vietnamese |
| **Dark Theme Color System** | ✅ Complete | High-contrast obsidian background & glowing active states |
| **Physical Device Verification** | ✅ Complete | Tested live on iPhone Kimmeng with Metal Impeller |
| **App Name Rebranding** | ✅ Complete | Updated to **WeBuy UAT** on iOS & Android |
| **Interactive Search Hub** | ✅ Complete | Real-time query search, history, trending, and category filtering |
| **Sizing & Fit Guide Modal** | ✅ Complete | CM/INCH unit switch, Smart Fit Recommender, measurement table |
| **Write Review & Rating Modal**| ✅ Complete | 5-star rating, fit choice, photo upload, +50 VIP points |
| **1-Tap Direct Checkout** | ✅ Complete | Instant "Buy Now" CTA button on Product Detail Page |
| **VIP Rewards & Loyalty Hub** | ✅ Complete | Points balance, perks list, referral code copy & share |
| **Order Lifecycle State Flow** | ✅ Complete | Checkout to active orders, cancellation, and reordering |
| **Global Wishlist State Sync** | ✅ Complete | WishlistProvider wired across all product cards and PDP |
| **Luxury Sort & Filter System** | ✅ Complete | Frosted glass modals, live filtering/sorting on Wishlist & Categories |
| **Expanded Catalog & Category Tabs**| ✅ Complete | 30+ pieces across Women, Men, Shoes, Bags, Luxury with live tab filters |
| **Simulator Live Execution** | ✅ Complete | Running live on iPhone 17 Simulator with Hot Reload |
| **Project Tracking (`ACTIVITY.md`)**| ✅ Complete | Fully documented project progress and architecture |

---

*Last Updated: 2026-08-31 by Senior Mobile Engineering Team*
