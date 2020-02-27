# bikeride

Check bike rack availability on RTS busses.

## Getting Started

  - [Installing Flutter SDK](#chapter-1)
    * [MacOS/Linux](#chapter-1a)
  - [Installing Android Studio](#chapter-2)
    * [MacOS](#chapter-2a)
    * [Linux](#chapter-2b)
  - [Configuring Android Studio](#chapter-3)
  - [Wrapping Up The Installation](#chapter-4)
  - [Cloning The Project](#chapter-5)
    * [Using Android Studio's VCS](#chapter-5a)
    * [Using Git CLI](#chapter-5b)
    * [Manually Adding The Project To Android Studio](#chapter-5c)
  - [Building The Project](#chapter-6)
    * [Ensuring The Project is Functional](#chapter-6a)
    * [Generating App Code](#chapter-6b)
    * [Building The App for Target Devices](#chapter-6c)

### Installing Flutter SDK <a name="chapter-1"></a>

First, download the latest [Flutter SDK](https://flutter.dev/docs/development/tools/sdk/releases) package.

#### MacOS/Linux <a name="chapter-1a"></a>

Once you have that, do

~~~
cd ~/Downloads
sudo mv ./flutter /opt/flutter
~~~
  
to install the application.

If you want to add it to the path, do

~~~
sudo ln -s /opt/flutter/bin/flutter /usr/local/bin/flutter
~~~
  
Now run

~~~
flutter
~~~

to make sure the SDK was installed correctly.

In order to make sure dependencies were installed, run

~~~
flutter precache
~~~

followed by

~~~
flutter doctor --android-licenses
~~~

You must accept the licenses to use Flutter (enter y for all).

### Installing Android Studio <a name="chapter-2"></a>

First, download the latest [Android Studio](https://developer.android.com/studio#downloads) package.

#### MacOS <a name="chapter-2a"></a>

Install the .dmg like you would with any other MacOS application.

#### Linux <a name="chapter-2b"></a>

Once downloaded

~~~
cd ~/Downloads
sudo tar -zxf <ANDROID_STUDIO_PACKAGE_NAME> /opt/
sudo ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio
~~~

to install Android Studio and add it to the executable path.

To add a desktop icon for easy access, run

~~~
android-studio
~~~

and in the GUI, navigate to **Tools -> Desktop Entry** at the top toolbar.

### Configuring Android Studio <a name="chapter-3"></a>

Open Android Studio and go to the **Plugins** section under **Android Studio -> Preferences (⌘,)**.
Search the **Marketplace** for Flutter and download that plugin.

Since we installed the Flutter SDK in /opt/flutter, we will have to make sure Android Studio is aware of the path.

To do this, navigate to **Android Studio -> Preferences (⌘,)**.
Open the **Languages & Frameworks** tab and select **Flutter**.
Under the field *Flutter SDK Path* in the *SDK* block, enter
> /opt/flutter

Then select **Dart** under the **Languages & Frameworks** menu tab.
Under the field *Dart SDK Path*, enter
> /opt/flutter/bin/cache/dart-sdk

Because we are targetting Android Lollipop 5.0 as a minimum requirement, we will need to install the SDK for it manually, as it is no longer default (at time of writing, Android Pie 9.0 is the default).

Under the **Appearance & Behavior** tab, open the **System Settings** tab and select **Android SDK**.
Under **SDK Platforms**, check the box next to *Android 5.0 (Lollipop)* to install it and hit ***Apply***.
Follow the install prompt and wait for completion.

If you do not have a physical Android Lollipop 5.0 device, you also need to install the Android Lollipop 5.0 Emulator.
To do this, navigate to **Tools -> AVD Manager**.

(If this option is missing, try restarting Android Studio to see if additional components need to be installed, specifically Intel HAXM.  You should be prompted on the bottom right hand corner.)

Select ***+ Create Virtual Device*** and select any hardware to emulate (Nexus 5X is a good option) and hit ***Next***.
In the **System Image** page, select the **x86 Images** tab and scroll down to "*Lollipop* Download |*21 * | *x86_64  * | *Android 5.0 (Google APIs)*" and select the *Download* link.
Follow the install prompt and wait for completion.
Once complete, select the system image you just downloaded and hit ***Next***.
On the **Android Virtual Device** page in the *Emulated Performance* block, change the *Graphics* field from *Automatic* to *Hardware - GLES 2.0*.
Hit ***Finish*** to add the device to the AVD list.

### Wrapping Up The Installation <a name="chapter-4"></a>

Once everything else is done, plug in an Android device (and/or iOS device if you are running MacOS) to your computer if you have one handy.

Then run

~~~
flutter doctor
~~~

to see if everything was installed correctly.

If you did not plug in a device, expect

~~~
[!] Connected device
    ! No devices available
~~~

If there are no other errors, everything is properly configured.  Otherwise, follow the instructions that were given by the flutter command to resolve the errors.

### Cloning The Project <a name="chapter-5"></a>

#### Using Android Studio's VCS <a name="chapter-5a"></a>

In the top toolbar, navigate to **Android Studio -> Preferences (⌘,)**.
Open the **Version Control** tab and select GitHub.
Add your GitHub account to the entry list using the ***+*** button at the left hand corner of the table.
Follow the prompts on the display.
Hit ***Apply*** and ***Ok***.

In the top toolbar, navigate to **VCS -> Git -> Clone...**.
Input the URL of this git 
> https://github/austinjkee/bikeride.git

into the field.
Hit ***Clone***.
When prompted to add the newly cloned source as an Android Studio project, select ***Yes***.

If you accidentally selected ***No***, go to the section on [Manually Adding The Project To Android Studio](#chapter-5c).

#### Using Git CLI <a name="chapter-5b"></a>

If you want to use this option, you likely already know how to use Git CLI, but out of an abundance of caution:
~~~
cd <PATH_TO_DEVELOPMENT_WORKSPACE>
git clone https://github/austinjkee/bikeride.git
~~~

#### Manually Adding The Project To Android Studio <a name="chapter-5c"></a>

Manually adding the Flutter project to Android Studio is necessary when using Git CLI or if something went wrong in the automated GUI cloning.

To do so, open Android Studio to the **Welcome to Android Studio** window.

Select the ***Open an existing Android Studio project*** option and navigate to the location of the cloned project.

It should add it properly if Flutter was installed correctly; if Android Studio prompts to use Gradle with the project, something is wrong with the Flutter install and 
~~~
flutter doctor
~~~
should be run to verify.

If the status comes back clean, restart Android Studio and try again.

### Building The Project <a name="chapter-6"></a>

#### Ensuring The Project is Functional <a name="chapter-6a"></a>

The developer Google Maps API key has been removed from the project.

When ready for production, a new Google Maps API must be provided in the following files:

*ios/Runner/AppDelegate.swift*
```swift
    ) -> Bool {
        GMSServices.provideAPIKey("API_KEY_STRING_GOES_HERE")
        GeneratedPluginRegistrant.register(with: self)
```

*android/app/src/main/AndroidManifest.xml*
```xml
    <meta-data android:name="com.google.android.geo.API_KEY"
        android:value="API_KEY_STRING_GOES_HERE"/>
```

#### Generating App Code <a name="chapter-6b"></a>

Once the project has been given a valid Google Maps API key, you can build the program from the flutter source to the target device native code.

In Android Studio's Terminal or in your preferred shell environment, navigate to the main directory of the project and run:
```
flutter build
```

This will generate the necessary code for app creation.

#### Building The App for Target Devices <a name="chapter-6c"></a>

**Disclaimer** - Building an iOS version of the application requires an Apple computer with at least macOS Mojave/Xcode 11.3 for up to iOS 13.2 and macOS Catalina/Xcode 11.4 for iOS 13.3 and above.

To actually build the application binaries for target devices, first make sure you have a valid device attached, either physical or virtual (simulators).

**Android Minimum Requirements**
OS: Marshmallow 6.0 (API 23)
Physical: 64-bit ARMv8 Compatible CPU
Software: Google Play Services Enabled

**iOS Minimum Requirements**
OS: iOS 12.4.5
Physical: iPhone 5S (Apple A7) or newer
Software: macOS Mojave/Xcode 11.3, macOS Catalina/Xcode 11.4 Preferred

*The application can theoretically be built for iPad, Apple TV, Android TV, and as a WebApp, but they are considered niche use cases and will not be covered here.*

To make sure the device is attached and recognized, in Android Studio's Terminal or in your preferred shell environment, run:
```bash
flutter doctor
```
Once you have verified that you have a device attached, proceed with running the flutter native builder.

Optionally, you may verify that the app builds correctly before bundling.

In Android Studio's Terminal or in your preferred shell environment, navigate to the main directory of the project and run:
```bash
flutter run
```

It should run on the attached device and all features should work as long as the minimum requirements are met.

To build a bundle for release, the package must be signed with a production key.  Further instructions for release can be found here:
<link>https://flutter.dev/docs/deployment/android</link>


