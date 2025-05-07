# Women Business Directory - Test Plan

## 1. Introduction

### 1.1 App Overview
The Women Business Directory is an iOS application designed to showcase businesses owned by immigrant women entrepreneurs. The app allows users to browse businesses by category, view detailed business information, and connect with entrepreneurs. Entrepreneurs can create profiles and list their businesses.

### 1.2 Test Objectives
- Verify all app functionality works as expected
- Ensure good user experience across different iOS devices
- Validate data integrity and Firebase integration
- Confirm app stability and performance
- Identify and address potential issues before App Store submission

### 1.3 Testing Scope
**In Scope:**
- User authentication and profile management
- Business directory browsing and filtering
- Business creation and management
- Profile completion validation
- Map integration
- Image uploading and display
- Navigation and UI

**Out of Scope:**
- Server-side Firebase testing
- Stress testing with thousands of users
- Testing on beta iOS versions

## 2. Test Environment

### 2.1 Device Matrix
| Device | iOS Version | Physical/Simulator | Notes |
|--------|-------------|-------------------|-------|
| iPhone 14 Pro | iOS 16.5+ | Physical | Primary test device |
| iPhone SE (2nd gen) | iOS 16.5+ | Physical | Smaller screen testing |
| iPhone 12 | iOS 16.5+ | Simulator | Medium screen testing |
| iPad Pro | iOS 16.5+ | Simulator | Tablet compatibility check |

### 2.2 Network Conditions
- Wi-Fi connection (high speed)
- Cellular data (4G/5G)
- Slow network (throttled)
- Offline/airplane mode

### 2.3 Firebase Environment
- Test using development Firebase project
- Verify final testing on production Firebase project

## 3. Test Types

### 3.1 Functional Testing
- Verify all features work according to requirements
- Test all user workflows from start to finish
- Validate input fields, buttons, and interactive elements
- Confirm proper data storage and retrieval

### 3.2 UI/UX Testing
- Verify UI elements display correctly on all screen sizes
- Test light/dark mode appearances
- Check that animations and transitions work smoothly
- Verify accessibility features (text scaling, VoiceOver support)

### 3.3 Performance Testing
- Measure app launch time
- Check responsiveness during scrolling long lists
  - Test rapid flick scrolling through Directory with 50+ companies
  - Monitor frame rate drops using Instruments Time Profiler
  - Verify smooth deceleration when releasing a scroll
  - Check for UI thread blocking during image loading while scrolling
  - Test scrolling performance with and without cached images
- Verify image loading performance
- Test app behavior with large datasets

### 3.4 Network Testing
- Verify app behavior during network transitions (wifi to cellular)
- Test app behavior when offline
- Verify data synchronization when connection is restored
- Check handling of network errors

### 3.5 Security Testing
- Verify secure storage of user credentials
- Test authentication mechanisms
- Validate proper access restrictions
- Check data protection measures

### 3.6 Unit Testing
The following unit tests have been implemented to test the core functionality of the app:

#### 3.6.1 Company Model Tests
- **Initialization Tests**: Verify that Company objects are created correctly with all properties properly set
- **Social Media Tests**: Validate the computed socialMedias property works with and without data
- **Equality Tests**: Confirm that Company objects with the same ID are considered equal regardless of other properties

#### 3.6.2 Entrepreneur Manager Tests
- **Entrepreneur Creation Tests**: Validate creating and retrieving entrepreneur profiles
- **Company Association Tests**: Test adding and removing companies from entrepreneur profiles
- **Entrepreneur Update Tests**: Verify entrepreneur information can be updated correctly
- **Error Handling Tests**: Validate proper handling of not-found scenarios

#### 3.6.3 Companies List View Model Tests
- **Search Filter Tests**: Verify search functionality works correctly with company names and descriptions
- **City Filter Tests**: Test filtering companies by city with proper standardization of city names
- **Ownership Type Tests**: Validate filtering by various business ownership types
- **Combined Filtering Tests**: Test scenarios with multiple simultaneous filter criteria

#### 3.6.4 Info View Model Tests
- **Data Loading Tests**: Verify entrepreneur data is loaded correctly
- **Error Handling Tests**: Test proper handling of loading failures
- **Not Found Tests**: Validate behavior when entrepreneur records aren't found
- **Loading State Tests**: Confirm proper management of loading state indicators

