
// MusicPlayerViewController.h
//
// Created by Adrian Boston and later modified by Sung Yoon
// Copyright (c) 2012 Bamsom. All rights reserved.

// MusicPlayerViewController is closely based on Apple AddMusic sample.
// MPMusicPlayer is quick and easy to implement, but appears to be less robust than AVPlayer.

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MusicPlayerViewController : UIViewController <MPMediaPickerControllerDelegate, AVAudioPlayerDelegate> {
        
	BOOL						playedMusicOnce;
    
	BOOL						interruptedOnPlayback;
	BOOL						playing ;
    
	MPMusicPlayerController		*musicPlayer;	
	MPMediaItemCollection		*userMediaItemCollection;
    
    IBOutlet UITableView		*_mediaItemCollectionTable; //AB
    
    IBOutlet UIButton *playPauseButton;
}

@property (readwrite)			BOOL					playedMusicOnce;

@property (nonatomic, retain)	MPMediaItemCollection	*userMediaItemCollection; 

@property (nonatomic, retain)	MPMusicPlayerController	*musicPlayer;

@property (readwrite)			BOOL					interruptedOnPlayback;

@property (readwrite)			BOOL					playing;

//AB Added these views and controllers
@property (nonatomic, retain) UITableView	*mediaItemCollectionTable;

@property (nonatomic, retain) IBOutlet UISegmentedControl *playPauseSegmentedControl;

@property (nonatomic, retain)  UIButton *playPauseButton;

- (IBAction) playOrPauseMusic: (id)sender;

- (IBAction)	AddMusicOrShowMusic:	(id) sender;

- (IBAction)    clearList          :    (id)sender;

- (void) reset ;

- (void) setupButtons;

- (void) handle_PlaybackStateChanged: (id) notification;

- (void)checkUncheck ;

@end
