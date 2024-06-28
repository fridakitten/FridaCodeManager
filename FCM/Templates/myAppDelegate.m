//
//
//  myAppDelegate.m
//  Created by %(author) at %(time)
//  This is a part of the %(project)
//
//

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
