//
//  BBAppDelegate.h
//  BB
//
//  Created by SUNG YOON on 12-03-09.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AUtype1;
@class AUtype1Delegate;
@class HomeViewController, MusicViewController, PrefViewController, MusicPlayerViewController;

@interface BBAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) HomeViewController *homeViewController;
@property (strong, nonatomic) PrefViewController *prefViewController;
@property (strong, nonatomic) MusicPlayerViewController *musicViewController;
@property (nonatomic, retain) AUtype1 *rioUnit;
@property (nonatomic, retain) AUtype1Delegate *rioUnitDelegate;


@end
