# Privacy Policy

**Last updated:** May 6, 2026

This Privacy Policy explains how **Lariss POS** (`com.gialoop.lariss`) handles data when you use the application.

Lariss POS is designed as an **offline-first** point-of-sale application. Based on the current implementation in this repository, the app stores operational data locally on the user's device and does not require a backend server to run core features.

## 1. Data We Process

Lariss POS may process and store the following data entered by the user:

- Store profile data, such as store name and owner name
- Product data, such as product name, category, selling price, stock, and minimum stock
- Category data
- Stock movement records
- Transaction data, such as invoice number, totals, payment amount, change amount, purchased items, and timestamps
- App settings saved by the user

## 2. How We Use Data

The app uses the data above only to provide its core functionality, including:

- Managing products, categories, and stock
- Processing cashier transactions
- Saving transaction history
- Displaying business summaries and trends
- Saving local app settings
- Generating export files on the device, when that feature is used

## 3. Data Storage

Based on the current app implementation:

- Core data is stored locally on the device using a local SQLite database
- Export files, such as CSV or PDF reports, may be created and stored in the app's local documents directory on the device
- The app does **not** require a user account to use its current core features

## 4. Data Sharing

Based on the current implementation in this repository:

- The app does **not** sell user data
- The app does **not** share operational data with third-party advertisers
- The app does **not** send core store and transaction data to a remote backend server for normal app operation

If you choose to open or move exported files outside the app using your device's operating system or other apps, those actions may be governed by the privacy practices of those external apps or services.

## 5. Analytics and Tracking

Based on the current implementation in this repository:

- The app does **not** use third-party analytics SDKs
- The app does **not** use advertising SDKs
- The app does **not** track users across apps or websites

## 6. Permissions and Device Access

The app may use limited device capabilities needed to run features such as:

- Local file storage for app data
- Opening exported files on the device

The Android project includes internet permission in **debug/profile development manifests** for development tooling, but the current production app implementation in this repository does not rely on a backend service for core functionality.

## 7. Data Retention

User data remains stored on the device until:

- The user deletes the data from within the app, if such controls are available
- The user removes the app data from the device
- The user uninstalls the app, subject to how the operating system handles local files and backups

Exported files created outside the core database may remain on the device until manually deleted by the user.

## 8. Data Security

We take reasonable steps to protect data stored by the app. However:

- No device, software, or storage method can be guaranteed 100% secure
- The security of locally stored data also depends on the security of the user's device

Users are encouraged to secure their devices with appropriate protections such as screen lock, device encryption, and access controls.

## 9. Children's Privacy

Lariss POS is intended for business and operational use. It is not designed specifically for children.

## 10. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect product, legal, or operational changes. The updated version should replace the previous version and include a revised "Last updated" date.

## 11. Contact

For questions about this Privacy Policy, contact:

- Developer/Company: `[replace with legal entity or developer name]`
- Email: `[replace with support or privacy email]`

## 12. Important Publishing Note

Before publishing this app to Google Play or the App Store, replace the contact placeholders above with real developer contact details and publish this policy at a public, non-editable URL, because both stores require a privacy policy link for app submission.
