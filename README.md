In certain scenarios, undertaking the extensive task of migrating or rewriting an entire existing application using Flutter may demand a considerable amount of effort, a factor that companies usually consider before deciding to use Flutter for their projects. To support this, Flutter offers an option of integrating Flutter as a module within an existing application, often referred to as the 'add-to-app'.

This article provides a comprehensive step-by-step guide to seamlessly integrate Flutter module into your iOS SwiftUI project. Furthermore, you will gain insights into establishing communication between Flutter and your existing app through the use of MethodChannel. Let's start!

### 1. Create an iOS native app with SwiftUI from XCode

Begin by setting up a native iOS project, which we'll name `iOSCounterApp`. In this example, let's modify the main view defined in `ContentView.swift` as follows:

```swift
import SwiftUI

struct ContentView: View {
    @State var counter = 0
    
    var body: some View {
        VStack {
            Text("Counter: \(counter)").font(.largeTitle)
            Button(action: {
                increaseCounter()
            }) {
                Text("Increase counter")
                    .font(.headline)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding(.vertical, 8)
            
            Button(action: {
                //TODO: handle opening Flutter screen here
            }) {
                Text("Open Flutter View")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding(.vertical, 10)
        }
        
    }

    func increaseCounter() {
        self.counter+=1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

The application class, `iOSCounterApp.swift`, can remain as is:


```swift
import SwiftUI

@main
struct iOSCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Run the application on an iOS device or simulator to see the following result:

<img width="300" src="https://user-images.githubusercontent.com/104349824/270587842-5ea31f5d-0b5f-4221-be23-9f70092a497a.png" />

### 2. Setting up Flutter module

#### 2.1. Create a Flutter module 

Let's create it in the directory at the same level as your existing iOS project (sibling directories):

```console
➜  iOSCounterApp pwd
/Users/huynq/Desktop/iOSCounterApp

➜  iOSCounterApp flutter create --template  module flutter_counter

➜  iOSCounterApp tree -L 1                                                   
.
├── flutter_counter
└── iOSCounterApp

3 directories, 0 files
```

#### 2.2. Exploring Flutter module

Open `flutter_counter` in IDE and observe something new. Generally, a Flutter module resembles a standard Flutter project.

1. In `pubspec.yaml`, scroll to the end to find a new `module` section. This section identifies the Flutter module:

```yaml
  module:
    androidX: true
    androidPackage: com.example.flutter_counter
    iosBundleIdentifier: com.example.flutterCounter
```

2. Inside the hidden `.ios` directory, you'll notice a new file named `podhelper.rb`. This script manages Pod installation (Flutter engine, plugins, application) and `.framework` (Flutter.framework, App.framework). 

Whenever you add a new plugin to the Flutter module, this script will update it in your existing application.

3. The location of the `.xcconfig` files is slightly different from a typical Flutter project. In a standard Flutter project, you'll find the `.xcconfig` files in the `ios/Flutter` directory:

```console
➜  Flutter tree -L 1            
.
├── AppFrameworkInfo.plist
├── Debug.xcconfig
├── Flutter.podspec
├── Generated.xcconfig
├── Release.xcconfig
└── flutter_export_environment.sh
```

However, in the Flutter module, they are located in two separate directories:


```console
➜  .ios tree -L 2
.
├── Config
│   ├── Debug.xcconfig
│   ├── Flutter.xcconfig
│   └── Release.xcconfig
├── Flutter
│   ├── AppFrameworkInfo.plist
│   ├── FlutterPluginRegistrant
│   ├── Generated.xcconfig
│   ├── README.md
│   ├── flutter_export_environment.sh
│   └── podhelper.rb
```

#### 2.3. Adding dependencies to Flutter module (optional)

You can add Flutter dependencies to module on `pubspec.yaml` file and also implement your code in the `lib/` directory. However, for now, let's keep it as the default counter app and revisit to module directory later.


### 3. Embedding the Flutter module to existing application

