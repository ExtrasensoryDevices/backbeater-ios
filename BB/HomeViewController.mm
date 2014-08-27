//
//  HomeViewController.m
//  BB
//
//  Created by SUNG YOON on 12-03-09.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import "HomeViewController.h"
#import "BBAppDelegate.h"
#import "BBSetting.h"
#import "BBUISettings.h"
#import "DialView.h"
#import "RotatingQueue.h"
#include <mach/mach_time.h>
#include "CAHostTimeBase.h"
#import "RunController.h"
#import "LedView.h"

static BOOL isNewTapSeq = YES;

@interface HomeViewController ()
{
    BOOL _isSensorIn;
    RotatingQueue *_filter;
    
}

- (void)foundFigertapBPM:(NSUInteger)bpm;

@end

@implementation HomeViewController

@synthesize chosenBPM, chosenSensitivity;
@synthesize detectedTempo, detectedFingertapTempo, plugIn, noSensorButt, flashingDrum;

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if ([keyPath isEqual:@"sensitivity"]) 
    {
        float received = [[object valueForKey:@"sensitivity"] floatValue];
        int received_i = int(100.0f *received) ;
        self.chosenSensitivity.text = [NSString stringWithFormat:@"%d%%", received_i];
    }
    else if ([keyPath isEqual:@"bpm"]) 
    {
        self.chosenBPM.text = [NSString stringWithFormat:@"%d", [[object valueForKey:@"bpm"] intValue]];
    }
    else if ([keyPath isEqual:@"sensorIn"]) // message from AUType1
    {
        [self stopRun]; // if running

        BOOL inOut = [[object valueForKey:@"sensorIn"] boolValue];
        if (inOut) {
            self.plugIn.hidden = YES;
            self.noSensorButt.hidden = YES;
            self.flashingDrum.hidden = YES;
            _isSensorIn = YES;
        }
        else {
            self.plugIn.hidden = NO;
            self.plugIn.text = @"";
            self.noSensorButt.hidden = NO;
            self.flashingDrum.hidden = YES;
            _isSensorIn = NO;
            [self.dialView reset]; // scroll to beginning.
        }
        
    }
    else if ([keyPath isEqual:@"mute"]) 
    {
        BOOL isMute = [[object valueForKey:@"mute"] boolValue];
        
        if (isMute) {
            [onOffButt setImage:[UIImage imageNamed:@"switch_met_off.png"] forState:UIControlStateNormal];
        }
        else {
            [onOffButt setImage:[UIImage imageNamed:@"switch_met_on.png"] forState:UIControlStateNormal];
        }
    }
    else if ([keyPath isEqual:@"sensitivityFlash"] || [keyPath isEqual:@"foundBPMf"])
    {
        //SY: Flash (blink) drum for a registered strike
//        [self flashSensitivity:[[object valueForKey:@"sensitivityFlash"] boolValue]] ;
        
        // SY: Condition [[object valueForKey:@"foundBPMf"] floatValue]<0.0f) is a hack to remove BPM text from screen
        // after about 3 seconds.
        if (([[object valueForKey:@"sensitivityFlash"] boolValue] || ([[object valueForKey:@"foundBPMf"] floatValue]<0.0f))&& _isSensorIn)
        {
            [self foundBPMf:[[object valueForKey:@"foundBPMf"] floatValue]] ;
        }
    }
    // handling change of analog dial vs digital text to display BPMs
    else if ([keyPath isEqual:@"bpmDigitalViewOff"]) {
        BOOL value = [[object valueForKey:@"bpmDigitalViewOff"] boolValue];
        [self switchBPMView: value];
    }
    // handling change run button
    else if ([keyPath isEqual:@"runViewOff"]) {
        [self stopRun]; // if running
        BOOL value = [[object valueForKey:@"runViewOff"] boolValue];
        [self setRunViewButtonHidden: value];
    }
    // changed number of strikes to average BPMs in filter
    else if ([keyPath isEqual:@"strikesFilterNum"]) {
        [self stopRun]; // if running
        int numOfStrikes = [[object valueForKey:@"strikesFilterNum"] intValue];
        if (self.filter.capacity != numOfStrikes) {
            
            // the valid strikes is the strikes minus the averaging window (the -1 is there because the Wth strike is the first valid one)
            [self initFilterWithCapacity:numOfStrikes-1]; 
        }
        // do not count runs if numOfStrikes = 2
        if (numOfStrikes <= 2){
            // hide runView if numOfStrikes <= 2
            [self stopRun]; // if running
            [self setLedViewHidden:YES];
            [self setRunViewButtonHidden:YES];
        } else {
            [self setLedViewHidden:NO];
            if (![BBUISettings instance].runViewOff){
                // show runView if numOfStrikes >= 2 && it turned on in settings
                [self setRunViewButtonHidden:NO];
            }
        }

    }
    // changed timeSignatureNum
    else if ([keyPath isEqual:@"timeSignatureNum"]) {
        // do nothing
    }
    else {
//        NSLog(@"No key path found %@", keyPath);
    }
}

