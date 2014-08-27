//
//  BBSecondViewController.h
//  BB
//
//  Created by SUNG YOON on 12-03-09.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCRoundSwitch.h"

@interface PrefViewController : UIViewController <UINavigationBarDelegate,  UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource> {
    
}

@property (nonatomic, retain) IBOutlet UITextField *chosenSen;
@property (nonatomic, retain) IBOutlet DCRoundSwitch *bpmViewSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *navBarControl;
@property (retain, nonatomic) IBOutlet UIImageView *bpmViewSwitchImage;
@property (retain, nonatomic) IBOutlet DCRoundSwitch *runViewSwitch;


- (IBAction)handleSensitivity:(id)sender;
- (IBAction)handleMeterSound:(id)sender;
- (IBAction)	handleURL:(id)sender;
- (IBAction)	handleFacebook:(id)sender;
- (IBAction)	handleTwitter:(id)sender;
- (IBAction)    handleUserManual:(id)sender;

- (IBAction)segmentAction:(id)sender;
- (IBAction) digitalBPMViewOnOff:(id)sender;

- (IBAction)postToFB:(id)sender;
- (IBAction)runViewOnOff:(id)sender;

@end

