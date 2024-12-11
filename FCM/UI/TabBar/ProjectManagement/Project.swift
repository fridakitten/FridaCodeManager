 /* 
 Project.swift 

 Copyright (C) 2023, 2024 SparkleChan and SeanIsTethered 
 Copyright (C) 2024 fridakitten 

 This file is part of FridaCodeManager. 

 FridaCodeManager is free software: you can redistribute it and/or modify 
 it under the terms of the GNU General Public License as published by 
 the Free Software Foundation, either version 3 of the License, or 
 (at your option) any later version. 

 FridaCodeManager is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of 
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 GNU General Public License for more details. 

 You should have received a copy of the GNU General Public License 
 along with FridaCodeManager. If not, see <https://www.gnu.org/licenses/>. 

  ______    _     _         _____        __ _                           ______                    _       _   _
 |  ___|  (_)   | |       /  ___|      / _| |                          |  ___|                  | |     | | (_)
 | |_ _ __ _  __| | __ _  \ `--.  ___ | |_| |___      ____ _ _ __ ___  | |_ ___  _   _ _ __   __| | __ _| |_ _  ___  _ __
 |  _| '__| |/ _` |/ _` |  `--. \/ _ \|  _| __\ \ /\ / / _` | '__/ _ \ |  _/ _ \| | | | '_ \ / _` |/ _` | __| |/ _ \| '_ \
 | | | |  | | (_| | (_| | /\__/ / (_) | | | |_ \ V  V / (_| | | |  __/ | || (_) | |_| | | | | (_| | (_| | |_| | (_) | | | |
 \_| |_|  |_|\__,_|\__,_| \____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___| \_| \___/ \__,_|_| |_|\__,_|\__,_|\__|_|\___/|_| |_|
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */ 
    
import Foundation

struct Project: Identifiable, Equatable {
    let id: UUID = UUID()
    var Name: String
    var BundleID: String
    var Version: String
    var ProjectPath: String
    var Executable: String
    var Macro: String
    var SDK: String
    var TG: String
    var TYPE: String

    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.Name == rhs.Name &&
               lhs.BundleID == rhs.BundleID &&
               lhs.Version == rhs.Version &&
               lhs.ProjectPath == rhs.ProjectPath &&
               lhs.Executable == rhs.Executable &&
               lhs.Macro == rhs.Macro &&
               lhs.SDK == rhs.SDK &&
               lhs.TG == rhs.TG &&
               lhs.TYPE == rhs.TYPE
    }
}

/*func GetProjects() -> [Project] {
    do {
        var Projects: [Project] = []

        for Item in try FileManager.default.contentsOfDirectory(atPath: global_documents) {
            if Item == "Inbox" || Item == "savedLayouts.json" || Item == ".sdk" || Item == ".cache" || Item == "virtualFS.dat" {
                continue
            }

            do {
                let infoPlistPath = "\(global_documents)/\(Item)/Resources/Info.plist"
                let dontTouchMePlistPath = "\(global_documents)/\(Item)/Resources/DontTouchMe.plist"

                var BundleID = "Corrupted"
                var Version = "Unknown"
                var Executable = "Unknown"
                var Macro = "stable"
                var TG = "Unknown"
                var SDK = "Unknown"
                var TYPE = "Applications"

                if let Info = NSDictionary(contentsOfFile: infoPlistPath) {
                    if let extractedBundleID = Info["CFBundleIdentifier"] as? String {
                        BundleID = extractedBundleID
                    }
                    if let extractedVersion = Info["CFBundleVersion"] as? String {
                        Version = extractedVersion
                    }
                    if let extractedExecutable = Info["CFBundleExecutable"] as? String {
                        Executable = extractedExecutable
                    }
                    if let extractedTG = Info["MinimumOSVersion"] as? String {
                        TG = extractedTG
                    }
                }

                if let Info2 = NSDictionary(contentsOfFile: dontTouchMePlistPath) {
                    if let extractedSDK = Info2["SDK"] as? String {
                        SDK = extractedSDK
                    }
                    if let extractedTYPE = Info2["TYPE"] as? String {
                        TYPE = extractedTYPE
                    }
                    if let extractedMacro = Info2["CMacro"] as? String {
                        Macro = extractedMacro
                    }
                }
                Projects.append(Project(Name: Item, BundleID: BundleID, Version: Version, ProjectPath: "\(global_documents)/\(Item)", Executable: Executable, Macro: Macro, SDK: SDK, TG: TG, TYPE: TYPE))
            } catch {
                print("Failed to process item: \(Item), error: \(error)")
                Projects.append(Project(Name: "Corrupted", BundleID: "Corrupted", Version: "Unknown", ProjectPath: "\(global_documents)/\(Item)", Executable: "Unknown", Macro: "", SDK: "Unknown", TG: "Unknown", TYPE: "Unknown"))
            }
        }
        return Projects
    } catch {
        print(error)
        return []
    }
}*/