#pragma mark -- handling messages

- (void)foundBPMf:(float)bpmf 
{
    // time signature correction
    bpmf = bpmf * [BBUISettings instance].timeSignatureNum;

    if (bpmf > 20.0f){
        // for one strike sensor send 4 - 6 events with the same value. filter those.
        if ([self.filter lastValue].floatValue != bpmf){
            flashingDrum.hidden = NO;
            [self performSelector:@selector(hideFlashingDrumDisplay) withObject:nil afterDelay:.1];
            [self displayBPM:bpmf];
        }
    }
}

- (void)foundFigertapBPM:(NSUInteger)bpm
{
    // time signature correction
    bpm = bpm * [BBUISettings instance].timeSignatureNum;

    self.detectedFingertapTempo.hidden = NO;
    tappingFinger.hidden = NO;
//    self.detectedFingertapTempo.text = [NSString stringWithFormat:@"%d", bpm];
    [self performSelector:@selector(hideFingertempoDisplay) withObject:nil afterDelay:.1];
    [self displayBPM:(float) bpm];
}


-(void) displayBPM:(float) bpm {
    self.lastStrikeInt = [[NSDate date] timeIntervalSince1970];
    
    int avgBpm = [[self.filter enqueue:[NSNumber numberWithFloat:bpm]] average];
    
    if ([BBUISettings instance].bpmDigitalViewOff) { // dial is enabled in settings
        [self.dialView bpmReading:bpm average: avgBpm];
        [self.ledView bpmReading:bpm average:avgBpm];
    } else {
        // display numbers w/o dial
        if (avgBpm>220.0f || avgBpm<20.0f)
        {
            // SY: We do not need BPM outside this range.
            self.detectedTempo.text = [NSString stringWithFormat:@"__"];
            [self.ledView reset];
        }
        else
        {
            self.detectedTempo.text = [NSString stringWithFormat:@"%d", avgBpm];
            [self.ledView bpmReading:bpm average:avgBpm];
        }
    }
    if ([RunController instance].isCounting){
        [[RunController instance] recordBPM:bpm average:avgBpm];
        NSUInteger validStrikesNumber = [[RunController instance] getValidStrikesNumber];
        self.validStrikesLbl.text = validStrikesNumber>0 ? [NSString stringWithFormat:@"%d", validStrikesNumber] : @"";
    }
}
-(void) switchBPMView:(BOOL) digitalOff {
    if (digitalOff){
        self.detectedTempo.hidden =YES;
        self.dialView.hidden = NO;
    } else {
        self.detectedTempo.hidden =NO;
        self.dialView.hidden = YES;

    }
}

-(void) setLedViewHidden:(BOOL) visibilityOff {
    [self.ledView setHidden:visibilityOff];
}

-(void) setRunViewButtonHidden:(BOOL) visibilityOff {
    // always allow turn off
    // turn On only if TS > 2
    if (visibilityOff || (!visibilityOff &&[BBUISettings instance].strikesFilterNum >= 2)){
        runButt.hidden = visibilityOff;
        self.validStrikesLbl.hidden = visibilityOff;
        if (visibilityOff){
            self.validStrikesLbl.text = @"";
        }
    }
}


//- (void)flashSensitivity:(BOOL)YorN 
//{
//    if (YorN) {
//        if (_isSensorIn) self.flashingDrum.hidden = NO;
//    }
//    else {
//        self.flashingDrum.hidden = YES;
//    }
//}


- (void)hideFingertempoDisplay {
    self.detectedFingertapTempo.hidden = YES;
    tappingFinger.hidden = YES;
}

- (void)hideFlashingDrumDisplay {
    flashingDrum.hidden = YES;
}



#pragma mark -- IBAction
- (IBAction)startStopMetro:(id)sender 
{
    if ([[BBSetting sharedInstance] mute]) 
    { 
        // Start metronome        
        [onOffButt setImage:[UIImage imageNamed:@"switch_met_on.png"] forState:UIControlStateNormal];
        [[BBSetting sharedInstance] setMute:NO];
    }
    else 
    { 
        // Stop metronome
        [onOffButt setImage:[UIImage imageNamed:@"switch_met_off.png"] forState:UIControlStateNormal];
        [[BBSetting sharedInstance] setMute:YES];
    }       
}

- (IBAction)noSensor:(id)sender 
{
    NSURL* launchURL =[NSURL URLWithString:@"http://www.backbeater.com"];
    [[UIApplication sharedApplication] openURL:launchURL];
}

