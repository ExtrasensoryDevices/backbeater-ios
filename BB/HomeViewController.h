//
//  HomeViewController.h
//  BB
//
//  Created by SUNG YOON on 12-03-09.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DialView;
@class RotatingQueue;
@class LedView;

@interface HomeViewController : UIViewController {
    IBOutlet UIButton *onOffButt;
    IBOutlet UIButton *runButt;
    IBOutlet UIImageView *flashingDrum;
    IBOutlet UIImageView *tappingFinger;
}

@property (nonatomic, retain) IBOutlet UITextField *chosenBPM;
@property (nonatomic, retain) IBOutlet UITextField *chosenSensitivity;
@property (nonatomic, assign) IBOutlet UITextField *detectedTempo;
@property (nonatomic, assign) IBOutlet UITextField *plugIn;
@property (nonatomic, assign) IBOutlet UIButton    *noSensorButt;
@property (nonatomic, assign) IBOutlet UITextField *detectedFingertapTempo;
@property (nonatomic, retain) IBOutlet DialView *dialView;
@property (nonatomic, retain) RotatingQueue *filter;
@property (nonatomic, retain) NSTimer *checkInactivityTimer;
@property (retain, nonatomic) IBOutlet UILabel *validStrikesLbl;
@property (retain, nonatomic) IBOutlet LedView *ledView;

@property (nonatomic, assign) NSTimeInterval lastStrikeInt;

@property (nonatomic, retain) IBOutlet UIImageView *flashingDrum;

- (void)foundBPMf:(float)bpmf;

//- (void)flashSensitivity:(BOOL)YorN;

- (IBAction)startStopMetro:(id)sender;
- (IBAction)noSensor:(id)sender;
- (IBAction)startStopRun:(id)sender;

@end


