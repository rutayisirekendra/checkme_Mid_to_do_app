# CheckMe - Modern Todo & Productivity App

A beautiful, feature-rich Flutter application for task management and productivity with gamification elements.

## Features

### 🎯 Core Features
- **Task Management**: Create, edit, complete, and delete todos with rich details
- **Smart Organization**: Categories, priorities, due dates, and subtasks
- **Calendar View**: Visual task overview with calendar integration
- **Search & Filter**: Find tasks quickly with advanced filtering options
- **Notes & Reflections**: Personal journaling and note-taking system

### 🎨 Design & UX
- **Modern UI**: Clean, minimalist design with glassmorphism effects
- **Dark/Light Mode**: Automatic theme switching based on user preference
- **Smooth Animations**: Delightful micro-interactions and transitions
- **Responsive Design**: Optimized for all screen sizes

### 🌱 Gamification
- **Growing Garden**: Visual garden that grows as you complete tasks
- **Streak Visualizer**: Track your daily productivity streaks
- **Progress Tracking**: Visual progress indicators and statistics
- **Daily Inspiration**: Motivational quotes and productivity tips

### 🔐 Security & Privacy
- **Local-First**: All data stored locally on your device
- **Biometric Authentication**: Secure access with fingerprint/face ID
- **PIN Protection**: Additional security layer for sensitive data
- **Privacy Focused**: No data collection or cloud sync

### 📱 Advanced Features
- **Notifications**: Smart reminders for due tasks
- **File Attachments**: Attach images, documents, and audio notes
- **Recurring Tasks**: Set up repeating tasks automatically
- **Task Dependencies**: Link tasks that depend on each other
- **Export/Import**: Backup and restore your data

## Technology Stack

- **Framework**: Flutter 3.8+
- **State Management**: Riverpod
- **Local Storage**: Hive
- **UI Components**: Material Design 3
- **Animations**: Flutter Staggered Animations
- **Notifications**: Flutter Local Notifications
- **Authentication**: Local Auth

## Getting Started

### Prerequisites
- Flutter SDK 3.8 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd checkme_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── theme/              # App themes and colors
│   ├── constants/          # App constants
│   └── extensions/         # Dart extensions
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── home/              # Home dashboard
│   ├── todo/              # Todo management
│   ├── calendar/          # Calendar view
│   ├── notes/             # Notes and reflections
│   └── settings/          # App settings
├── models/                 # Data models
├── services/              # Business logic services
├── shared/                # Shared components
│   ├── widgets/           # Reusable widgets
│   └── providers/         # State providers
└── utils/                 # Utility functions
```

## Key Features Implementation

### Growing Garden
The app features a unique gamification system where completing tasks causes a virtual garden to grow. Different types of tasks create different elements in the garden, providing visual feedback for productivity.

### Streak Visualizer
Track your daily productivity with a visual path that shows your current streak and longest streak. The character moves along the path as you maintain your daily task completion.

### Smart Notifications
Intelligent notification system that reminds you of upcoming tasks and celebrates your achievements. Notifications are customizable and respect your preferences.

### Local-First Architecture
All data is stored locally using Hive database, ensuring your information stays private and the app works offline. No internet connection required for core functionality.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- All open-source contributors who made this possible

## Support

If you encounter any issues or have questions, please:
1. Check the [Issues](https://github.com/your-repo/issues) page
2. Create a new issue with detailed information
3. Contact the development team

---

**CheckMe** - Your personal productivity companion 🌟