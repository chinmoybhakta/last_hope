# 🔍 Debugging Guide: Black Screen Issue

## 📋 What I've Added for Debugging

### 1. **Comprehensive Logging** 📝
I've added detailed debug logs throughout the app to track the exact flow:

#### **App Initialization:**
- 🚀 `OfflineMapApp: Building app`
- 🏠 `MainScreen: initState called`
- 🏠 `MainScreen: Building with index X`

#### **Navigation Flow:**
- 🏠 `MainScreen: Bottom nav tapped index X`
- 🏠 `MainScreen: Page changed to index X`

#### **Map Screen:**
- 🗺️ `MapScreen: initState called`
- 🗺️ `MapScreen: Building widget...`
- 🗺️ `MapScreen: Center: [coordinates]`
- 🗺️ `MapScreen: Zoom: [level]`
- 🗺️ `MapScreen: Current: [location]`
- 🗺️ `MapScreen: Destination: [destination]`
- 🗺️ `MapScreen: Route length: [count]`

#### **Location Service:**
- 🔍 `Starting location acquisition...`
- ✅ `Location services are enabled`
- 📋 `Current permission: [permission]`
- ✅ `Starting position acquisition...`
- 📍 `Location acquired: [lat, lng]`

#### **Search Screen:**
- 🔍 `SearchScreen: initState called`
- 🔍 `SearchScreen: Loading country data...`
- 🌍 `CountryDataService: Loading data from assets...`
- 🌍 `CountryDataService: Loaded [count] countries`

#### **Search Results:**
- 🔍 `SearchResultsList: Building widget...`
- 🔍 `SearchResultsList: Results count: [count]`
- 🔍 `SearchResultsList: Tapped on [name]`
- 🔍 `SearchResultsList: Navigation triggered for [name]`

### 2. **Error Boundary** 🐛
- Added `DebugErrorWidget` that catches and displays any widget errors
- Shows detailed error information on screen instead of black screen
- Logs all errors with stack traces

### 3. **Enhanced Error Handling** ⚠️
- Location service now has timeout (15 seconds)
- Comprehensive try-catch blocks with stack traces
- Better permission handling

## 🔧 How to Debug the Black Screen

### **Step 1: Run the App with Logs**
```bash
flutter run --debug
```

### **Step 2: Watch the Console Carefully**
Look for these specific log patterns:

#### **If you see:**
```
🗺️ MapScreen: Building widget...
```
**Then:** The map screen is building correctly

#### **If you see:**
```
❌ Error getting location: [error]
```
**Then:** Location services are failing

#### **If you see:**
```
🌍 CountryDataService: Error loading data: [error]
```
**Then:** Country data loading is failing

#### **If you see:**
```
🐛 ERROR in [widget]: [exception]
```
**Then:** A widget error occurred (will show on screen)

### **Step 3: Common Issues & Solutions**

#### **Issue 1: Location Permission Denied**
**Logs:** `❌ Location permissions are denied`
**Solution:** 
- Check app permissions in Android settings
- Grant location permission manually

#### **Issue 2: Country Data Loading Failed**
**Logs:** `❌ CountryDataService: Error loading data`
**Solution:**
- Check if `assets/global_full_dataset.json` exists
- Verify file path in `pubspec.yaml`

#### **Issue 3: Network Issues**
**Logs:** `❌ Failed host lookup: 'tile.openstreetmap.org'`
**Solution:**
- Check internet connection
- Try offline mode

#### **Issue 4: Widget Rendering Error**
**Logs:** `🐛 ERROR in [widget]: [exception]`
**Solution:**
- Check the red error screen that appears
- Look at the stack trace in logs

### **Step 4: Test Specific Scenarios**

#### **Test 1: App Startup**
1. Launch app
2. Check for: `🚀 OfflineMapApp: Building app`
3. Check for: `🏠 MainScreen: Building with index 0`

#### **Test 2: Search Navigation**
1. Tap search tab
2. Check for: `🏠 MainScreen: Bottom nav tapped index 1`
3. Check for: `🔍 SearchScreen: Building widget...`
4. Type search query
5. Check for: `🔍 SearchBarWidget: Found [count] results`

#### **Test 3: Navigation Trigger**
1. Tap on search result
2. Check for: `🔍 SearchResultsList: Navigation triggered for [name]`
3. Check for: `🗺️ MapScreen: Destination: [destination]`

## 🎯 What to Look For

### **Black Screen Causes:**
1. **Location Service Timeout** - No GPS signal
2. **Map Rendering Error** - FlutterMap issue
3. **Asset Loading Failure** - Missing JSON file
4. **Permission Issues** - Location/data permissions
5. **Network Timeout** - Tile loading failure

### **Success Indicators:**
- ✅ All emoji logs appear in sequence
- 🗺️ Map screen builds without errors
- 🔍 Search results load correctly
- 📍 Location is acquired successfully

## 📱 Testing on Device

1. **Enable Debug Logging:**
   ```bash
   flutter run --debug --verbose
   ```

2. **Monitor LogCat:**
   ```bash
   adb logcat -s flutter
   ```

3. **Check App Permissions:**
   - Location: Fine & Coarse
   - Storage: Read/Write
   - Network: Internet

## 🆘 If Still Black Screen

1. **Share the complete log output** from app launch
2. **Note exactly when** the black screen appears
3. **Check if any red error screen** shows up
4. **Try different search terms** to isolate the issue

The comprehensive logging will help us pinpoint exactly where the issue occurs! 🎯
