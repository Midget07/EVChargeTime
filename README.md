# EVChargeTime

EVChargeTime is a Flutter app that helps electric vehicle owners estimate charging time based on battery capacity, current and target charge percentages, type of current (AC/DC), and charging amperage.

## Features

- Input battery capacity, current charge %, target charge %, and charging amperage.
- Choose between AC and DC current.
- Calculates estimated charging time and finish time.
- Saves the last entered values locally for convenience.

## Getting Started

### Prerequisites

- Flutter SDK installed
- An Android device/emulator to run the app

### Installing

1. Clone the repository:
git clone https://github.com/your-username/your-repo-name.git


2. Navigate to the project directory:
cd your-repo-name


3. Install dependencies:
flutter pub get


4. Run the app:
flutter run


## Building APK

To build an APK for Android, run:
flutter build apk

The APK will be generated in `build/app/outputs/flutter-apk/app-release.apk`.

## Usage

- Enter the battery capacity in kWh.
- Adjust the current and target charge percentages.
- Select the current type (AC or DC).
- Set the charging amperage.
- The app calculates and displays the estimated charging time and finish time.
- The app remembers your last inputs for next time.

## Dependencies

- Flutter SDK
- intl (for date and time formatting)
- shared_preferences (for saving user data locally)

## License

This project is licensed under the MIT License.

---

Feel free to customize the repository URL and add any additional sections as needed.
If you want, I can help you generate a more detailed README as well.
