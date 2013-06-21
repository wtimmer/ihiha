//
//  AppDelegate.m
//  iHiHa
//
//  Created by Wouter Timmer on 25-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import <NewsstandKit/NewsstandKit.h>

@implementation AppDelegate


							
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
    
    /*
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound | UIRemoteNotificationTypeNewsstandContentAvailability )];
    */
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
      UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound ];
    

     
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //For test
    
    // allows more than one new content notification per day (development)
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    
    NSLog(@"LAUNCH OPTIONS = %@",launchOptions);
    
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"%@",payload);
    if(payload) {
        NSLog(@"Payload");

    }
    
    NSLog(@"didFinishLaunchingWithOptions");
    // Override point for customization after application launch.
    
    // Select the left-most tab of our initial tab bar controller:
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = 2;
    return YES;
}
#pragma push
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *str = [NSString stringWithFormat:@"Device Token=%@",deviceToken];
    NSLog(@"%@",str);
    [self UploadToken:deviceToken];
    
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        NSString *alert = [NSString stringWithFormat:@"%@",key];
        NSLog(@"%@",alert);
        
        
        
    }
    if (application.applicationState == UIApplicationStateActive)
    {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[NSString stringWithFormat:@"%@",
                                                                     [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
    }
}


- (void)UploadToken:(NSData *)deviceToken {
    
    
    UIDevice *myDevice = [UIDevice currentDevice];
   
    NSString *Token = [NSString  stringWithFormat:@"%@",deviceToken  ];
    Token = [Token stringByReplacingOccurrencesOfString:@" " withString:@"" ];
    Token = [Token stringByReplacingOccurrencesOfString:@"<" withString:@"" ];
    Token = [Token stringByReplacingOccurrencesOfString:@">" withString:@"" ];
    NSString *uniqueGlobalDeviceIdentifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString *uniqueDeviceIdentifier = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *myRequestString = [NSString stringWithFormat:@"<iOS uniqueGlobalDeviceIdentifier='%@' uniqueDeviceIdentifier='%@' model='%@' name='%@' appversion='%@' deviceToken='%@' iOS='%@' CFBundleIdentifier='%@'><item/>\n" ,uniqueGlobalDeviceIdentifier, uniqueDeviceIdentifier, [myDevice model], [myDevice name], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],Token, [myDevice systemVersion],appID];
    //XML Header einde
    myRequestString = [NSString stringWithFormat:@"%@\n </iOS> ", myRequestString];
    // de tekens uit de teksen verwijderen.
    myRequestString = [myRequestString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    // NSLog(@"post:%@",myRequestString);
    
    // Upload de verzamelde data
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
	NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:[NSString stringWithFormat:@"http://rotterdapp.net/ihiha/DeviceToken.php" ]]] ;
    
    [ request setHTTPMethod: @"POST" ];
    [ request setHTTPBody: myRequestData ];
	NSURLConnection *connect =[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connect){}
    
   
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] );
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"connectionDidFinishLoading");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    // inform the user
    NSLog(@"Connection failed! Error - %@",error);
}



- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@",str);
    NSString *data = [NSString stringWithFormat:@""] ;
    NSData *myRequestData = [ NSData dataWithBytes: [data UTF8String ] length: [ data length ] ];
    
    [self UploadToken:myRequestData];
    
}




@end
