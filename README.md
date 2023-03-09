# 100 Days of Swift

Projects from the Hacking with Swift book by Paul Hudson ([@twostraws](https://github.com/twostraws))

The book is divided into `Projects` and `Milestones`. `Projects` are meant to teach iOS cocepts, techniques and frameworks.\
Every `3` projects, a milestone is reached. `Milestones` are challenges that use the concepts learned in the previous 3 projects. For example, after `Project 3` comes `Milestone 1`.


## Course Content

---

### Project 1: *[Storm Viewer](Project%201)*
**Objective:** Get started coding in Swift by making an image viewer app and learning key concepts.

**Topics:** View Controllers, Storyboards, `UITableView`, `UIImageView`, `FileManager`

---

### Project 2: *[Guess the Flag](Project%202)*
**Objective:** Make a game using UIKit, and learn about integers, buttons, colors and actions.

**Topics:** Asset catalogs, `UIButton`, `IBAction`, `CALayer`, `UIColor`, `UIAlertController`

---

### Project 3: *[Social Media](Project%203)*
**Objective:** Let users share photos to social media by modifying project 1.

**Topics:** `UIBarButtonItem`, `UIActivityViewController`, `URL`

---

### Milestone 1: *[Country Flags](Milestone%201)*
Topics covered in Projects: 1-3

**Challenge:** Create an app that lists various world flags in a table view. When one of them is tapped, slide in a detail view controller that contains an image view, showing the same flag full size. On the detail view controller, add an action button that lets the user share the flag picture and country name using `UIActivityViewController`.

---

### Project 4: *[Easy Browser](Project%204)*
**Objective:** Embed WebKit and learn about delegation, Key-Value Observing (KVO), classes and `UIToolbar`.

**Topics:** `loadView()`, `WKWebView`, `URLRequest`, `UIToolbar`, `UIProgressView`, Key-Value Observing (KVO)

---

### Project 5: *[Word Scramble](Project%205)*
**Objective:** Create an anagram game while learning about closures and booleans.

**Topics:** Closures, Method return values, Booleans, `NSRange`

---

### Project 6: *[Auto Layout](Project%206)*
**Objective:** Get to grips with Auto Layout using practical examples and code.

**Topics:** `NSLayoutConstraint`, Visual Format Language, Layout anchors

---

### Milestone 2: *[Shopping List](Milestone%202)*
Topics covered in Projects: 4-6

**Challenge:** Create an app that lets people create a shopping list by adding items to a table view.

---

### Project 7: *[Whitehouse Petitions](Project%207)*
**Objective:** Make an app to parse Whitehouse petitions using JSON and a tab bar.

**Topics:** `UITabBarController`, JSON, `Data`, `Codable`

---

### Project 8: *[7 Swifty Words](Project%208)*
**Objective:** Build a word-guessing game and master strings once and for all.

**Topics:** Programmatic UI, String methods (e.g.: `count()`, `index(of:)`, `joined()`), Property observers, Range operators

---

### Project 9: *[Grand Central Dispatch](Project%209)*
**Objective:** Learn how to run complex tasks in the background with GCD.

**Topics:** `DispatchQueue`, `perform(inBackground:)`

---

### Milestone 3: *[Hangman Game](Milestone%203)*
Topics covered in Projects 7-9

**Challenge:** Make a hangman game using UIKit. As a reminder, this means choosing a random word from a list of possibilities, but presenting it to the user as a series of underscores. So, if your word was “RHYTHM” the user would see “??????”.

---

### Project 10: *[Names to Faces](Project%2010)*
**Objective:** Get started with UICollectionView and the photo library.

**Topics:** `UICollectionView`, `UIImagePickerController`, `UUID`, Classes (`NSObject`)

---

### Project 11: *[Pachinko](Project%2011)*
**Objective:** Dive into `SpriteKit` to try your hand at fast 2D games.

**Topics:** `SpriteKit`, `SKAction`, `UITouch`, Physics, Blend modes, Collisions, Emitters, `CGFloat`

---

### Project 12: *[UserDefaults](Project%2012b)*
**Objective:** Learn how to save user settings and data for later use.

[Project 12a](Project%2012a) uses `NSCoding`, `NSKeyedArchiver`, `NSKeyedUnarchiver` to persist data.
[Project 12b](Project%2012b) uses `Codable`, `JSONEncoder` and `JSONDecoder` to persist data.

**Topics:** `UserDefaults`, `NSCoding`, `Codable`

---

### Milestone 4: *[Camera Interests](Milestone%204)*
Topics covered in Projects 10-12

**Challenge:** To put two different projects into one (Projects 1 and 12). Let users take photos of things that interest them, add captions to them, then show those photos in a table view. Tapping the caption should show the picture in a new view controller.

---

### Project 13: *[Instafilter](Project%2013)*
**Objective:** Make a photo manipulation program using `CoreImage` filters and a `UISlider`.

**Topics:** `CoreImage`, `CIContext`, `CIFilter`, `UISlider`, Writing to the Photo Library

---

### Project 14: *[Whack-a-Penguin](Project%2014)*
**Objective:** Build a game using `SKCropNode` and a sprinkling of Grand Central Dispatch.

**Topics:** `SKCropNode`, `SKTexture`, `asyncAfter()`

---

### Project 15: *[Animation](Project%2015)*
**Objective:** Bring your interfaces to life with animation, and meet switch/case at the same time.

**Topics:** Core Animation, `CGAffineTransform`

---

### Milestone 5: *[Country Facts](Milestone%205)*
Topics covered in Projects 13-15

**Challenge:** Make an app that contains facts about countries: show a list of country names in a table view, then when one is tapped bring in a new screen that contains its capital city, size, population, currency, and any other facts that interest you.

---

### Project 16: *[Capital Cities](Project%2016)*
**Objective:** Teach users about geography while you learn about MKMapView and annotations.

**Topics:** `MKMapView`, `MKAnnotation`, `MKPinAnnotationView`, `CLLocationCoordinate2D`

---

### Project 17: *[Space Race](Project%2017)*
**Objective:** Dodge space debris while you learn about per-pixel collision detection.

**Topics:** Per-pixel collision detection, Advancing particle systems, `Timer`, `linearDamping`, `angularDamping`

---

### Project 18: *[Debugging](Project%2018)*
**Objective:** Everyone hits problems sooner or later, so learning to find and fix them is an important skill.

**Topics:** `print()`, `assert()`, Breakpoints, View debugging

---

### Milestone 6: *[Shooting Gallery](Milestone%206)*
Topics covered in Projects 16-18

**Challenge:** Make a shooting gallery game using SpriteKit: create three rows on the screen, then have targets slide across from one side to the other. If the user taps a target, make it fade out and award them points.

---

### Project 19: *[JavaScript Injection](Project%2019)*
**Objective:** Extend Safari with a cool feature for JavaScript developers.

**Topics:** Safari extensions, `NSExtensionItem` `UITextView`, `NotificationCenter`

---

### Project 20: *[Fireworks Night](Project%2020)*
**Objective:** Learn about color blends while making things go bang!

**Topics:** `UIBezierPath`, `SKAction.follow()`, Sprite color blending, Emitter nodes, Shake gestures

---

### Project 21: *[Local Notifications](Project%2021)*
**Objective:** Send reminders, prompts and alerts even when your app isn't running.

**Topics:** `UNUserNotificationCenter`, `UNNotificationRequest`, `UNMutableNotificationContent`, `UNCalendarNotificationTrigger`, and `UNTimeIntervalNotificationTrigger`

---

### Milestone 7: *[Notes](Milestone%207)*
Topics covered in Projects 19-21

**Challenge:** Recreate the iOS Notes app. Follow the iPhone version, because it’s fairly simple: a navigation controller, a table view controller, and a detail view controller with a full-screen text view.

---

### Project 22: *[Detect-a-Beacon](Project%2022)*
**Objective:** Learn to find and range iBeacons using our first project for a physical device.

**Topics:** iBeacons, Core Location, `CLLocationManager`, `CLBeaconRegion`, `CLProximity`

---

### Project 23: *[Swifty Ninja](Project%2023)*
**Objective:** Learn to draw shapes in SpriteKit while making a fun and tense slicing game.

**Topics:** `SKShapeNode`, `touchesEnded()`, `AVAudioPlayer`, `CaseIterable`

---

### Project 24: *[Swift Strings](Project%2024)*
**Objective:** Learn more about Swift Strings.

**Topics:** String subscripts, `contains(where:)`, `NSAttributedString`, Swift playgrounds

---

### Milestone 8: *[Swift Extensions](Milestone%208)*
Topics covered in Projects 22-24

**Challenge:** Implement three Swift language extensions using what you learned in project 24.
1. Extend `UIView` so that it has a `bounceOut(duration:)` method that uses animation to scale its size down to 0.0001 over a specified number of seconds.
2. Extend `Int` with a `times()` method that runs a closure as many times as the number is high. For example, `5.times { print("Hello!") }` will print “Hello” five times.
3. Extend `Array` so that it has a mutating `remove(item:)` method. If the item exists more than once, it should remove only the first instance it finds.

---

### Project 25: *[Selfie Share](Project%2025)*
**Objective:** Make a multipeer photo sharing app in just 150 lines of code.

**Topics:** Multipeer Connectivity Framework, `MCSession`, `MCPeerID`, `MCAdvertiserAssistant`, `MCBrowserViewController`

---

### Project 26: *[Marble Maze](Project%2026)*
**Objective:** Respond to device tilting by steering a ball around a vortex maze.

**Topics:** Core Motion (Accelerometer), `CMMotionManager`, Collision bitmasks, Array reversing, Compiler directives

---

### Project 27: *[Core Graphics](Project%2027)*
**Objective:** Draw 2D shapes using Apple's high-speed drawing framework.

**Topics:** Core Graphics, `UIGraphicsImageRenderer`, Drawing Fills and Strokes, Transforms

---

### Milestone 9: *[Meme Generator](Milestone%209)*
Topics covered in Projects 25-27

**Challenge:** Create a meme generation app using `UIImagePickerController`, `UIAlertController`, and Core Graphics. If you aren’t familiar with them, memes are a simple format that shows a picture with one line of text overlaid at the top and another overlaid at the bottom.

---

### Project 28: *[Secret Swift](Project%2028)*
**Objective:** Save user data securely using the device keychain and Touch ID.

**Topics:** `LocalAuthentication` for Biometrics Authentication (Touch ID and Face ID), Device keychain

---

### Project 29: *[Exploding Monkeys](Project%2029)*
**Objective:** Remake a classic DOS game and learn about destructible terrain and scene transitions.

**Topics:** Mixing `UIKit` and `SpriteKit`, Texture atlases, Scene transitions, Destructible terrain

---

### Project 30: *[Instruments](Project%2030)*
**Objective:** Become a bug detective and track down lost memory, slow drawing and more.

**Topics:** Instruments, Time Profiler, Allocations, Shadows, Table cells in code

---

### Milestone 10: *[Memory Pairs](Milestone%2010)*
Topics covered in Projects 28-30

**Challenge:** Create a memory pairs game that has players find pairs of cards – it’s sometimes called Concentration, Pelmanism, or Pairs.

---