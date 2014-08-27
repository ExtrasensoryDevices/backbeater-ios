//
//  BBAppDelegate.m
//  BB
//
//  Created by SUNG YOON on 12-03-09.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <Parse/Parse.h>
#import "TestFlight.h"

#import "BBAppDelegate.h"
#import "AUtype1.h"
#import "AUtype1Delegate.h"
#import "HomeViewController.h"
#import "PrefViewController.h"
#import "MusicPlayerViewController.h"
#import "BBSetting.h"
#import "BBUISettings.h"
@implementation BBAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize homeViewController, prefViewController, musicViewController;
@synthesize rioUnit, rioUnitDelegate;

- (void)dealloc
{
    [rioUnit release];
    [rioUnitDelegate release];
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    [Parse setApplicationId:@"FrcEuo2aSWB92xNBziVAOffa5jQ5sP56cR1jLXG4"
                  clientKey:@"A2d0cAfVlnlytyuIQIBfytyZfsORFbpr4W7gxzMC"];
    
    [TestFlight takeOff:@"79ff713882d3b847fa8b8dfbd589712f_MTM4NjcyMjAxMi0xMC0wMiAxNTowNDoyNC41OTUwODk"];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
        
    [[BBSetting sharedInstance] setMute:YES];
    
    //SY: rioUnit is a type of CoreAudio RemoteIO Audio Unit for this App.
    rioUnit = [[AUtype1 alloc] init];
    [rioUnit setup];
    
    rioUnitDelegate = [[AUtype1Delegate alloc] init];
    
    // SY: MaxSensitivity means a threshold value to register a strike. So smaller the value, more sensitive it is.
    // Vice-versa for MinSensitivity.
    [rioUnitDelegate setupWithMaxSensitivity:0.01f andMinSensitivity:0.45f];
    
    [self.rioUnit setDelegate:rioUnitDelegate];
    
    homeViewController = [[[HomeViewController alloc] initWithNibName:@"HomeViewController_iPhone" bundle:nil] autorelease];    
    prefViewController = [[[PrefViewController alloc] initWithNibName:@"PrefViewController_iPhone" bundle:nil] autorelease];
    musicViewController = [[[MusicPlayerViewController alloc] initWithNibName:@"MusicPlayerViewController" bundle:nil] autorelease];

    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeViewController, musicViewController, prefViewController, nil];
    
    [self.tabBarController setDelegate:self];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // KVO : Key-Value Observation is adopted instead of direct messaging or NSNotification.
    //SY: homeViewController, rioUnit, and rioUnitDelegate respond to setting changes from prefViewController
    [[BBSetting sharedInstance] addObserver:self.homeViewController forKeyPath:@"sensitivity" options:0 context:nil];
    [[BBSetting sharedInstance] addObserver:self.homeViewController forKeyPath:@"bpm" options:0 context:nil];
    
    [[BBSetting sharedInstance] addObserver:self.rioUnit forKeyPath:@"mute" options:0 context:nil];    
    [[BBSetting sharedInstance] addObserver:self.rioUnit forKeyPath:@"inMusicPlayer" options:0 context:nil];
   
    [[BBSetting sharedInstance] addObserver:self.homeViewController forKeyPath:@"mute" options:0 context:nil];
    [[BBSetting sharedInstance] addObserver:self.homeViewController forKeyPath:@"sensorIn" options:0 context:nil];
    
    [[BBSetting sharedInstance] addObserver:self.homeViewController forKeyPath:@"foundBPMf" options:0 context:nil];
    [[BBSetting sharedInstance] addObserver:self.homeViewController forKeyPath:@"sensitivityFlash" options:0 context:nil];
    
    [[BBSetting sharedInstance] addObserver:self.rioUnitDelegate forKeyPath:@"bpm" options:0 context:nil];    
    [[BBSetting sharedInstance] addObserver:self.rioUnitDelegate forKeyPath:@"sensitivity" options:0 context:nil];
    [[BBSetting sharedInstance] addObserver:self.rioUnitDelegate forKeyPath:@"metSound" options:0 context:nil];
    
    [[BBUISettings instance] addObserver:self.homeViewController forKeyPath:@"bpmDigitalViewOff" options:0 context:nil];
    [[BBUISettings instance] addObserver:self.homeViewController forKeyPath:@"strikesFilterNum" options:0 context:nil];

    [[BBUISettings instance] addObserver:self.homeViewController forKeyPath:@"timeSignatureNum" options:0 context:nil];

    [[BBUISettings instance] addObserver:self.homeViewController forKeyPath:@"runViewOff" options:0 context:nil];
    
    return YES;
}

#pragma mark ---- UITabBarControllerDelegate methods ----

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController 
{
    if (tabBarController.selectedIndex == 1) {
        [[BBSetting sharedInstance] setMute:YES];
        [[BBSetting sharedInstance] setInMusicPlayer:YES];
    }
    else {
        [[BBSetting sharedInstance] setInMusicPlayer:NO];
    }
}

///////////////////////////////////////////////////////////////////////////////

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [musicViewController reset];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.idleTimerDisabled = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.idleTimerDisabled = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [musicViewController reset];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[BBSetting sharedInstance] removeObserver:self.homeViewController forKeyPath:@"sensitivity"];
    [[BBSetting sharedInstance] removeObserver:self.homeViewController forKeyPath:@"bpm"];
    
    [[BBSetting sharedInstance] removeObserver:self.rioUnitDelegate forKeyPath:@"sensitivity"];
    [[BBSetting sharedInstance] removeObserver:self.rioUnitDelegate forKeyPath:@"bpm"];
    [[BBSetting sharedInstance] removeObserver:self.rioUnitDelegate forKeyPath:@"metSound"];
    
    [[BBSetting sharedInstance] removeObserver:self.rioUnit forKeyPath:@"mute"];
    [[BBSetting sharedInstance] removeObserver:self.rioUnit forKeyPath:@"inMusicPlayer"];
    
    [[BBSetting sharedInstance] removeObserver:self.homeViewController forKeyPath:@"sensorIn"];
    [[BBSetting sharedInstance] removeObserver:self.homeViewController forKeyPath:@"mute"];
    [[BBSetting sharedInstance] removeObserver:self.homeViewController forKeyPath:@"foundBPMf"];
    [[BBSetting sharedInstance] removeObserver:self.homeViewController forKeyPath:@"sensitivityFlash"];
    
    [[BBUISettings instance] removeObserver:self.homeViewController forKeyPath:@"bpmDigitalViewOff"];
    [[BBUISettings instance] removeObserver:self.homeViewController forKeyPath:@"strikesFilterNum"];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