These unit tests provide automated verification of the app's core business logic and data handling capabilities, helping to catch regressions quickly during development.

## 4. Test Schedule

### 4.1 Testing Phases
| Phase | Duration | Focus Areas |
|-------|----------|------------|
| Alpha Testing | 1 week | Core functionality, major workflows |
| Beta Testing | 2 weeks | Edge cases, integration points, minor features |
| Final Testing | 1 week | Regression testing, performance validation |

### 4.2 Resources and Responsibilities
- Developer Testing: Developer team
- QA Testing: Testing team/stakeholders
- Beta Testing: Small group of real users

### 4.3 Exit Criteria
- All critical and high-priority test cases pass
- No known crashes or critical bugs
- All UI/UX issues addressed
- Performance metrics meet expectations
- Firebase integration verified

## 5. Risk Assessment

### 5.1 Critical User Flows
1. User authentication (high risk)
2. Profile completion (high risk)
3. Business creation (high risk)
4. Image upload and display (medium risk)
5. Map integration (medium risk)

### 5.2 Potential Problem Areas
- Network-dependent functionality
- Image handling and caching
- Firebase data synchronization
- MapKit integration
- Profile completion validation logic

### 5.3 Mitigation Strategies
- Implement robust error handling
- Add appropriate loading indicators
- Develop offline capabilities where possible
- Ensure proper validation of user inputs
- Add comprehensive logging for troubleshooting

## 6. Test Cases

### Authentication Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| AUTH-001 | Email Sign-up | Test user registration with email | App installed, network available | 1. Open app<br>2. Tap "Sign up"<br>3. Enter email/password<br>4. Tap "Create Account" | Account created, user directed to profile completion | - | - |
| AUTH-002 | Email Sign-in | Test user login with email | User account exists | 1. Open app<br>2. Enter email/password<br>3. Tap "Sign In" | User successfully logged in, sees Directory view if profile complete | - | - |
| AUTH-003 | Google Sign-in | Test Google authentication | Google account available | 1. Open app<br>2. Tap "Continue with Google"<br>3. Select Google account | User authenticated, profile created if new user | - | - |
| AUTH-004 | Apple Sign-in | Test Apple authentication | Apple ID available | 1. Open app<br>2. Tap "Continue with Apple"<br>3. Confirm Apple ID | User authenticated, profile created if new user | - | - |
| AUTH-005 | Skip Authentication | Test guest access | App installed | 1. Open app<br>2. Tap "Skip" | User enters app with limited functionality | - | - |
| AUTH-006 | Sign Out | Test sign out functionality | User signed in | 1. Navigate to Profile<br>2. Tap Settings<br>3. Tap "Sign Out" | User signed out, returned to auth screen | - | - |

### Profile Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| PROF-001 | Profile Completion Detection | Test if app detects incomplete profile | New user account | 1. Sign in with new account<br>2. Observe initial screen | Redirected to Profile view with completion banner | - | - |
| PROF-002 | Profile Image Upload | Test profile image upload | User signed in | 1. Go to Profile<br>2. Tap profile image<br>3. Select photo<br>4. Confirm upload | Profile image updated successfully | - | - |
| PROF-003 | Profile Information Update | Test editing profile info | User signed in | 1. Go to Profile<br>2. Tap edit<br>3. Update fields<br>4. Save changes | Profile information updated successfully | - | - |
| PROF-004 | Bio Addition | Test adding entrepreneur bio | User signed in | 1. Go to Profile<br>2. Tap edit<br>3. Enter bio<br>4. Save changes | Bio displayed on profile | - | - |
| PROF-005 | Profile Completion Validation | Verify correct completion status | User with partial profile | 1. Complete different profile elements<br>2. Check completion banner visibility | Banner disappears when profile is complete | - | - |

