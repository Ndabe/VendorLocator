# Solution

## Scope

This implementation focuses on a reliable vertical slice of the vendor locator rather than building a full production backend. It satisfies the required SwiftUI, concurrency, Google Maps, Google Places, Keychain, REST, and XCTest requirements within the assessment time box.

## Architecture

The app is split into small feature and service boundaries:

```text
SwiftUI views
    -> @Observable view models
        -> protocols
            -> local JSON, URLSession, Keychain, Google Maps, Google Places
```

### Domain

`Vendor` and `Coordinate` are pure Codable value types. Coordinates are required because every vendor displayed on the map must have a marker.

### Vendor loading

`VendorLoading` defines the asynchronous vendor-loading contract.

- `LocalVendorLoader` decodes the bundled `vendors.json` file.
- `URLSessionVendorLoader` loads a REST JSON array, validates the HTTP response, decodes ISO-8601 dates, and attaches a bearer token when one is present.
- `AppDependencies` selects the local loader by default. Setting `VendorAPIEndpoint` in the app Info settings selects the URLSession loader.

The local source is intentional: the assignment permits a bundled JSON or other mock REST source, and it makes the demo deterministic without requiring a backend.

### State management

`VendorListViewModel` is the shared source of truth for the current vendor list and selected vendor. The Vendors and Map tabs receive the same instance, so list selection, marker selection, and Places additions remain synchronized.

The view model is main-actor isolated because it owns UI-observable state. Domain values are Sendable and can cross asynchronous boundaries.

## Google Maps implementation

`GoogleMapView` is a `UIViewRepresentable` wrapper around `GMSMapView`.

- Markers are reconciled by vendor ID.
- Marker titles contain the vendor name.
- Marker snippets contain the vendor address.
- Selecting a vendor from the list animates the camera to its coordinate and selects the corresponding marker.
- Google SDK setup is isolated in `GoogleSDKConfiguration` and reads `GoogleAPIKey` from the app configuration.

## Google Places enhancement

The chosen enhancement is **place search**.

`GooglePlacesService` is isolated behind `PlaceSearching` and uses the Google Places SDK to:

1. Request autocomplete suggestions for a query.
2. Read the selected place ID.
3. Fetch place details for name, formatted address, and coordinate.
4. Convert the result into a `Vendor`.
5. Add the vendor to the shared list, which causes the map to render its marker.

A live restricted API key is configured for the working demo, so a mocked Places implementation was not needed. The service protocol remains an explicit integration boundary where a mock could be injected for tests or offline development.

## Secure token storage

`KeychainTokenStore` uses the iOS generic-password Keychain APIs with:

- A service based on the app bundle identifier.
- A fixed session-token account.
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` accessibility.
- No token logging.

The Settings screen masks the token by default, supports explicit reveal, loads it from Keychain on appearance, and supports save and clear operations.

When the optional REST loader is active, it reads the token from the Keychain and sends it in the `Authorization` header. The bundled mock mode does not make network calls, so it has no request to authenticate.

## Error and loading states

The vendor list handles:

- Initial loading.
- Successful data display.
- Pull-to-refresh.
- Initial load failure with retry.
- Refresh failure while retaining the previous list, with a visible retry banner.
- Invalid or missing bundled data.
- REST transport, HTTP status, and decoding failures.

Places search exposes loading and error states in its search sheet.

## Testing

The focused XCTest decodes a representative vendor payload and verifies:

- Vendor identity.
- Latitude and longitude mapping.
- Favourite state.
- ISO-8601 date decoding.

This test was chosen because decoding is a core boundary between the REST/mock source and the application domain, and it is deterministic and fast.

## Trade-offs

- **Bundled JSON by default:** reliable for review and demonstration, but not a replacement for a production backend.
- **Optional REST loader:** keeps the network contract real without requiring an external service for the assessment.
- **In-memory favourites:** meets the requirement with minimal scope; favourites reset on relaunch.
- **No offline cache:** the local mock already provides deterministic degraded behavior, so a persistence cache was deferred.
- **One Places enhancement:** place search was selected because it demonstrates a clear user-facing Google Places integration. Address-to-coordinate lookup was intentionally not implemented.
- **No clustering:** the sample dataset is small and does not need marker clustering.
- **No Places session token:** the integration uses the SDK request boundary and place IDs, but session-token optimization was left outside the four-hour scope.

## Manual demo checklist

1. Launch and show the vendor list.
2. Pull to refresh and toggle a favourite.
3. Tap the vendor row and show map camera recentering and marker selection.
4. Open the map add action, search for a place, and add it as a vendor.
5. Open Settings, save a token, reveal it, relaunch, and clear it.
6. Switch the simulator between light and dark appearances.
