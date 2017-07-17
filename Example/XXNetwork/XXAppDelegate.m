//
//  XXAppDelegate.m
//  XXNetwork
//
//  Created by acct<blob>=0xE7BE8AE5AD90 on 07/13/2017.
//  Copyright (c) 2017 acct<blob>=0xE7BE8AE5AD90. All rights reserved.
//

#import "XXAppDelegate.h"
#import <XXCategories/NSDictionary+ToString.h>
#import <XXNetwork/XXNetwork.h>

@implementation XXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *dict = @{@"test":@"12",
                           @"a":@"1213",
                           @"b":@"1213312312"};
    NSDictionary *dict2 = @{@"b":@"1213312312",
                            @"test":@"12",
                            @"a":@"1213"};
    
    NSString *string1 = [dict toString];
    NSString *string2 = [dict2 toString];
    NSLog(@"\n%@\n%@\n",string1,string2);
    
    [XXLog logCacheData:nil url:@"https://www.baodu.com" method:@"post" params:dict];

    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