### Directory Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| DIR-001 | Category Display | Test business categories listing | App with data | 1. Go to Directory<br>2. Observe categories | Categories display with correct count | - | - |
| DIR-002 | Business Listing | Test business listing by category | App with data | 1. Go to Directory<br>2. Select a category<br>3. View business list | Businesses in selected category displayed | - | - |
| DIR-003 | Filter by City | Test city filtering | App with data | 1. Go to Directory<br>2. Tap filter<br>3. Select city<br>4. Apply filter | Only businesses in selected city shown | - | - |
| DIR-004 | Filter by Ownership | Test ownership type filtering | App with data | 1. Go to Directory<br>2. Tap filter<br>3. Select ownership type<br>4. Apply filter | Only businesses with selected ownership shown | - | - |
| DIR-005 | Multiple Filters | Test combined filtering | App with data | 1. Go to Directory<br>2. Apply city filter<br>3. Apply ownership filter | Businesses matching all criteria shown | - | - |
| DIR-006 | Filter Reset | Test clearing filters | Filters applied | 1. Go to Directory<br>2. Tap filter<br>3. Tap "Reset Filters" | All businesses shown, filter count reset | - | - |

### Business Management Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| BIZ-001 | Add Company | Test adding a new company | User signed in | 1. Go to Profile<br>2. Tap "Add Company"<br>3. Fill all fields<br>4. Save | New company added to profile | - | - |
| BIZ-002 | Edit Company | Test editing company details | User with company | 1. Go to Profile<br>2. Select company<br>3. Tap edit<br>4. Modify fields<br>5. Save | Company details updated | - | - |
| BIZ-003 | Delete Company | Test company deletion | User with company | 1. Go to Profile<br>2. Select company<br>3. Tap delete<br>4. Confirm | Company removed from profile | - | - |
| BIZ-004 | Add Company Images | Test adding company images | User adding company | 1. During company creation<br>2. Add logo<br>3. Add header<br>4. Add portfolio images | All images upload successfully | - | - |
| BIZ-005 | Business Categories | Test category selection | User adding company | 1. During company creation<br>2. Select multiple categories<br>3. Save | Company appears in all selected categories | - | - |

### Company Detail Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| DETAIL-001 | Company Info Display | Test company details view | App with data | 1. Go to Directory<br>2. Select a company<br>3. View details | All company info displayed correctly | - | - |
| DETAIL-002 | Map Integration | Test map functionality | Company with address | 1. View company details<br>2. Go to Map tab<br>3. Check map display | Location pinned correctly on map | - | - |
| DETAIL-003 | Contact Actions | Test contact functionality | Company with contact info | 1. View company details<br>2. Tap email<br>3. Tap phone | Correct apps open for contact | - | - |
| DETAIL-004 | Image Gallery | Test portfolio images | Company with images | 1. View company details<br>2. Go to Products tab<br>3. Tap an image | Image enlarges, can zoom/pan | - | - |
| DETAIL-005 | Bookmark Company | Test bookmarking | User signed in | 1. View company details<br>2. Tap bookmark icon | Company added to bookmarks list | - | - |

### Entrepreneurs Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| ENT-001 | Entrepreneurs List | Test entrepreneurs listing | App with data | 1. Go to Entrepreneurs tab<br>2. Scroll through list | Entrepreneurs displayed correctly | - | - |
| ENT-002 | Entrepreneur Profile | Test viewing other profiles | App with data | 1. Go to Entrepreneurs tab<br>2. Select an entrepreneur | Profile displayed with companies | - | - |
| ENT-003 | Profile Navigation | Test navigation from profile | Viewing entrepreneur | 1. View entrepreneur profile<br>2. Select a company | Company details displayed correctly | - | - |

