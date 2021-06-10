# AdaptiveFonts
<img src= "/font-schema.png" height = 400>


## Introduction

In brief, AdaptiveFonts is a font library to use custom fonts on the fly. AdaptiveFonts takes responsibilities for:
- [x] Downloading fonts from Google Fonts or custom resources.
- [x] Registering custom fonts to the system.
- [x] Loading and using custom fonts dynamically and seamlessly.

## Installation

### CocoaPods

Install [CocoaPods](https://cocoapods.org) if need be.

```bash
$ gem install cocoapods
```

Add `AdaptiveFonts` in your `Podfile`.

```ruby
use_frameworks!

pod 'AdaptiveFonts'
```

Run the following command.

```bash
$ pod install
```

## Usage

Firstly, set the [Google API](https://developers.google.com/fonts/docs/developer_api) key in the app delegate.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    AdaptiveFonts.shared.APIKey = "paste your key here"
}
```

Now you are ready to use AdaptiveFonts with only one API to remember.

```swift
let font = Font(family: "ABeeZee", variant: .regular)
let fontSize = 27
AdaptiveFonts.shared.font(for: font, size: fontSize) { uifont in
    // Do something with the `uifont`.
}
```

_**Note:** Do not forget to `import AdaptiveFonts` in any file using AdaptiveFonts._
