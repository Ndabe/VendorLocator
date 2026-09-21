# VendorLocator

A SwiftUI vendor locator for iOS. The app loads vendors, displays them on Google Maps, supports Google Places search, and stores a session token securely in the iOS Keychain.

## Requirements

- Xcode 27 or later
- iOS 17.6 or later
- A macOS development environment
- A Google Cloud project with billing enabled for Maps and Places usage

## Run locally

1. Clone the repository.
2. Open `VendorLocator.xcodeproj` in Xcode.
3. Allow Xcode to resolve the Swift Package Manager dependencies:
   - Google Maps SDK for iOS 11.1.0+
   - Google Places SDK for iOS 11.1.0+
4. Select an iOS 17.6+ simulator or device.
5. Build and run the `VendorLocator` scheme.

The app uses the bundled `VendorLocator/Resources/vendors.json` file by default, so the vendor list is deterministic and does not require a backend.

## Google API key

The submitted project includes the configured key in `VendorLocator/Info.plist` under
`GoogleAPIKey`. `GoogleSDKConfiguration` reads this value at launch and provides it to
the Google Maps and Google Places SDKs.

For a new local key, select the `VendorLocator` app target, open **Info**, and add or replace:

- Key: `GoogleAPIKey`
- Type: `String`
- Value: your restricted key

API keys are not server secrets, but they must be restricted by bundle identifier and API.
Do not reuse this key for unrestricted production or server-side access.

## Optional REST endpoint

The default app uses bundled JSON. To use the token-aware REST loader, add this custom Info property to the app target:

- Key: `VendorAPIEndpoint`
- Type: `String`
- Value: an HTTPS endpoint returning a JSON array of vendors

The endpoint should return objects matching the `Vendor` model:

```json
[
  {
    "id": "ven-001",
    "name": "Example Vendor",
    "address": "12 Example Street",
    "coordinate": {
      "lat": -33.918861,
      "lng": 18.423300
    },
    "isFavorite": false,
    "updatedAt": "2025-06-01T12:00:00Z"
  }
]
```

When a token exists in Keychain, the REST loader sends it as `Authorization: Bearer <token>`.

## Tests

Run the focused unit test from Xcode.
The test validates vendor JSON decoding, coordinates, favourites, and ISO-8601 dates.

## Main flows

- **Vendors:** Load, refresh, inspect vendor details, and toggle favourites.
- **Map:** View vendor markers and select a vendor to recenter the camera.
- **Add vendor:** Search Google Places and add a selected place as a vendor and marker.
- **Settings:** Save, reveal, reload, and clear the session token.
