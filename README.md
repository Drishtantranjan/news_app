# News App

A modern Flutter application that provides users with the latest news updates in a clean and intuitive interface.

## Features

- 📰 Latest news feed with list and grid view options
- 🔍 Detailed news article view with pinch-to-zoom image support
- 🌓 Dark/Light theme support
- 📱 Responsive design for both Android and iOS
- 🔄 Infinite scroll for news feed
- 🖼️ Cached image loading for better performance
- 📊 API call tracking

## Screenshots

[Add your app screenshots here]

## Getting Started

### Prerequisites

- Flutter SDK (3.19.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Drishtantranjan/news_app.git
```

2. Navigate to the project directory:
```bash
cd news_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── features/
│   ├── news_list/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── news_detail/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    └── widgets/
```

## Architecture

This project follows Clean Architecture principles with the following layers:
- Presentation Layer (UI, BLoC)
- Domain Layer (Entities, Use Cases)
- Data Layer (Repositories, Data Sources)

## Dependencies

- `flutter_bloc`: State management
- `cached_network_image`: Image caching
- `photo_view`: Image zoom functionality
- [Add other dependencies here]

## CI/CD

This project uses GitHub Actions for continuous integration and deployment. The workflow:
- Runs on push to main branch and pull requests
- Verifies code formatting
- Runs static analysis
- Executes tests
- Builds release versions for Android and iOS

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Project Link: [https://github.com/Drishtantranjan/news_app](https://github.com/Drishtantranjan/news_app)