First, let's create Podfile in your existing project:

```console
➜  iOSCounterApp cd iOSCounterApp/
➜  iOSCounterApp pod init 
``

Result:

```Ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'iOSCounterApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iOSCounterApp

end
```

Then, update the generated Podfile as follows:

```Ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

flutter_application_path = '../flutter_counter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'iOSCounterApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iOSCounterApp
  install_all_flutter_pods(flutter_application_path)
end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
end
```

Run the following command:


```console
pod install
```

Note: Whenever you add a new plugin to the Flutter module, you'll need to run `pod install` again in the existing project to refresh it.

Finally, re-open existing project. 

You will see there is `.xcworkspace` file as the pod is installed successfully. Now, let's close the opening `.xcodeproj` and open `.xcworkspace` in XCode. You can try running the project again to make sure nothing is broken. If it goes well, you will see it is still the same as before. Now, let's go to the final steps.

Finally, reopen your existing project. You'll notice a new `.xcworkspace` file, indicating that the Pod was successfully installed. Close the existing `.xcodeproj` and open the `.xcworkspace` in Xcode. 

Try running the project to ensure that everything works as expected. If it runs smoothly, the application should appear unchanged as the begins. Now, let's proceed to the final steps.

### 4. Starting Flutter from existing application

To initiate a Flutter view from your existing application, we'll utilize `FlutterEngine` and `FlutterViewController`. The `FlutterEngine` manages the Dart VM and Flutter runtime, while the `FlutterViewController` connects to the `FlutterEngine` and displays rendered frames.

We'll initialize the `FlutterEngine` before using it, aka `pre-warming`. This approach is recommended. Okay, let's do it!

First, create a `FlutterEngine` in `iOSCounterApp.swift`:

```swift
import SwiftUI
import Flutter

class FlutterDependencies: ObservableObject {
    let flutterEngine = FlutterEngine(name: "flutter-engine")
    init() {
        flutterEngine.run()
    }
}

@main
struct iOSCounterApp: App {
    @StateObject var flutterDependencies = FlutterDependencies()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(flutterDependencies)
        }
    }
}
```

Next, update `ContentView.swift` as follows:

```swift
import SwiftUI
import Flutter

struct ContentView: View {
    // Flutter dependencies are passed in an EnvironmentObject.
    @EnvironmentObject var flutterDependencies: FlutterDependencies

    @State var counter = 0
    
