//
// fetch.m
//
// Created by SeanIsNotAConstant on 24.06.24
//
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <sys/utsname.h>

const char* getosver() {
    NSString *versionString = [[UIDevice currentDevice] systemVersion];
    const char *versionCString = [versionString UTF8String];
    return versionCString;
}

const char* getmodel() {
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    const char *modelCString = [modelName UTF8String];

    return modelCString;
}

const char* getres() {
    // Get the main screen
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    // Get the screen bounds and scale
    CGRect screenBounds = mainScreen.bounds;
    CGFloat screenScale = mainScreen.scale;
    
    // Calculate the screen resolution
    CGFloat screenWidth = screenBounds.size.width * screenScale;
    CGFloat screenHeight = screenBounds.size.height * screenScale;
    
    // Create the resolution string
    NSString *resolutionString = [NSString stringWithFormat:@"%.0fx%.0f", screenWidth, screenHeight];
    
    // Convert NSString to C string
    const char *resolutionCString = [resolutionString UTF8String];
    
    // Allocate memory for the result and copy the C string
    char *result = (char *)malloc(strlen(resolutionCString) + 1);
    if (result != NULL) {
        strcpy(result, resolutionCString);
    }
    
    return result;
}

const char *getcpu() {
    NSString *machine = [NSString stringWithFormat:@"%s",getmodel()];
    NSString *iphoneFamily = [machine substringToIndex:[machine length] - 2];
    
    NSDictionary *cpuNames = @{
        @"iPhone1": @"APL0098",
        @"iPhone2": @"APL0098",
        @"iPhone3": @"Apple A4",
        @"iPhone4": @"Apple A5",
        @"iPhone5": @"Apple A6",
        @"iPhone6": @"Apple A7",
        @"iPhone7": @"Apple A8",
        @"iPhone8": @"Apple A9",
        @"iPhone9": @"Apple A10 Fusion",
        @"iPhone10": @"Apple A11 Bionic",
        @"iPhone11": @"Apple A12 Bionic",
        @"iPhone12": @"Apple A13 Bionic",
        @"iPhone13": @"Apple A14 Bionic",
        @"iPhone14": @"Apple A15 Bionic",
        @"iPhone15": @"Apple A16 Bionic",
        @"iPhone16": @"Apple A16 Bionic",
        @"iPhone17": @"Apple A17 Bionic",
    };

    NSString *cpuName = cpuNames[iphoneFamily] ?: @"Unknown";

    const char *charCPU = [cpuName UTF8String];

    return charCPU;
}