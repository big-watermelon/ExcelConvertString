//
//  AppDelegate.m
//  ExcelConvertString
//
//  Created by 大西瓜 on 2018/9/4.
//  Copyright © 2018年 大西瓜. All rights reserved.
//


#import "AppDelegate.h"
#import "MainViewController.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    MainViewController *viewCtl = [[MainViewController alloc] init];
    [self.window setContentViewController:viewCtl];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
@end
