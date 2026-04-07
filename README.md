# Profitara – Inventory & Production Management

Profitara is a **Flutter** application designed for small business owners to track inventory, manage stock, plan production batches, and analyze profitability. It uses **BLoC** for state management and **SQLite** for local data persistence.

---

## ✨ Features

- **📊 Statistics Dashboard**  
  Total profit, revenue, stock value, low stock items, waste value, profit margin, most profitable batch, and production overview.

- **📦 Inventory Management**  
  Add, edit, delete stocks with custom units and conversion factors (e.g., 1 pack = 12 pieces).  
  Increase or decrease stock quantities, track waste, and view detailed stock information.

- **🏭 Batch Production**  
  Create production batches with multiple materials.  
  Each batch defines a yield (pieces produced), profit margin, and recommended selling price.  
  Start production with a multiplier – automatically deduct materials and record profit/revenue.

- **📈 Production Runs**  
  View all production runs, update actual sold quantities, and see updated profit calculations.

- **⚙️ Settings**  
  Switch between light and dark theme (persistent).

- **📱 Offline First**  
  All data stored locally using SQLite – no internet required.

---

## 🛠️ Technologies

- **Flutter** – UI framework  
- **BLoC** – State management  
- **SQLite** – Local database (via `sqflite`)  
- **Shared Preferences** – Theme persistence  
- **Provider** – Theme provider for cross‑page access  

---

## 📥 Installation

### Prerequisites
- Flutter SDK (>=3.0)
- Dart (>=3.0)
- Android Studio / VS Code with Flutter extensions

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/profitara.git
   cd profitara

2. **Install dependencies**
   ```bash
   flutter pub get

3. **Run the app**
   ```bash
   flutter run

Note: The app uses a local SQLite database that is created on first launch. No external database setup is required.

---


## 📁 Project Structure

      lib/
      ├── blocs/                 # BLoC state management
      │   ├── batch/            # BatchBloc (batches, production runs)
      │   ├── inventory/        # InventoryBloc (stocks, categories, waste)
      │   └── statistics/       # StatisticsBloc (dashboard data)
      ├── database/             # SQLite helper (DatabaseHelper)
      ├── models/               # Data models (Stock, Batch, ProductionRun, etc.)
      ├── pages/                # UI screens
      │   ├── add_batch_page.dart
      │   ├── add_stock_page.dart
      │   ├── batch_details_page.dart
      │   ├── batch_page.dart
      │   ├── inventory_page.dart
      │   ├── main_page.dart
      │   ├── production_details_page.dart
      │   ├── production_list_page.dart
      │   ├── settings_page.dart
      │   ├── statistics_page.dart
      │   └── stock_details_page.dart
      ├── providers/            # ThemeProvider (for light/dark mode)
      ├── repositories/         # Data layer (Stock, Batch, Waste repositories)
      ├── theme/                # App colors, text themes
      └── utils/                # Unit conversions, helpers

---

## 🗃️ Database Schema

Profitara creates the following tables on first run (version 10):

| Table               | Description                                 |
|---------------------|---------------------------------------------|
| `categories`        | Stock categories (Raw Material, Packaging)  |
| `stocks`            | Inventory items with base unit, quantity    |
| `stock_unit_pieces` | Custom piece counts for pack/box/bundle     |
| `batches`           | Production batch definitions                |
| `batch_materials`   | Materials required for each batch           |
| `waste`             | Waste entries for stocks                    |
| `production_runs`   | Executed production runs with profit/revenue|

All foreign keys are enforced with `ON DELETE CASCADE` where appropriate.

## 🧪 Usage Guide

### Adding Stocks

1. Go to **Inventory** → tap + button.

2. Enter name, category, base unit (e.g., *piece, kg, liter*).

3. Check the units that can be used for this stock (e.g., dozen, pack, box).
For *pack, box, or bundle,* specify the number of pieces it contains.

4. Enter initial quantity, cost (in any selected unit), and minimum stock level.

5. Save – the stock appears in the inventory list.

### Adjusting Stocks Quantity

- Tap a stock to open Stock Details.

- Use Add Stock to increase quantity (choose any compatible unit).

- Use Add Waste to record waste and decrease quantity.

### Creating a Batch 

1. Go to **Batches** → tap + button.

2. Enter batch name, yield (pieces produced), profit margin (%).

3. Add materials: select a stock, enter quantity, choose unit.

4. The recommended selling price is calculated automatically.

5. Save – the batch appears in the batch list.

### Starting Production

- Tap a batch → view details.

- Adjust the multiplier (number of production runs).

- See material cost, revenue, and profit for the selected multiplier.

- Tap Start Production – materials are deducted, and a production run is recorded.

### Updating Actual Sold

1. From the batch list, tap the history icon in the app bar to open Production Runs.

2. Tap a run → update the actual number of pieces sold.

3. Profit and revenue are recalculated automatically.

### Changing Theme 

- Open **Settings** (gear icon in the main app bar).

- Toggle **Dark Mode** – the preference is saved.

## 🎨 Customization

### Colors & Fonts

- Primary colors are defined in `lib/theme/app_colors.dart`.

- Fonts: Inter (body) and InterDisplay (headings) – assets must be placed in `assets/fonts/inter/`.
The `pubspec.yaml` includes the required font declarations.

### Units & Conversion

- The UnitConversions class (in `lib/utils/unit_conversions.dart`) manages all conversions.

- Custom pack sizes are stored per stock in `stock_unit_pieces` and passed to conversion methods.


## 📄 License

This project is open‑source and available under the **MIT License**.
Feel free to use, modify, and distribute it as you wish.


## 👤 Author

Created by [NelArevs](https://github.com/arevalojennel) – a tool for small business owners.
For questions or contributions, please open an issue on GitHub.


Happy selling! 🚀