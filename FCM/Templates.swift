/*
    Templates.swift

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

// RootViewController

let rvc = \
"""
#import "myRootViewController.h"

@interface myRootViewController () <UITableViewDataSource>
@property (nonatomic, strong) UITableView *logTableView;
@property (nonatomic, strong) NSMutableArray *logEntries;
@end

@implementation myRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"ObjevtiveC support!";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)];

    // Create and configure UITableView for log display
    self.logTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.logTableView.dataSource = self;
    [self.view addSubview:self.logTableView];

    // Initialize log entries array
    self.logEntries = [NSMutableArray array];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = self.logEntries[indexPath.row];
    return cell;
}

- (void)addButtonTapped:(id)sender {
    @try {
        // Add log entry
        NSString *logEntry = @"Hello, World!";
        [self.logEntries insertObject:logEntry atIndex:0];

        // Update UITableView
        [self.logTableView reloadData];
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    } @finally {
        NSLog(@"Add button tapped");
    }
}

@end
"""

let rvch = \
"""
#import <UIKit/UIKit.h>

@interface myRootViewController : UIViewController

@end
"""

// App Delegate

let apdh = \
"""
#import <UIKit/UIKit.h>

@interface myAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootViewController;

@end
"""

let apd = \
"""
#import "myAppDelegate.h"
#import "myRootViewController.h"

@implementation myAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[myRootViewController alloc] init]];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
	return YES;
}

@end
"""

// Main entrypoint

let mainv = \ // ObjC-only app
"""
#import <Foundation/Foundation.h>
#import "myAppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(myAppDelegate.class));
	}
}
"""

// Swift + ObjC app
let mainh = \
"""
#import <Foundation/Foundation.h>

@interface MyObjectiveCClass : NSObject

- (NSString *)hello;

@end
"""

let mainm = \
"""
#import "main.h"

@implementation MyObjectiveCClass

- (NSString *)hello {
    return @"Hello ObjectiveC World!";
}

@end
"""

let objcswift = \
"""
import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
       Text(hello())
    }
    func hello() -> String {
        let myObjCInstance = MyObjectiveCClass()
        return myObjCInstance.hello()
    }
}
"""

// SwiftUI app
let swiftApp = \
"""
import SwiftUI

@main
struct MyApp: App {

    var body: some Scence {
        WindowGroup {
            ContentView()
        }
    }

}
"""

let contentView = \
"""
import SwiftUI

struct ContentView: View {

    var body: some View {
        Text("Hello, World!")
    }

}
"""

// PLists
let DontTouchMe = \
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>ProjectName</key>
        <string>%(v2uuid)</string>
        <key>SDK</key>
        <string>%(SDK)</string>
    </dict>
</plist>
"""

let InfoPlist = \
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleExecutable</key>
        <string>%(Name)</string>
        <key>CFBundleIdentifier</key>
        <string>%(BundleID)</string>
        <key>CFBundleName</key>
        <string>%(Name)</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <key>CFBundleVersion</key>
        <string>1.0</string>
        <key>MinimumOSVersion</key>
        <string>%(OSVer)</string>
        <key>UILaunchScreen</key>
        <dict/>
    </dict>
</plist>
"""

let ents = \
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>platform-application</key>
        <true/>
    </dict>
</plist>
"""

func authorgen(_ file: String, _ content: String) -> String {
    let author = UserDefaults.standard.string(forKey: "Author")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yy"

    return "//\n// \(file)\n//\n// Created by \(author ?? "Anonym") on \(dateFormatter.string(from: Date()))\n//\n\n\(content)";
}