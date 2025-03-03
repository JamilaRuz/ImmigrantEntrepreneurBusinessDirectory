<b>Bussiness Directory</b> </br>
<p>This app was developed as a Business Directory for Immigrant Entrepreneurs in Canada. It provides listings of businesses organized into niche-specific categories. </p>

<b>Overview</b>
  <p>The app integrates with third-party platforms such as Google, Facebook, and Apple, and utilizes Firebase for data storage. These technologies combine to provide a robust and scalable app for immigrant entrepreneurs, offering easy authentication, business listing management, and real-time data storage with Firebase.</p>
<b>Swift/SwiftUI</b> </br>
<b>Firebase:</b> </br>
<b>Backend & Data Storage:</b> Firebase is used to store business listing data, handle real-time database management, and offer cloud-based storage</br>
<b>Firebase Cloud Firestore:</b></br>
A NoSQL database used for storing and syncing data.</br>
<b>Firebase Authentication:</b></br>
Handles user authentication with Google, Facebook, and Apple login.</br></br>

 <b>Screenshots</b> </br></br>
 
 <p>
   <img src="https://github.com/user-attachments/assets/532d3861-53ad-43f5-b731-9edefd2942d3" width="200"/>
   <img src="https://github.com/user-attachments/assets/5236727e-5f09-46ea-87c7-0705b14d7b6e" width="200"/>
   <img src="https://github.com/user-attachments/assets/9e00779a-e9a9-47ed-8c8d-cc61249a03dc" width="200"/>
   <img src="https://github.com/user-attachments/assets/c9b2b6f1-160a-4ef6-bfc7-88f6dad66f44" width="200"/>
   <img src="https://github.com/user-attachments/assets/f89ec88a-a4e4-44c0-85ec-1bcfb6b1b444" width="200"/>
 </p>
 
## CI/CD with GitHub Actions

This project uses GitHub Actions for continuous integration and delivery. The workflow automatically:

1. Builds the app
2. Runs unit tests
3. (When configured) Deploys to TestFlight

### CI/CD Status

[![iOS CI/CD](https://github.com/YOUR_USERNAME/WomenBusinessDirectory/actions/workflows/ios.yml/badge.svg)](https://github.com/YOUR_USERNAME/WomenBusinessDirectory/actions/workflows/ios.yml)

### Setting Up Deployment

To enable automatic deployment to TestFlight:

1. Uncomment the `deploy-to-testflight` job in `.github/workflows/ios.yml`
2. Add the following secrets to your GitHub repository:
   - `BUILD_CERTIFICATE_BASE64`: Your distribution certificate as base64
   - `P12_PASSWORD`: The password for your certificate
   - `BUILD_PROVISION_PROFILE_BASE64`: Your provisioning profile as base64
   - `KEYCHAIN_PASSWORD`: A password for the temporary keychain
   - `APP_STORE_CONNECT_API_KEY_ID`: Your App Store Connect API Key ID
   - `APP_STORE_CONNECT_API_ISSUER_ID`: Your App Store Connect API Issuer ID
   - `APP_STORE_CONNECT_API_KEY_CONTENT`: Your App Store Connect API Key content

3. Create an `ExportOptions.plist` file in your repository with the appropriate settings for your app.





