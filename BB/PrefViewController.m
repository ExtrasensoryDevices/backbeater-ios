//
//  BBSecondViewController.m
//  BB
//
//  Created by SUNG YOON on 12-03-09.
//  Copyright (c) 2012 Bamsom. All rights reserved.
//

#import <Parse/Parse.h>
#import "PrefViewController.h"
#import "BBSetting.h"
#import "BBUISettings.h"
#import "RunController.h"
#import "StatsCell.h"

static UIView *oldView;
static UIView *newView;

@interface PrefViewController () {
    
    NSArray *_strikeValues;
    NSArray *_timeSignatureValues;
    NSArray *_statsData;
  
}

@property (nonatomic, strong) NSArray *MetronomeSounds;
@property (nonatomic, retain) IBOutlet UIView *flippingView;
@property (nonatomic, retain) IBOutlet UIView *settingsView;
@property (nonatomic, retain) IBOutlet UIView *metronomeView;
@property (nonatomic, retain) IBOutlet UIScrollView *helpView;
@property (nonatomic, retain) IBOutlet UIView *contactView;
@property (nonatomic, retain) IBOutlet UIView *statisticsView;
@property (nonatomic, retain) IBOutlet UIPickerView *metTempoPickerView;
@property (nonatomic, retain) IBOutlet UIPickerView *strikesPickerView;
@property (retain, nonatomic) IBOutlet UIPickerView *timeSignaturePickerView;
@property (nonatomic, retain) IBOutlet UISlider *sensitivitySlider;
@property (nonatomic, retain) IBOutlet UISegmentedControl *metronomeSound;
@property (retain, nonatomic) IBOutlet UITableView *statsTable;

@end

@implementation PrefViewController

@synthesize chosenSen;

@synthesize MetronomeSounds;
@synthesize flippingView = _flippingView;
@synthesize settingsView = _settingsView;
@synthesize metronomeView = _metronomeView;
@synthesize helpView = _helpView;
@synthesize contactView = _contactView;
@synthesize statisticsView = _statisticsView;

@synthesize metTempoPickerView = _metTempoPickerView;

@synthesize sensitivitySlider = _sensitivitySlider;
@synthesize metronomeSound = _metronomeSound;

#pragma mark --- Handle user choices

- (IBAction)handleSensitivity:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [[BBSetting sharedInstance] setSensitivity:[slider value]];
    
    chosenSen.text = [NSString stringWithFormat:@"%i", (int)(slider.value*100.0f)];
}

- (IBAction)handleMeterSound:(id)sender {
    UISegmentedControl *ctrl = (UISegmentedControl *)sender;
    [[BBSetting sharedInstance] setMetSound:[ctrl selectedSegmentIndex]];
}

-(IBAction)	handleURL:(id)sender {
	NSURL* launchURL =[NSURL URLWithString:@"http://www.backbeater.com"];
    [[UIApplication sharedApplication] openURL:launchURL];
}

-(IBAction)	handleTwitter:(id)sender {
   
    NSURL* twitterNativeAppURL =[NSURL URLWithString:@"twitter:///user?screen_name=backbeatr"];
    
    if ( [[UIApplication sharedApplication] canOpenURL:twitterNativeAppURL]) {
        [[UIApplication sharedApplication] openURL:twitterNativeAppURL];
    }
    // Otherwise, just open it in the browser
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/backbeatr"]];
    }

}

- (IBAction)handleUserManual:(id)sender {
	NSURL* launchURL =[NSURL URLWithString:@"http://www.backbeater.com/m/manual.html"];
    [[UIApplication sharedApplication] openURL:launchURL];
}

-(IBAction)	handleFacebook:(id)sender {
    // This is Backbeater Facebook ID
	NSURL* fbNativeAppURL =[NSURL URLWithString:@"fb://page/103680369737796&"];
    
    if ( [[UIApplication sharedApplication] canOpenURL:fbNativeAppURL]) {
        [[UIApplication sharedApplication] openURL:fbNativeAppURL];
    }
    // Otherwise, just open it in the browser
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/backbeatr"]];
    }
}


#pragma mark ----- navigation
/* Use the segment control to select a view.
 Transition the center view from view to view.
 */
