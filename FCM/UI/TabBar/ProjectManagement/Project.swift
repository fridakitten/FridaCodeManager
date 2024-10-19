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

//TODO: Use NSDictionary!!
func MakeApplicationProject(_ Name: String, _ BundleID: String, type: Int) -> Int {
    let v2uuid: UUID = UUID()
    let SDK: String = UserDefaults.standard.string(forKey: "sdk") ?? "iPhoneOS15.6.sdk"

    do {
        let ResourcesPath = "\(global_documents)/\(v2uuid)/Resources"
        try FileManager.default.createDirectory(atPath: ResourcesPath, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: "\(ResourcesPath)/Info.plist", contents: Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>CFBundleExecutable</key>\n\t<string>\(Name)</string>\n\t<key>CFBundleIdentifier</key>\n\t<string>\(BundleID)</string>\n\t<key>CFBundleName</key>\n\t<string>\(Name)</string>\n\t<key>CFBundleShortVersionString</key>\n\t<string>1.0</string>\n\t<key>CFBundleVersion</key>\n\t<string>1.0</string>\n\t<key>MinimumOSVersion</key>\n\t<string>\(String(gosver() ?? "14.0"))</string>\n\t<key>UILaunchScreen</key>\n\t<dict>\n\t\t<key>UILaunchScreen</key>\n\t\t<dict/>\n\t</dict>\n</dict>\n</plist>".utf8))
        FileManager.default.createFile(atPath: "\(ResourcesPath)/DontTouchMe.plist", contents: Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>ProjectName</key>\n\t<string>\(v2uuid)</string>\n\t<key>SDK</key>\n\t<string>\(SDK)</string>\n</dict>\n</plist>".utf8))
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
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.m", contents: Data("\(authorgen(file: "myRootViewController.m"))#import \"myRootViewController.h\"\n \n@interface myRootViewController () <UITableViewDataSource>\n@property (nonatomic, strong) UITableView *logTableView;\n@property (nonatomic, strong) NSMutableArray *logEntries;\n@end\n \n@implementation myRootViewController\n \n- (void)viewDidLoad {\n    [super viewDidLoad];\n \n    self.title = @\"ObjevtiveC support!\";\n \n    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];\n \n    // Create and configure UITableView for log display\n    self.logTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];\n    self.logTableView.dataSource = self;\n    [self.view addSubview:self.logTableView];\n \n    // Initialize log entries array\n    self.logEntries = [NSMutableArray array];\n}\n \n- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n    return self.logEntries.count;\n}\n \n- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n    static NSString *CellIdentifier = @\"Cell\";\n    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];\n \n    if (!cell) {\n        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];\n    }\n \n    cell.textLabel.text = self.logEntries[indexPath.row];\n    return cell;\n}\n \n- (void)addButtonTapped:(id)sender {\n    @try {\n        // Add log entry\n        NSString *logEntry = @\"Hello, World!\";\n        [self.logEntries insertObject:logEntry atIndex:0];\n \n        // Update UITableView\n        [self.logTableView reloadData];\n    } @catch (NSException *exception) {\n        NSLog(@\"Exception: %@\", exception);\n    } @finally {\n        NSLog(@\"Add button tapped\");\n    }\n}\n \n@end".utf8))
                break
            case 3:
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data("\(authorgen(file: "My App.swift"))import SwiftUI\n\n@main\nstruct MyApp: App {\n    var body: some Scene {\n        WindowGroup {\n            ContentView()\n        }\n    }\n}".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data("\(authorgen(file: "ContentView.swift"))import Foundation\nimport SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n       Text(hello())\n    }\n    func hello() -> String {\n        let myObjCInstance = MyObjectiveCClass()\n        return myObjCInstance.hello()\n    }\n}".utf8))
                FileManager.default.createFile(atPath:"\(global_documents)/\(v2uuid)/bridge.h", contents: Data("\(authorgen(file: "bridge.h"))#import \"main.h\"".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.h", contents: Data("\(authorgen(file: "main.h"))#import <Foundation/Foundation.h>\n \n@interface MyObjectiveCClass : NSObject\n \n- (NSString *)hello;\n \n@end".utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: Data("\(authorgen(file: "main.m"))#import \"main.h\"\n \n@implementation MyObjectiveCClass\n \n- (NSString *)hello {\n    return @\"Hello ObjectiveC World!\";\n}\n \n@end".utf8))
            default:
                return 2
        }
        FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/entitlements.plist", contents: Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>platform-application</key>\n\t<true/>\n</dict>\n</plist>".utf8))
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
