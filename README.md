# TextGenius-SmartText: Custom iOS Keyboard Extension

Welcome to the TextGenius, a Custom iOS Keyboard Extension project! This project provides a custom keyboard for iPhones, built using UIKit, and a companion app built with SwiftUI for customization options. The keyboard features a built-in search bar that integrates with the Gemini-1.5 flash API to quickly answer questions or generate content for commenting or replying.

## Contents

- [Features](#features)
- [Demo](#demo)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Dependencies](#dependencies)
  - [Steps](#steps)
- [Usage](#usage)
- [Customization](#customization)
  - [UIKit (Keyboard)](#uikit-keyboard)
  - [SwiftUI (App)](#swiftui-app)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

- **Embedded Search Bar**: Quickly ask questions from the Gemini-1.5 flash API.
- **Content Generation**: Generate content for comments or replies effortlessly.
- **Customization Options**: Enable autocorrect, double space for a period, auto-capitalization after space, and audio and haptic feedback.
- **Special Functionality**: A special key to easily set the LLM API for generating smart replies/comments.
- **Advanced Text Manipulation**: Long press on the spacebar to move the cursor, enhancing text editing efficiency, auto caps after period, and much more like a native iOS keyboard.
- **UIKit & SwiftUI**: Built using UIKit for the keyboard and SwiftUI for the customization app.

## Demo

Watch demo video on YouTube [by clicking here](https://youtu.be/5UIAogtqVv0?si=FIFv0eo52bBhmP0p)

## Installation

### Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.10+

### Dependencies

- **Generative AI Swift**: [Generative-AI-Swift](https://github.com/Generative-AI-Swift)
- **Lottie**: [Lottie](https://github.com/airbnb/lottie-ios)
- **MarkdownKit**: [MarkdownKit](https://github.com/bmoliveira/MarkdownKit)

### Steps

1. **Clone the repository:**
    ```bash
    cd TextGenius
    git clone https://github.com/DEV-D-GR8/TextGenius.git
    ```
2. **Open the project in Xcode:**
    ```bash
    open TextGenius.xcodeproj
    ```
3. **Build and run the project:**
    - Select the `TextGenius` target.
    - Connect your iOS device or use a simulator.
    - Click the Run button or press `Cmd + R`.

4. **Enable the Keyboard Extension:**
    - Go to `Settings` > `General` > `Keyboard` > `Keyboards` > `Add New Keyboard...`
    - Select `SmartText-TextGenius`.

## Usage

1. **Access the Keyboard:**
    - Open any app that uses the keyboard.
    - Tap and hold the globe icon to select `SmartText-TextGenius`.

2. **Use the Search Bar:**
    - Type your query in the search bar.
    - Get instant answers or content generated by Gemini-1.5 flash API.

3. **Customize Settings:**
    - Open the companion app.
    - Adjust settings such as autocorrect, double space for a period, auto-capitalization, and audio/haptic feedback.

## Customization

### UIKit (Keyboard)

The keyboard is built using UIKit to provide a familiar iOS-like experience. You can customize the appearance and behavior of the keyboard by modifying the `KeyboardViewController.swift` file.

### SwiftUI (App)

The companion app is built with SwiftUI for easy customization. You can add or modify settings in the `SettingsView.swift` file.
There is an onboarding screen provided for first time app launch and splash screen for subsequent launches.

## Contributing

Contributions are welcome! Please fork this repository and submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for more details.

## Contact

For any inquiries or support, please contact Dev Asheesh Chopra at [chopradevasheesh@gmail.com](mailto:chopradevasheesh@gmail.com).

---

Thank you for using the TextGenius custom iOS Keyboard Extension! Enjoy a seamless typing experience with powerful customization options.
