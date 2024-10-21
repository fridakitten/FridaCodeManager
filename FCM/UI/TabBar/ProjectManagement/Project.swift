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
 */ 
    
import Foundation

struct Project: Identifiable {
    let id = UUID()              // UUID v2 Project Identifier
    var Name: String             // Name of the Project
    var BundleID: String         // BundleID of the Project(App)
    var Version: String          // Version of the Project(App)
    var ProjectPath: String      // Path of the Project
    var Executable: String       // Executable of the Project(App)
    var SDK: String              // SDK of the Project(so the compiler knows what SDK the developer choosed to use)
    var TG: String               // Minimum iOS Version the Project Supports(so the compiler knows what it should compile for)
}

func GetProjects() -> [Project] {
    do {
        var Projects: [Project] = []
        for Item in try FileManager.default.contentsOfDirectory(atPath: global_documents) {
            if let Info = NSDictionary(contentsOfFile: "\(global_documents)/\(Item)/Resources/Info.plist"), let BundleID = Info["CFBundleIdentifier"] as? String, let Version = Info["CFBundleVersion"] as? String, let Executable = Info["CFBundleExecutable"] as? String, let TG = Info["MinimumOSVersion"] as? String {
                if let Info2 = NSDictionary(contentsOfFile: "\(global_documents)/\(Item)/Resources/DontTouchMe.plist"), let SDK = Info2["SDK"] as? String, let Name = Info2["ProjectName"] as? String {
                    Projects.append(Project(Name: Name, BundleID: BundleID, Version: Version, ProjectPath: "\(global_documents)/\(Item)", Executable: Executable, SDK: SDK, TG: TG))
                }
            }
        }
        return Projects
    } catch {
        print(error)
        return []
    }
}

func MakeApplicationProject(_ Name: String, _ BundleID: String, type: Int) -> Int {
    let v2uuid: UUID = UUID()
    let SDK: String = UserDefaults.standard.string(forKey: "sdk") ?? "iPhoneOS15.6.sdk"

    do {
        let ResourcesPath = "\(global_documents)/\(v2uuid)/Resources"
        try FileManager.default.createDirectory(atPath: ResourcesPath, withIntermediateDirectories: true)

        let infoPlistData: [String: Any] = [
            "CFBundleExecutable": Name,
            "CFBundleIdentifier": BundleID,
            "CFBundleName": Name,
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1.0",
            "MinimumOSVersion": gosver() ?? "14.0",
            "UILaunchScreen": [
                "UILaunchScreen": [:]
            ]
        ]

        let infoPlistPath = "\(ResourcesPath)/Info.plist"
        let infoPlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: infoPlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: infoPlistPath, contents: infoPlistDataSerialized, attributes: nil)

        let dontTouchMePlistData: [String: Any] = [
            "ProjectName": v2uuid.uuidString,
            "SDK": SDK
        ]

        let dontTouchMePlistPath = "\(ResourcesPath)/DontTouchMe.plist"
        let dontTouchMePlistDataSerialized = try PropertyListSerialization.data(fromPropertyList: dontTouchMePlistData, format: .xml, options: 0)
        FileManager.default.createFile(atPath: dontTouchMePlistPath, contents: dontTouchMePlistDataSerialized, attributes: nil)

        switch(type) {
            case 1:
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data("\(authorgen(file: "My App.swift"))import SwiftUI\n\n@main\nstruct MyApp: App {\n    var body: some Scene {\n        WindowGroup {\n            ContentView()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data("\(authorgen(file: "ContentView.swift"))import SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        Text(\"Hello, World!\")\n    }\n}".utf8))
                break
            case 2:
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: Data("\(authorgen(file: "main.m"))#import <Foundation/Foundation.h>\n#import \"myAppDelegate.h\"\n\nint main(int argc, char *argv[]) {\n\t@autoreleasepool {\n\t\treturn UIApplicationMain(argc, argv, nil, NSStringFromClass(myAppDelegate.class));\n\t}\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myAppDelegate.h", contents: Data("\(authorgen(file: "myAppDelegate.h"))#import <UIKit/UIKit.h>\n \n@interface myAppDelegate : UIResponder <UIApplicationDelegate>\n \n@property (nonatomic, strong) UIWindow *window;\n@property (nonatomic, strong) UINavigationController *rootViewController;\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myAppDelegate.m", contents: Data("\(authorgen(file: "myAppDelegate.m"))#import \"myAppDelegate.h\"\n#import \"myRootViewController.h\"\n\n@implementation myAppDelegate\n\n- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {\n\t_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];\n\t_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[myRootViewController alloc] init]];\n\t_window.rootViewController = _rootViewController;\n\t[_window makeKeyAndVisible];\n\treturn YES;\n}\n\n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.h", contents: Data("\(authorgen(file: "myRootViewController.h"))#import <UIKit/UIKit.h>\n \n@interface myRootViewController : UIViewController\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.m", contents: Data("\(authorgen(file: "myRootViewController.m"))#import \"myRootViewController.h\"\n@interface myRootViewController () <UITableViewDataSource>\n@property (nonatomic, strong) UITableView *logTableView;\n@property (nonatomic, strong) NSMutableArray *logEntries;\n@end\n@implementation myRootViewController\n- (void)viewDidLoad {\n    [super viewDidLoad];\n    self.title = @\"ObjectiveC support!\";\n    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];\n    self.logTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];\n    self.logTableView.dataSource = self;\n    [self.view addSubview:self.logTableView];\n    self.logEntries = [NSMutableArray array];\n}\n- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n    return self.logEntries.count;\n}\n- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n    static NSString *CellIdentifier = @\"Cell\";\n    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];\n    if (!cell) {\n        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];\n    }\n    cell.textLabel.text = self.logEntries[indexPath.row];\n    return cell;\n}\n- (void)addButtonTapped:(id)sender {\n    @try {\n        NSString *logEntry = @\"Hello, World!\";\n        [self.logEntries insertObject:logEntry atIndex:0];\n        [self.logTableView reloadData];\n    } @catch (NSException *exception) {\n        NSLog(@\"Exception: %@\", exception);\n    } @finally {\n        NSLog(@\"Add button tapped\");\n    }\n}\n@end".utf8))
                break
            case 3:
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data("\(authorgen(file: "My App.swift"))import SwiftUI\n\n@main\nstruct MyApp: App {\n    var body: some Scene {\n        WindowGroup {\n            ContentView()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data("\(authorgen(file: "ContentView.swift"))import Foundation\nimport SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n       Text(hello())\n    }\n    func hello() -> String {\n        let myObjCInstance = MyObjectiveCClass()\n        return myObjCInstance.hello()\n    }\n}".utf8))
                FileManager.default.createFile(atPath:"\(global_documents)/\(v2uuid)/bridge.h", contents: Data("\(authorgen(file: "bridge.h"))#import \"main.h\"".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.h", contents: Data("\(authorgen(file: "main.h"))#import <Foundation/Foundation.h>\n@interface MyObjectiveCClass : NSObject\n- (NSString *)hello;\n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: Data("\(authorgen(file: "main.m"))#import \"main.h\"\n@implementation MyObjectiveCClass\n- (NSString *)hello {\n    return @\"Hello ObjectiveC World!\";\n}\n@end".utf8))
            default:
                return 2
        }

        let entitlementsPlistData: [String: Any] = [
            "platform-application": true
        ]

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
