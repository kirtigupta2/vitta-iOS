# Vitta – iOS (SwiftUI)

## Easiest way (on the Mac)
1. On github.com click the green Code button > Download ZIP, then unzip it.
2. Open the unzipped folder and double-click **Vitta.xcodeproj**.
3. At the top pick an iPhone simulator and press Cmd+R.
4. Optional live previews: open Previews.swift > Editor > Canvas > Resume.

If Xcode says the project cannot be opened, use the manual way below.

## Manual way
Create a new iOS App project in Xcode (SwiftUI, Swift, Storage None), delete its
ContentView.swift, the *App.swift file and Assets.xcassets, then drag everything
inside the `Vitta` folder into the project (tick "Copy items if needed").

`qa_statement` (Statement icon) was never provided; an SF Symbol is used.

## Assets
Everything the app uses is already inside `Vitta/Assets.xcassets` (8 PNG images,
14 SVG icons, app icon, accent color). `Assets-Source/` keeps the original
files too: `images/` (PNG), `icons/` (SVG) and `fonts/` (Roboto TTF, optional –
the app uses the iPhone system font unless you add Roboto to the project).