func MakeApplicationProject(_ Name: String, _ BundleID: String, type: Int) -> Int {
    let v2uuid: UUID = UUID()
    let SDK: String = UserDefaults.standard.string(forKey: "sdk") ?? "iPhoneOS15.6.sdk"
    let TYPE: String = {
        switch type {
            case 1, 2, 3, 5:
                return "Applications"
            case 4:
                return "Utilities"
            case 6:
                return "Sean16"
            default:
                return "Applications"
        }
    }()

    do {
        let ResourcesPath = "\(global_documents)/\(v2uuid)/Resources"
        try FileManager.default.createDirectory(atPath: ResourcesPath, withIntermediateDirectories: true)

        let infoPlistData: [String: Any] = [
            "CFBundleExecutable": Name,
            "CFBundleIdentifier": BundleID,
            "CFBundleName": Name,
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1.0",
            "MinimumOSVersion": gosver() ?? "15.0",
        ]

        let infoPlistPath = "\(ResourcesPath)/Info.plist"
        let infoPlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: infoPlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: infoPlistPath, contents: infoPlistDataSerialized, attributes: nil)

        let dontTouchMePlistData: [String: Any] = [
            "SDK": SDK,
            "TYPE": TYPE,
            "CMacro": "stable",
            "Macro": [
                "stable": [:],
                "debug": [:],
            ]
        ]

        let dontTouchMePlistPath = "\(ResourcesPath)/DontTouchMe.plist"
        let dontTouchMePlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: dontTouchMePlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: dontTouchMePlistPath, contents: dontTouchMePlistDataSerialized, attributes: nil)

        switch(type) {
            case 1: // Swift App
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data("\(authorgen(file: "My App.swift"))import SwiftUI\n\n@main\nstruct MyApp: App {\n    var body: some Scene {\n        WindowGroup {\n            ContentView()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data("\(authorgen(file: "ContentView.swift"))import SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n    }\n}".utf8))
                break
            case 2: // ObjC App
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: Data("\(authorgen(file: "main.m"))#import <Foundation/Foundation.h>\n#import \"myAppDelegate.h\"\n\nint main(int argc, char *argv[]) {\n\t@autoreleasepool {\n\t\treturn UIApplicationMain(argc, argv, nil, NSStringFromClass(myAppDelegate.class));\n\t}\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myAppDelegate.h", contents: Data("\(authorgen(file: "myAppDelegate.h"))#import <UIKit/UIKit.h>\n \n@interface myAppDelegate : UIResponder <UIApplicationDelegate>\n \n@property (nonatomic, strong) UIWindow *window;\n@property (nonatomic, strong) UINavigationController *rootViewController;\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myAppDelegate.m", contents: Data("\(authorgen(file: "myAppDelegate.m"))#import \"myAppDelegate.h\"\n#import \"myRootViewController.h\"\n\n@implementation myAppDelegate\n\n- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {\n\t_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];\n\t_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[myRootViewController alloc] init]];\n\t_window.rootViewController = _rootViewController;\n\t[_window makeKeyAndVisible];\n\treturn YES;\n}\n\n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.h", contents: Data("\(authorgen(file: "myRootViewController.h"))#import <UIKit/UIKit.h>\n \n@interface myRootViewController : UIViewController\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.m", contents: Data("\(authorgen(file: "myRootViewController.m"))#import \"myRootViewController.h\"\n@interface myRootViewController () <UITableViewDataSource>\n@property (nonatomic, strong) UITableView *logTableView;\n@property (nonatomic, strong) NSMutableArray *logEntries;\n@end\n@implementation myRootViewController\n- (void)viewDidLoad {\n    [super viewDidLoad];\n    self.title = @\"ObjectiveC support!\";\n    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];\n    self.logTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];\n    self.logTableView.dataSource = self;\n    [self.view addSubview:self.logTableView];\n    self.logEntries = [NSMutableArray array];\n}\n- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n    return self.logEntries.count;\n}\n- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n    static NSString *CellIdentifier = @\"Cell\";\n    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];\n    if (!cell) {\n        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];\n    }\n    cell.textLabel.text = self.logEntries[indexPath.row];\n    return cell;\n}\n- (void)addButtonTapped:(id)sender {\n    @try {\n        NSString *logEntry = @\"Hello, World!\";\n        [self.logEntries insertObject:logEntry atIndex:0];\n        [self.logTableView reloadData];\n    } @catch (NSException *exception) {\n        NSLog(@\"Exception: %@\", exception);\n    } @finally {\n        NSLog(@\"Add button tapped\");\n    }\n}\n@end".utf8))
                break
            case 3: // Swift/ObjC App
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data("\(authorgen(file: "My App.swift"))import SwiftUI\n\n@main\nstruct MyApp: App {\n    var body: some Scene {\n        WindowGroup {\n            ContentView()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data("\(authorgen(file: "ContentView.swift"))import Foundation\nimport SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n       Text(hello())\n    }\n    func hello() -> String {\n        let myObjCInstance = MyObjectiveCClass()\n        return myObjCInstance.hello()\n    }\n}".utf8))
                FileManager.default.createFile(atPath:"\(global_documents)/\(v2uuid)/bridge.h", contents: Data("\(authorgen(file: "bridge.h"))#import \"main.h\"".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.h", contents: Data("\(authorgen(file: "main.h"))#import <Foundation/Foundation.h>\n@interface MyObjectiveCClass : NSObject\n- (NSString *)hello;\n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: Data("\(authorgen(file: "main.m"))#import \"main.h\"\n@implementation MyObjectiveCClass\n- (NSString *)hello {\n    return @\"Hello ObjectiveC World!\";\n}\n@end".utf8))
                break
            case 4: // C Binary
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.c", contents: Data("\(authorgen(file: "main.c"))#include <stdio.h>\n\nint main(void) {\n    printf(\"Hello, World\");\n}".utf8))
                break
            case 5: // Swift/C++ App
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data("\(authorgen(file: "My App.swift"))import SwiftUI\n\n@main\nstruct MyApp: App {\n    var body: some Scene {\n        WindowGroup {\n            ContentView()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data("\(authorgen(file: "ContentView.swift"))import Foundation\nimport SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        Button(\"Test\") {\n            test()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath:"\(global_documents)/\(v2uuid)/bridge.h", contents: Data("\(authorgen(file: "bridge.h"))int test();".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.cpp", contents: Data("\(authorgen(file: "main.cpp"))#include <iostream>\n\nextern \"C\" {\n\nint test() {\n    std::cout << \"Hello, World!\" << std::endl;\n    return 0;\n}\n\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/api.api", contents: Data("<api>\n    <version>1.1</version>\n    <build>-lc -lc++</build>\n</api>".utf8))
                break
            default:
                return 2
        }

        var entitlementsPlistData: [String: Any] = [ "platform-application": true ]
        if type == 4 {
            entitlementsPlistData = [
                "platform-application": true,
                "com.apple.private.security.no-sandbox": true
            ]
        }

        let entitlementsPlistPath = "\(global_documents)/\(v2uuid)/entitlements.plist"
        let entitlementsPlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: entitlementsPlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: entitlementsPlistPath, contents: entitlementsPlistDataSerialized, attributes: nil)
    } catch {
        print(error)
        return 1
    }

    return 0
}

func authorgen(file: String) -> String {
    let author = UserDefaults.standard.string(forKey: "Author")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yy"
    let currentDate = Date()
    return "//\n// \(file)\n//\n// Created by \(author ?? "Anonym") on \(dateFormatter.string(from: currentDate))\n//\n \n"
}

func importProj(target: String) -> Void {
    let v2uuid: String = "\(UUID())"

    if FileManager.default.fileExists(atPath: target) {
        if libzip_unzip(target, "\(global_container)/tmp/\(v2uuid)") != 0 {
            return
        }
    } else {
        return
    }
    cfolder(atPath: "\(global_container)/tmp/\(v2uuid)")
    let content: [URL] = try! FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "\(global_documents)/../tmp/\(v2uuid)"), includingPropertiesForKeys: nil)
    let projpath: String = content[0].path
    _ =  mv("\(projpath)", "\(global_documents)/\(v2uuid)")
    _ = rm("\(global_container)/tmp/\(v2uuid)")
}
