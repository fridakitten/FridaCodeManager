/*
 main.m

 Rewritten by cxdxn1
 
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

#import <UIKit/UIKit.h>
#import "FridaCodeManager-Swift.h"

NSString *libroot_dyn_get_jbroot_prefix(void);

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString *jbroot = [NSString stringWithCString:libroot_dyn_get_jbroot_prefix() encoding:NSUTF8StringEncoding];
        
        // Create a new instance of UINavigationBarAppearance
        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
        
        // Set background color
        navigationBarAppearance.backgroundColor = [[UIColor systemBackground] colorWithAlphaComponent:0.9]; // Adjust alpha as needed
        
        // Set title text attributes
        NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor label]}; // Using label color
        navigationBarAppearance.titleTextAttributes = titleAttributes;
        
        // Set button styles
        NSDictionary *buttonAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]}; // Set button color to white
        navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes;
        
        UIBarButtonItemAppearance *backItemAppearance = [[UIBarButtonItemAppearance alloc] init];
        backItemAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor label]}; // fix text color
        navigationBarAppearance.backButtonAppearance = backItemAppearance;
        
        // Apply the appearance to the navigation bar
        UINavigationBar.appearance.standardAppearance = navigationBarAppearance;
        UINavigationBar.appearance.compactAppearance = navigationBarAppearance;
        UINavigationBar.appearance.scrollEdgeAppearance = navigationBarAppearance;
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([MyAppDelegate class]));
    }
}

//
//  AppDelegate.m
//  FridaCodeManager
//
//  Created by cxdxn1 on 23.3.24.
//  Copyright © 2024 cxdxn1. All rights reserved.
//

#import "AppDelegate.h"
#import "FridaCodeManager-Swift.h"

@implementation MyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[UIHostingController alloc] initWithRootView:[[ContentView alloc] initWithHello:[[NSUUID alloc] init]]];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [self handleSprojFile:url];
}

- (void)handleSprojFile:(NSURL *)url {
    NSError *error;
    NSURL *documentsURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error) {
        NSLog(@"Error getting documents directory: %@", error.localizedDescription);
        return;
    }
    
    NSURL *targetURL = [documentsURL URLByAppendingPathComponent:@"target.sproj"];
    
    if ([[NSFileManager defaultManager] copyItemAtURL:url toURL:targetURL error:&error]) {
        NSString *copiedFileContent = [NSString stringWithContentsOfURL:targetURL encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"Copied File Content: %@", copiedFileContent);
    } else {
        NSLog(@"Error handling .sproj file: %@", error.localizedDescription);
    }
    
    [self importProj];
}

- (void)importProj {
    NSError *error;
    // Implement importProj method logic here
    
    // Example:
    NSString *fileContent = @"Example content"; // Replace with actual file content
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"importedFile.txt"];
    
    if ([fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"File imported successfully!");
    } else {
        NSLog(@"Error importing file: %@", error.localizedDescription);
    }
}

@end
