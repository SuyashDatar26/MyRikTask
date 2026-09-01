Myrik — Flutter Take-Home
What I Built
A Blinkit-inspired category/product listing screen built with Flutter 3.32+, using live product data from the DummyJSON API.

Implemented
Two-column responsive product grid

Vertical category rail

Live product data from DummyJSON

Paginated product loading while scrolling

Product search using the DummyJSON search endpoint

Product cards with:

Product image
Product title
Price
Calculated original/MRP price
Discount
Rating
Shipping information
Stock/availability
ADD button with quantity stepper

Cart state maintained while navigating/rebuilding the screen

Favourite products

Favourite persistence using SharedPreferences

Loading state

Error state with retry

Empty/search-empty state

Out-of-stock handling

Bottom cart bar with item count and total

Hand-written Product.fromJson() model

Separation between UI, state management, networking and JSON parsing

Android and iOS app configuration

Automated test

Architecture
CategoryScreen
      │
      ├── SearchBar
      ├── CategoryRail
      ├── ProductCard
      └── CartBar
             │
             ↓
      ProductViewModel
             │
             ↓
       ProductService
             │
             ↓
        DummyJSON API
Project Structure
lib/
├── main.dart
├── models/
│   └── product.dart
├── services/
│   └── product_service.dart
├── viewmodels/
│   └── product_view_model.dart
├── screens/
│   └── category_screen.dart
└── widgets/
    ├── category_rail.dart
    ├── product_card.dart
    ├── cart_bar.dart
    └── search_bar.dart
API
The application uses the public DummyJSON Products API:

https://dummyjson.com/products
Search uses:

https://dummyjson.com/products/search?q={query}
Pagination is implemented using:

limit
skip
The product model is manually written and only successfully parsed product records are added to the application state, so a malformed record does not prevent the remaining products from being displayed.

Packages Used
http — API communication
provider — ViewModel/state management
shared_preferences — favourite persistence
Flutter Material — UI components
What I Skipped
I prioritised the required functionality within the one-hour timebox. I did not implement functional filters/sorting, authentication, checkout, a separate cart screen, or cart persistence because they were explicitly outside the required scope, while the category rail and bottom cart bar were kept lightweight.

Use of Assistants
I used an AI coding assistant during development for implementation guidance, debugging and reviewing the structure of the Flutter code. I reviewed and adapted the generated suggestions to fit the assessment requirements, particularly the separation between widgets, ViewModel, service and manually written model. The final implementation was tested locally on an Android device.

README Questions
1. Where does logic that two screens both need belong?
Logic that is shared by multiple screens should live below the UI layer, normally in a shared ViewModel, controller, service, or repository depending on what the logic does. Screens should consume that shared state or call the appropriate methods instead of duplicating the same business logic in each widget. This keeps behaviour consistent and makes the logic easier to test and change without modifying every screen.

2. What breaks tomorrow if the API adds a field to the product object?
Ideally, nothing breaks because the application model only reads the fields it actually needs and ignores additional fields returned by the API. If the API changes the type or structure of an existing field that the model depends on, the hand-written fromJson() parsing can reject that individual record rather than bringing down the entire product list. If we later need the new field, we can add it to the model and UI in one controlled place without changing the networking or screen architecture.
