# Setting Up TestFlight Distribution with GitHub Actions

This guide explains how to set up the required secrets and certificates for automated TestFlight distribution using GitHub Actions.

## Required Secrets
Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions > New repository secret):

### Apple Distribution Certificate

1. `APPLE_DISTRIBUTION_CERTIFICATE_BASE64`: Your Apple Distribution Certificate in Base64 format
2. `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD`: The password for your certificate

To convert your certificate to Base64:
```bash
base64 -i Certificates.p12 | pbcopy
```

### Provisioning Profile

`PROVISIONING_PROFILE_BASE64`: Your provisioning profile in Base64 format

To convert your provisioning profile to Base64:
```bash
base64 -i profile.mobileprovision | pbcopy
```

### App Store Connect API Key

1. `APP_STORE_CONNECT_API_KEY_ID`: The Key ID from App Store Connect
2. `APP_STORE_CONNECT_API_KEY_ISSUER_ID`: The Issuer ID from App Store Connect
3. `APP_STORE_CONNECT_API_KEY_CONTENT`: The content of your .p8 key file in Base64 format

To convert your API key to Base64:
```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

### Other Secrets

`KEYCHAIN_PASSWORD`: A secure password for the temporary keychain (can be any strong password)

## Creating an App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to Users and Access > Keys
3. Click the "+" button to create a new key
4. Give it a name like "GitHub Actions"
5. Select "App Manager" access
6. Download the key (it can only be downloaded once)
7. Note the Key ID and Issuer ID

## Updating the Appfile

Before pushing to GitHub, update the `fastlane/Appfile` with your actual bundle identifier and Apple ID:

```ruby
app_identifier("com.yourcompany.yourapp") # Your app's bundle identifier
apple_id("your_apple_id@example.com") # Your Apple email address
```

## Testing Locally

You can test the Fastlane setup locally before pushing to GitHub:

```bash
bundle install
bundle exec fastlane beta
```

## Workflow Execution

The TestFlight distribution workflow will run automatically when:
- Code is pushed to the main branch
- You manually trigger the workflow from the Actions tab in GitHub

## Troubleshooting

If you encounter issues:
1. Check the GitHub Actions logs for detailed error messages
2. Verify that all secrets are correctly set up
3. Ensure your Apple Developer account has the necessary permissions
4. Check that your provisioning profile is valid and includes the correct devices 

## Additional Changes

### Create Legacy Build Settings

```yaml
- name: Create Legacy Build Settings
  run: |
    # Create a shared data directory with build settings
    mkdir -p WomenBusinessDirectory.xcodeproj/project.xcworkspace/xcshareddata
    cat > WomenBusinessDirectory.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings << 'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>BuildSystemType</key>
        <string>Original</string>
        <key>DisableBuildSystemDeprecationWarning</key>
        <true/>
        <key>IDEPackageSupportUseBuiltinSCM</key>
        <true/>
    </dict>
    </plist>
    EOF
```

### Build and Archive

```yaml
- name: Build and Archive
  run: |
    # Use env file and direct project reference with legacy build system
    source .xcodebuild.env
    
    # Try building with xcpretty for better output formatting
    set -o pipefail && xcodebuild clean archive \
      -project WomenBusinessDirectory.xcodeproj \
      -scheme WomenBusinessDirectory \
      -sdk iphoneos \
      -configuration Release \
      -allowProvisioningUpdates \
      -derivedDataPath DerivedData \
      -archivePath ./WomenBusinessDirectory.xcarchive \
      COMPILER_INDEX_STORE_ENABLE=NO \
      | xcpretty 
``` 