- (IBAction)segmentAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger i = [segmentedControl selectedSegmentIndex];
    
    switch (i) {
        case 0:
            newView = _statisticsView;
            break;
        case 1:     //Metronome settings
            newView = _metronomeView;
            break; 

        case 2:     //Help info screen
            newView = _helpView;
            break;            
        case 3:     //Link screen
            newView = _contactView;
            break;            
        default:
            break;
    }

    if (newView != oldView){
        [UIView transitionFromView: oldView toView: newView duration:0.45 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        oldView = newView;
    }
}
- (IBAction) digitalBPMViewOnOff:(id)sender {
    UISwitch *bpmViewSwtich = sender;
    BOOL digitalViewOff =!bpmViewSwtich.on;
    NSString *imageName =digitalViewOff ? @"switch_analog.png": @"switch_digital.png";
    self.bpmViewSwitchImage.image = [UIImage imageNamed: imageName];    
    [BBUISettings instance].bpmDigitalViewOff = digitalViewOff;
}

- (IBAction)postToFB:(id)sender {
    // temporarily post to parse
    RunData *data = [[RunController instance] getLatestRun];
    if (data == nil){
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Enter your name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    [alertView release];
}

- (IBAction)runViewOnOff:(id)sender {
    [BBUISettings instance].runViewOff = !self.runViewSwitch.on;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){ // cancel
        return;
    }
    
    NSString *name = [alertView textFieldAtIndex:0].text;
    name = [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (name.length == 0){
        return;
    }

    RunData *data = [[RunController instance] getLatestRun];

    PFObject *record = [[PFObject alloc] initWithClassName:@"statistics"];
    [record setValue:[NSNumber numberWithInt:data.runNumber] forKey:@"runNumber"];
    [record setValue:name forKey:@"name"];
    [record setValue:[NSNumber numberWithInt:data.length] forKey:@"length"];
    [record setValue:[NSNumber numberWithInt:data.averageBPM] forKey:@"averageBPM"];
    [record setValue:data.date forKey:@"date"];
    [record setValue:[NSNumber numberWithInt:data.score] forKey:@"score"];
    [record setValue:data.scoreString forKey:@"scoreString"];
    [record setValue:(data.trackTitle ? data.trackTitle : @"") forKey:@"trackTitle"];
    [record saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSString *message;
        if (error){
            if ([error code] == kPFErrorConnectionFailed) {
                message = @"You are not connected to the internet. Please try again later.";
            } else {
                message = error.localizedDescription;
            }
        } else {
            message = @"Score uploaded to Backbeater.com";
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
    }];
    [record release];
    
}



/////////////////////////////////////////////////
#pragma mark -- TableView Delegate for statistics view


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _statsData ? _statsData.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"StatsCellIdentifier";
    
    RunData *data = [_statsData objectAtIndex:indexPath.row];
    if (!data){
        return nil;
    }
    
    StatsCell *cell = (StatsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[StatsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier]autorelease];
    }
    NSString *trackTitle = data.trackTitle ? data.trackTitle : @"";
    cell.label.text = [NSString stringWithFormat:@"Run %d %@\nAverage BPM: %d  Length %d \nScore: %d %@",
                           data.runNumber, trackTitle, data.averageBPM, data.length, data.score, data.scoreString];
    
    return cell;
    
}





/////////////////////////////////////////////////
#pragma mark -- PickerView Delegate for Metronome Tempo and Average Strikes

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pView {return 1;}

- (NSInteger)pickerView:(UIPickerView *)pView numberOfRowsInComponent:(NSInteger)component
{
    if (pView == self.metTempoPickerView) {
        return 202;
    } else  if (pView == self.strikesPickerView){
        // for strikes picker
        return _strikeValues.count;
    } else  if (pView == self.timeSignaturePickerView){
        // for time signature picker
        return _timeSignatureValues.count;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[[UILabel alloc] initWithFrame:
                  CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)] autorelease];
        tView.font = [UIFont systemFontOfSize:22];
        [tView setBackgroundColor:[UIColor clearColor]];
        tView.textAlignment = NSTextAlignmentCenter;
    }
    NSString *text = @"";
    if (pickerView == self.metTempoPickerView) {
        text =[NSString stringWithFormat:@"%i",row+20 ];
    }
	else if (pickerView == self.strikesPickerView) {
        // for strikes picker
        text = [NSString stringWithFormat:@"%@", _strikeValues[row]];
    }
	else if (pickerView == self.timeSignaturePickerView) {
        // for time signature picker
        text = [NSString stringWithFormat:@"%@", _timeSignatureValues[row]];
    }
    tView.text = text;

    return tView;
}