### Performance Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| PERF-001 | App Launch Time | Test startup performance | Fresh app install | 1. Close app completely<br>2. Open app<br>3. Time until interactive | App launches in under 3 seconds | - | - |
| PERF-002 | Image Loading | Test image loading performance | App with data | 1. Navigate to image-heavy screens<br>2. Observe loading | Images load smoothly with placeholders | - | - |
| PERF-003 | Scrolling Performance | Test list scrolling | App with data | 1. Go to Directory<br>2. Scroll rapidly through lists | Smooth scrolling without stutters | - | - |
| PERF-004 | Memory Usage | Test memory management | App running for extended time | 1. Use app extensively<br>2. Navigate between screens<br>3. View many images | No excessive memory usage or crashes | - | - |
| PERF-005 | Fast Scroll Gesture | Test rapid scrolling in long lists | App with 50+ companies | 1. Go to Directory<br>2. Select a category with many companies<br>3. Perform rapid flick scrolling<br>4. Observe scrolling behavior | Scrolling remains smooth at 60 FPS, no visual stuttering | - | - |
| PERF-006 | Scrolling with Image Loading | Test scrolling while images load | Fresh app install, clear cache | 1. Go to Directory<br>2. Quickly scroll through list<br>3. Observe image loading during scroll | UI remains responsive, scrolling doesn't stutter when images load | - | - |
| PERF-007 | Scroll Deceleration | Test smooth scroll deceleration | App with data | 1. Go to Company list<br>2. Perform quick flick gesture<br>3. Observe how scrolling decelerates | Smooth deceleration without jitter or sudden stops | - | - |
| PERF-008 | Frame Rate Monitoring | Use Instruments to measure scroll performance | Development build with Instruments | 1. Connect app to Instruments<br>2. Use Time Profiler<br>3. Monitor frame rate during scrolling | Sustained 58-60 FPS during scrolling, no significant drops | - | Developer tool |

### Network Module

| ID | Test Case | Description | Preconditions | Test Steps | Expected Results | Status | Notes |
|----|-----------|-------------|--------------|------------|------------------|--------|-------|
| NET-001 | Offline Mode | Test app behavior offline | App with data | 1. Use app normally<br>2. Enable airplane mode<br>3. Continue using app | Graceful handling, cached data available | - | - |
| NET-002 | Network Reconnection | Test reconnection behavior | App in offline mode | 1. Use app in offline mode<br>2. Disable airplane mode<br>3. Continue using app | App reconnects, syncs data automatically | - | - |
| NET-003 | Poor Network | Test slow connection behavior | Network throttling enabled | 1. Use app on slow network<br>2. Perform various actions | Loading indicators shown, operations complete | - | - |

## 7. Bug Tracking and Reporting

### 7.1 Bug Report Template
When documenting bugs, include:
- Bug ID
- Description
- Steps to reproduce
- Expected vs. actual result
- Device and iOS version
- Screenshots/recordings
- Severity level (Critical, High, Medium, Low)

### 7.2 Issue Severity Levels
- **Critical**: App crashes, data loss, cannot proceed
- **High**: Major feature broken, workaround difficult
- **Medium**: Feature partially broken, has workaround
- **Low**: Minor UI issues, cosmetic problems

## 8. Test Execution Log

| Date | Tester | Test Cases | Results | Issues Found | Notes |
|------|--------|------------|---------|--------------|-------|
|      |        |            |         |              |       |

## 9. Test Completion Report

To be completed after testing:

### 9.1 Test Coverage Summary
- Total test cases: 
- Executed test cases:
- Pass rate:
- Test areas covered:
  - UI/UX functionality
  - Business logic
  - Data handling
  - Unit tests (including models, managers, view models)

### 9.2 Unit Test Coverage
The following unit tests have been implemented and are running successfully:

| Test Category | Tests Implemented | Tests Passing | Coverage Areas |
|---------------|------------------|--------------|----------------|
| Company Model | 3 | 3 | Initialization, social media properties, equality |
| Entrepreneur Manager | 5 | 5 | Creation, retrieval, company associations, updates, error handling |
| Companies List View Model | 4 | 4 | Search filtering, city filtering, ownership filtering, combined filters |
| Info View Model | 4 | 4 | Data loading, error handling, not-found handling, loading states |

### 9.3 Outstanding Issues
- Critical issues:
- High priority issues:
- Medium priority issues:
- Low priority issues:

### 9.4 Recommendations
- Release readiness assessment
- Suggested improvements
- Follow-up testing needs

---

## Appendix: Test Data

### A.1 Test User Accounts
| Email | Password | Profile Status | Notes |
|-------|----------|----------------|-------|
| test1@example.com | testpass1 | Complete | Has multiple businesses |
| test2@example.com | testpass2 | Incomplete | Missing profile photo |
| test3@example.com | testpass3 | Empty | New user |

### A.2 Test Business Data
| Name | Category | Location | Notes |
|------|----------|----------|-------|
| Tech Solutions | Technology | Toronto | Complete with images |
| Green Garden | Services | Vancouver | No portfolio images |
| Creative Design | Art & Design | Montreal | Multiple categories |