-(void) updateRunButtonState
{
    if ([RunController instance].isCounting){
        [runButt setImage:[UIImage imageNamed:@"stop_up.png"] forState:UIControlStateNormal];
        [runButt setImage:[UIImage imageNamed:@"stop_dn.png"] forState:UIControlStateHighlighted];
    } else {
        [runButt setImage:[UIImage imageNamed:@"start_up.png"] forState:UIControlStateNormal];
        [runButt setImage:[UIImage imageNamed:@"start_dn.png"] forState:UIControlStateHighlighted];
    }
    
}

-(void) startRun
{
    [[RunController instance] startRun];
    [self updateRunButtonState];
}

-(void) stopRun
{
    [[RunController instance] stopRun:_filter.average];
    [self updateRunButtonState];
    self.validStrikesLbl.text = @"";
}

- (IBAction)startStopRun:(id)sender {
    if ([RunController instance].isCounting)
    {
        [self stopRun];
    } else {
        [self startRun];
    }
}

#pragma mark ---- view controller bookeeping

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"main_menu_home"];
        [self initFilterWithCapacity:[BBUISettings instance].strikesFilterNum];
    }
    return self;
}
-(void) initFilterWithCapacity:(int)capacity{
    RotatingQueue *filter = [[RotatingQueue alloc] initWithCapacity:capacity];
    self.filter = filter;
    [filter release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	  
    self.chosenBPM.text = [NSString stringWithFormat:@"%d", 40+20];
    self.chosenSensitivity.text = @"100%";   
    
    self.detectedTempo.text = @"__";
    
    self.flashingDrum.hidden = YES;
    tappingFinger.hidden = YES;
    self.detectedFingertapTempo.hidden = YES;    
    
    //SY: It seems KVO does not work at the launch.
    [onOffButt setImage:[UIImage imageNamed:@"switch_met_off.png"] forState:UIControlStateNormal];
    
    // add dial view

    self.dialView = [DialView view];
    self.dialView.frame = CGRectMake(0, 92, 320, 320);
    [self.view insertSubview:self.dialView atIndex:1];
    if ([BBUISettings instance].bpmDigitalViewOff){
        // hide digital view
        self.detectedTempo.hidden = YES;
    } else {
        self.dialView.hidden = YES;
    }
    
    //run Button
    [self updateRunButtonState];
    [runButt setHidden:[BBUISettings instance].runViewOff];
    
    self.lastStrikeInt = [[NSDate date] timeIntervalSince1970];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkLastStrikeInterval) userInfo:nil repeats:YES];
    self.checkInactivityTimer = timer;
}

- (void)viewDidUnload {
    [self setValidStrikesLbl:nil];
    [self setLedView:nil];
    [super viewDidUnload];
    [self.checkInactivityTimer invalidate];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!_isSensorIn){
        [self stopRun]; // if running
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark --- touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{    
    static UInt64 newTapTime = 0;
    static UInt64 oldTapTime = 0;
    
    static UInt32 taptapCount = 0;
    
    Float64 figertapBPM;
    NSUInteger fingertapBPM_UI;
    Float64 delayFator = 0.1;
    
    newTapTime = CAHostTimeBase::GetCurrentTime();
    
    UInt64 timeElapsedNs = CAHostTimeBase::AbsoluteHostDeltaToNanos(newTapTime, oldTapTime); 
#if DEBUG
    printf("%llu nanoseconds passed.\n", timeElapsedNs);
#endif
    
    Float64 timeElapsedInSec = Float64(timeElapsedNs) * 10.e-9 * delayFator;
#if DEBUG
    printf("%f second passed.\n", timeElapsedInSec);
#endif
    
    isNewTapSeq = (timeElapsedInSec > 2.0)? YES : NO ;
        
    if (isNewTapSeq) 
    {
        taptapCount = 0;
        [self hideFingertempoDisplay];
        
    }
    else 
    {  
        
        if (timeElapsedInSec>0.2) // When BPM is less than 100, calculate and display BPM immediately.
        {
            figertapBPM = 60.0/timeElapsedInSec ;
            fingertapBPM_UI = (NSUInteger)(figertapBPM);
            [self foundFigertapBPM:fingertapBPM_UI];
        }
        else // When BPM is more than 100, add up elapsed time until tap count is over 3, then display.
        {
            [self hideFingertempoDisplay];            
        }
        
    }
    
    oldTapTime = newTapTime;
    taptapCount += 1;
        
}
#define filterResetIdleTimeSec 5

-(void) checkLastStrikeInterval{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - self.lastStrikeInt > filterResetIdleTimeSec ) {
        [self.filter reset];
        [self.dialView reset]; // scroll to beginning.
        [self.ledView reset];
        self.detectedTempo.text = [NSString stringWithFormat:@"__"];
    }
}
- (void)dealloc
{
    [_checkInactivityTimer invalidate];
    // TODO: add more
    [_dialView release];
    [_ledView release];
    [_filter dealloc];
    [_checkInactivityTimer release];
    [_validStrikesLbl release];
    [_ledView release];
    [super dealloc];
}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//}


@end