- (void)pickerView:(UIPickerView *)pView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pView == self.metTempoPickerView) {
        // BPM : 60 = Hz : 1  => dt between beats = 60/BPM sec.
        [[BBSetting sharedInstance] setBpm:row+20];
    } else if (pView == self.strikesPickerView) {
        // strikes picker
        int strike = ((NSNumber*)[_strikeValues objectAtIndex:row]).intValue;
        [BBUISettings instance].strikesFilterNum = strike;

    } else if (pView == self.timeSignaturePickerView) {
        // time signature picker
        int ts = ((NSNumber*)[_timeSignatureValues objectAtIndex:row]).intValue;
        [BBUISettings instance].timeSignatureNum = ts;
    }
}

#pragma mark ---- ViewController bookeeping

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"main_menu_controls"];
        
        self.MetronomeSounds = [NSArray arrayWithObjects:@"beep", @"stick", @"clap",  nil];
        _strikeValues = [@[@2, @4, @8, @16]retain];
        _timeSignatureValues = [@[@1, @2, @3, @4]retain];
    }
    
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [_metTempoPickerView selectRow:40 inComponent:0 animated:NO];
    
    //Add metronome view to flippingview
    [_flippingView addSubview:_metronomeView];
    
   
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_page.png"]];
    [_helpView addSubview:imageView];
    [_helpView setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
     _helpView.scrollEnabled = YES;
    _helpView.backgroundColor = [UIColor blackColor];
    _helpView.canCancelContentTouches = NO;
    _helpView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [imageView release];

    [self.strikesPickerView selectRow:[_strikeValues indexOfObject:[NSNumber numberWithInt: [BBUISettings instance].strikesFilterNum]]  inComponent:0 animated:NO];
    
    [self.timeSignaturePickerView selectRow:[_timeSignatureValues indexOfObject:[NSNumber numberWithInt: [BBUISettings instance].timeSignatureNum]]  inComponent:0 animated:NO];
    
    if (oldView == nil)
        oldView = _metronomeView;   //set it to view seen on load
    
    // customize bpm view switcher
    self.runViewSwitch.onTintColor = [UIColor darkGrayColor];
    self.runViewSwitch.offTintColor = [UIColor lightGrayColor];
    [self.runViewSwitch setKnobStartColor:[UIColor blackColor]];
    
    // customize bpm view switcher
    self.bpmViewSwitch.onTintColor = [UIColor darkGrayColor];
    self.bpmViewSwitch.offTintColor = [UIColor lightGrayColor];
    [self.bpmViewSwitch setKnobStartColor:[UIColor blackColor]];
    self.bpmViewSwitch.onText =@"";
    self.bpmViewSwitch.offText =@"";
    self.bpmViewSwitch.on = YES; // digital view is turned on by default
    
    // nav bar control needs to display settings by default
    self.navBarControl.selectedSegmentIndex =1;
}

- (void)viewDidUnload {
    [self setBpmViewSwitchImage:nil];
    [super viewDidUnload];
    [self setStrikesPickerView:nil];
    [self setBpmViewSwitch:nil];
    [self setNavBarControl:nil];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_statsData){
        [_statsData release];
    }
    _statsData = [[[RunController instance] getRunStatsAscending:NO] retain];
    
    [self.statsTable reloadData];
    
    [self.statsTable registerNib:[UINib nibWithNibName:@"StatsCell" bundle:nil] forCellReuseIdentifier:@"StatsCellIdentifier"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)dealloc
{
    [_strikeValues release];
    [_strikesPickerView release];
    [_bpmViewSwitch release];
    [_navBarControl release];
    [_bpmViewSwitchImage release];
    [_runViewSwitch release];
    [_timeSignaturePickerView release];
    
    [_statsData release];
    [_strikeValues release];
    [_timeSignatureValues release];
    
    [_statsTable release];
    [super dealloc];
}

@end