    var body: some View {
        VStack {
            Text("Counter: \(counter)").font(.largeTitle)
            Button(action: {
                increaseCounter()
            }) {
                Text("Increase counter")
                    .font(.headline)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding(.vertical, 8)
            
            Button(action: {
                showFlutter()
            }) {
                Text("Open Flutter View")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding(.vertical, 10)
        }
        
    }
    
    func increaseCounter() {
        self.counter+=1
    }

    func showFlutter() {
        // Get RootViewController from window scene
        guard
          let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) as? UIWindowScene,
          let window = windowScene.windows.first(where: \.isKeyWindow),
          let rootViewController = window.rootViewController
        else { return }

        // Create a FlutterViewController from pre-warm FlutterEngine
        let flutterViewController = FlutterViewController(
          engine: flutterDependencies.flutterEngine,
          nibName: nil,
          bundle: nil)
        flutterViewController.modalPresentationStyle = .overCurrentContext
        flutterViewController.isViewOpaque = false

        rootViewController.present(flutterViewController, animated: true)
      }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

Now, we need to update Flutter module code:

```dart
appBar: AppBar(
	title: Text(widget.title),
	actions: [
	  IconButton(
	    onPressed: () => SystemNavigator.pop(animated: true),
	    icon: const Icon(Icons.exit_to_app),
	  ),
	],
),
```

We added a button that enables you to exit the Flutter view with `SystemNavigator.pop`. `SystemNavigator.pop` is used to request Flutter application be popped off navigation stack and return control to the platform-specific host (e.g, Android Activity or iOS ViewController). It's a well-suited API for this purpose.

Now, let's return to the Xcode project with your existing app and run it.

Voila! You can now open a Flutter screen and seamlessly close it. 

<video src="https://user-images.githubusercontent.com/104349824/270621053-3812cfb1-7c5a-48c6-8a84-40078f41efbd.mp4"/>

However, you might have noticed that data is stored separately between the Flutter module and the existing app. If you're wondering how to synchronize or share data between these two portions (Flutter and the existing app), let's delve into the next parts to explore this further.

### 5. Share data between Flutter and existing application

#### 5.1. Existing app implementation

The solution is to use [MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html). You usually see `FlutterMethodChannel` initiation in UIViewController's `viewDidLoad` (UIKit), but there is no equivalent `viewDidLoad` in SwiftUI. 

Here's how we address this.

SwiftUI provides `onAppear` which closely resembles `viewDidLoad`. However, it has limitation, especially when your existing app has multiple views. `onAppear` triggers each time we navigate forward and back to the original view where we intend to initialize the method channel. On Android, it behaves similarly to Activity's `onResume` callback. 

To work around this, we will "cook" `onAppear` to "simulate" `viewDidLoad`. I'd like to acknowledge [Sarun](https://sarunw.com) for his tutorial on this issue, available [here](https://sarunw.com/posts/swiftui-viewdidload/).


Add the following code to `ContentView.swift`:

```swift
struct ViewDidLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
}
```

Next, apply `onViewDidLoad` to outermost view, which in this case is `VStack`:

```swift
VStack {
    // existing code, not paste here as it's long
}.onViewDidLoad {
    handleMethodChannel()
}
```

Now, we've effectively managed the lifecycle issue. Let's complete the remaining steps in `handleMethodChannel()`:

```swift
func handleMethodChannel() {
    flutterMethodChannel = FlutterMethodChannel(name: "flutter_channel/counter", binaryMessenger: flutterDependencies.flutterEngine.binaryMessenger)
    flutterMethodChannel?.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        switch(call.method) {
        case "increaseCounter":
            counter += 1
            submitCounter()
        case "getCounter":
            submitCounter()
        default:
            print("Unrecognized method: \(call.method)")
        }
    })
}

func submitCounter() {
    flutterMethodChannel?.invokeMethod("submitCounter", arguments: counter)
}
```

Additionally, remember to update the changed value (counter) through the method channel as well:

```swift
func increaseCounter() {
    self.counter+=1
    submitCounter()
}
```

#### 5.1. Flutter module implementation


On Flutter side, let's declare a MethodChannel and handle all method calls:

```dart
final _methodChannel = const MethodChannel('flutter_channel/counter');

@override
void initState() {
	super.initState();
	_methodChannel.setMethodCallHandler((call) => _handleMethodCall(call));
	_methodChannel.invokeMethod('getCounter');
}

_handleMethodCall(MethodCall call) {
	if (call.method == 'submitCounter') {
	  setState(() {
	    _counter = call.arguments as int;
	  });
	}
}
```

Also, invoke `increaseCounter` method when increasing counter by tapping on FAB as well:

```dart
void _incrementCounter() {
	setState(() {
	  _counter++;
	});
	_methodChannel.invokeMethod<void>('increaseCounter');
}
```

#### Final result

Voila! Now you can seamlessly communicate between Flutter module and existing app. 

<video src="https://user-images.githubusercontent.com/104349824/270668768-fa405f13-94b7-4fda-ab29-234c0f314fec.mp4"/>

Check out the complete sample code at https://github.com/huynguyennovem/flutter-add-to-app-ios-swiftui

### Conclusion

This article has walked you through the process of integrating a Flutter module into your iOS application, allowing for seamless communication and data exchange. By incorporating Flutter's capabilities within your native iOS project, your team won't have to worry about rewriting your entire app with Flutter, streamlining development and enhancing the user experience.

