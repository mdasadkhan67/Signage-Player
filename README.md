# Flutter Signage Media Player – README

## 📌 Project Overview

Application is a **Signage Media Player** designed to display **images and videos continuously in a loop** on **TV screens or other all devices**.

The goal of this application is to ensure:

* smooth continuous playback
* proper memory management
* zero UI crashes during long-running playback
* support for multiple screen sizes
* scalable clean architecture

---

# 🧠 My Development Thought Process

## 1) Requirement Understanding

First, I carefully read the assignment requirements and understood the core business goal.

This is not a normal mobile app.
It is a **continuous loop signage player**, which means the application may run for:

* hours
* full day
* multiple days
* on shop advertisement screens

Because of this, I understood that **memory leakage prevention and resource management are the most important parts of the application**.

So from the beginning, I focused on:

* controller disposal
* timer cleanup
* safe state updates
* mounted checks
* proper lifecycle handling
* avoiding widget rebuild issues

---

## 2) Screen Size & TV Display Planning

The JD mentioned **TV screen size support**, so I made sure the UI is responsive and scalable.

I planned the app to support:

* mobile screens
* tablet screens
* Android TV / smart TV
* landscape large displays

For this, I used:

* `SizedBox.expand()`
* `SafeArea`
* `BoxFit.cover`
* responsive widgets
* media player widgets that scale to full screen

This ensures the media fits properly on **all screen sizes without distortion**.

---

## 3) Real-World Product Research

Before implementation, I followed how **real companies and online advertising display services** show ads on:

* shopping mall TVs
* restaurant menu screens
* store digital boards
* reception displays
* event LED screens

From this, I understood the common flow:

1. app opens
2. splash / initialization
3. fetch media configuration
4. preload content
5. show images/videos one by one
6. loop forever
7. recover safely on errors

This helped me design the app like a **real production signage system**.

---

## 4) Application Flow Planning

After understanding the business use case, I planned the full app flow.

## 🔁 Flow

```text
Main → Splash Screen → Media Screen → Load JSON → Initialize Media → Play Loop Forever
```

Detailed flow:

1. `main.dart` launches app
2. Splash screen handles initial setup
3. Navigate to media screen
4. JSON file is loaded
5. Response converted into model
6. Check media type
7. If image → show image with timer
8. If video → initialize video controller
9. After complete → move next
10. Repeat from start

This provides **infinite loop playback**.

---

## 5) JSON Response Planning

I planned the JSON structure in a clean and scalable way.

## 📄 Sample JSON

```json
[
  {
    "type": "image",
    "url": "https://picsum.photos/800/600"
  },
  {
    "type": "video",
    "url": "https://samplelib.com/lib/preview/mp4/sample-5s.mp4"
  }
]
```

### Why this structure?

This structure is simple and easy for backend integration.

Using the `type` key, the app decides:

* image widget
* video widget
* future gif/web content support

---

## 6) Dynamic Media Rendering

As per the JSON key, I render media dynamically.

### Logic

* `type == image` → `Image.network()` 
* `type == video` → `VideoPlayerController`

This makes the application backend-driven and easy to scale.

No hardcoded UI media logic is required.

---

## 7) Clean Project Architecture

I created a proper maintainable project structure.

## 📁 Folder Structure

```text
lib/
│
├── main.dart
├── models/
│   └── media_item.dart
│
├── services/
│   └── media_service.dart
│
├── screens/
│   ├── splash_screen.dart
│   └── media_screen.dart
│
├── widgets/
│   ├── image_player.dart
│   └── video_player_widget.dart
│
├── utils/
│   └── app_constants.dart
│
└── helpers/
    └── media_helper.dart
```

## 8) Startup Initialization Flow

The startup flow is designed carefully.

## 🚀 App Startup

```text
main → splash → media screen → initialize JSON → start playback
```

### Splash Responsibilities

* initial loading UI
* app warmup
* navigation preparation
* future token/device checks

### Media Screen Responsibilities

* JSON parsing
* media switching
* timer setup
* video controller setup
* loop playback
* error recovery

---

# 🛡️ Memory Leak Prevention Strategy

This was the most important part of development.

Because the app runs continuously, I added strict memory-safe logic.

## ✅ Timer Cleanup

```dart
_timer?.cancel();
```

## ✅ Video Controller Cleanup

```dart
_videoController?.dispose();
```

## ✅ Safe Widget Updates

```dart
if (mounted) setState(() {});
```

## ✅ Safe Navigation

```dart
if (context.mounted)
```

These steps prevent:

* memory leaks
* disposed widget crashes
* duplicate timers
* duplicate listeners
* video controller overflow

---

# ✅ Final Result

The final application is:

* production-ready
* memory safe
* scalable
* responsive for TV screens
* online + offline capable
* loop optimized
* cleanly structured

This approach closely follows how **real advertising display companies build signage systems**.

---

# 🙌 Conclusion

I started by deeply understanding the requirement, especially the **continuous loop nature of the application**, which made **memory management, screen adaptability, and architecture planning** the top priorities.

Then I researched real-world signage services, designed the playback flow, structured the JSON response, created reusable modules, and implemented safe lifecycle handling.

The final result is a **stable, maintainable, and real-world Flutter signage player solution**.
