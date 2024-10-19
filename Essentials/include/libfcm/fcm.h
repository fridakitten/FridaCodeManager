#ifndef FCM_H
#define FCM_H
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

/**
 * @brief Functions to get Information about the darwin host machine
 *
 */
NSString *ghost();
NSString *gosver();
NSString *gos();
NSString *gosb();
NSString *gmodel();
NSString *garch();
NSString *gcpu();

/**
 * @brief Functions to generate a documents container in case it doesnr exist yet
 *
 */
NSString* contgen(void);

/**
 * @brief This function is to kill processes with their bundle identifier
 *
 */
void killTaskWithBundleID(NSString *bundleID);

#endif // FCM_H
