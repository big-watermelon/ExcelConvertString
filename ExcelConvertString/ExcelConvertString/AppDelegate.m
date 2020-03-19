//
//  AppDelegate.m
//  ExcelConvertString
//
//  Created by 大西瓜 on 2018/9/4.
//  Copyright © 2018年 大西瓜. All rights reserved.
//


#import "AppDelegate.h"
#import "MainViewController.h"
#import "CommonFunction.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    MainViewController *viewCtl = [[MainViewController alloc] init];
    [self.window setContentViewController:viewCtl];
    
}

- (void)test
{
    [CommonFunction translateString:@"1、Teacher: whoever answers my next question, can go home." fromType:LanguageType_en toType:LanguageType_zh completed:^(NSString * _Nullable string, NSString * _Nullable error) {
        if (string) {
            NSLog(@"str %@", string);
        }else{
            NSLog(@"%@", error);
        }
    }];
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
