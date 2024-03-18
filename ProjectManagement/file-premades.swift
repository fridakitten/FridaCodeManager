func rvch() -> String {
    return """
#import <UIKit/UIKit.h>

@interface myRootViewController : UIViewController

@end
"""
}

func rvc() -> String {
    return """
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
}

func apdh() -> String {
    return """
#import <UIKit/UIKit.h>

@interface myAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootViewController;

@end
"""
}

func apd() -> String {
    return """
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
}

func mainv() -> String {
    return """
#import <Foundation/Foundation.h>
#import "myAppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(myAppDelegate.class));
	}
}
"""
}

func mainh() -> String {
    return """
#import <Foundation/Foundation.h>

@interface MyObjectiveCClass : NSObject

- (NSString *)hello;

@end
"""
}

func mainm() -> String {
    return """
#import "main.h"

@implementation MyObjectiveCClass

- (NSString *)hello {
    return @"Hello ObjectiveC World!";
}

@end
"""
}

func objcs() -> String {
    return """
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
}
func tools() -> String {
    return """
print("Hello World")
"""
}
func toolc() -> String {
    return """
printf(@"Hello World");
"""
}