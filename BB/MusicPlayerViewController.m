/*
 File: MusicPlayerViewController.m
 */

#import "MusicPlayerViewController.h"
#import <Foundation/Foundation.h>

#import "BBUISettings.h"

@implementation MusicPlayerViewController

@synthesize userMediaItemCollection;	// the media item collection created by the user, using the media item picker	
@synthesize musicPlayer;				// the music player, which plays media items from the iPod library

@synthesize interruptedOnPlayback;		// A flag indicating whether or not the application was interrupted during 
//		application audio playback
@synthesize playedMusicOnce;			// A flag indicating if the user has played iPod library music at least one time
//		since application launch.
@synthesize playing;					// An application that responds to interruptions must keep track of its playing/
//		not-playing state.



@synthesize mediaItemCollectionTable = _mediaItemCollectionTable;

@synthesize playPauseSegmentedControl = _playPauseSegmentedControl;

@synthesize playPauseButton;

#pragma mark Music control________________________________

// A toggle control for playing or pausing iPod library music playback, invoked
//		when the user taps the 'playBarButton' in the Navigation bar.
- (IBAction) playOrPauseMusic: (id)sender {
    
	MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[musicPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[musicPlayer pause];
	}
}


// Display the media item picker.
- (IBAction) AddMusicOrShowMusic: (id) sender {
    
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    picker.delegate						= self;
    picker.allowsPickingMultipleItems	= YES;
    
    [self presentModalViewController: picker animated: YES];
    [picker release];
}

- (IBAction)clearList:(id)sender {
    [musicPlayer stop];
    
    self.userMediaItemCollection = nil;
    [musicPlayer setQueueWithItemCollection:userMediaItemCollection];
    [self.mediaItemCollectionTable reloadData];
    
}

- (void) reset {
    [musicPlayer stop];
    
    self.userMediaItemCollection = nil;
    [musicPlayer setQueueWithItemCollection:userMediaItemCollection];
    [self.mediaItemCollectionTable reloadData];
}

// Invoked by the delegate of the media item picker when the user is finished picking music.
//		The delegate is either this class or the table view controller, depending on the 
//		state of the application.
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (userMediaItemCollection == nil) 
        {
            
			// apply the new media item collection as a playback queue for the music player
			[self setUserMediaItemCollection: mediaItemCollection];
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			[self setPlayedMusicOnce: YES];
			[musicPlayer play];
            
            [self checkUncheck];
            
		} 
        else 
        {
            
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= musicPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= musicPlayer.currentPlaybackTime;
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
			[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
			[combinedMediaItems release];
            
			// Apply the new media item collection as a playback queue for the music player.
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			musicPlayer.nowPlayingItem			= nowPlayingItem;
			musicPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[musicPlayer play];
			}
            
            [self checkUncheck];
		}
     
	}
}

// If the music player was paused, leave it paused. If it was playing, it will continue to
//		play on its own. The music player state is "stopped" only if the previous list of songs
//		had finished or if this is the first time the user has chosen songs after app 
//		launch--in which case, invoke play.
- (void) restorePlaybackState {
    
	if (musicPlayer.playbackState == MPMusicPlaybackStateStopped && userMediaItemCollection) {
		
		if (playedMusicOnce == NO) {
            
			[self setPlayedMusicOnce: YES];
			[musicPlayer play];
		}
	}
    
}



#pragma mark Media item picker delegate methods________

// Invoked when the user taps the Done button in the media item picker after having chosen
//		one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
    [self dismissModalViewControllerAnimated: YES];	// Dismiss the media item picker.
	
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];	// Apply the chosen songs to the music player's queue.
    
	[self.mediaItemCollectionTable reloadData];    // Add music to list
    
}

// Invoked when the user taps the Done button in the media item picker having chosen zero
//		media items to play
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissModalViewControllerAnimated: YES];
}



#pragma mark Music notification handlers__________________

- (void) handle_NowPlayingItemChanged: (id) notification {
    
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePlaying) {
        MPMediaItem *currItem = [musicPlayer nowPlayingItem];
        
        NSArray *mediaArray = [userMediaItemCollection items];
        
        if (currItem != NULL && mediaArray != NULL) {
            NSInteger currIndex = [mediaArray indexOfObject:currItem]; //find index of item at row    
            
            NSIndexPath *idx = [NSIndexPath indexPathForRow:currIndex inSection:0];
            
            // Select the row in the table
            // And push it to the top position
            [_mediaItemCollectionTable selectRowAtIndexPath:idx animated:NO scrollPosition: UITableViewScrollPositionMiddle];
        }
    }
    [self updateTrackTitle];
    [self checkUncheck];
    
}

// When the playback state changes, set the play/pause button in the Navigation bar
//      appropriately.
- (void) handle_PlaybackStateChanged: (id) notification {
    
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    
    if (playbackState == MPMusicPlaybackStatePaused) {
        
        [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if (playbackState == MPMusicPlaybackStatePlaying) {
        
        [self.playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if (playbackState == MPMusicPlaybackStateStopped) {
                
        [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        // Even though stopped, invoking 'stop' ensures that the music player will play  
        //      its queue from the start.
        [musicPlayer stop];
    }
    [self updateTrackTitle];
}



-(void) updateTrackTitle
{
    MPMusicPlaybackState playbackState = [musicPlayer playbackState];
    MPMediaItem *currItem = [musicPlayer nowPlayingItem];
    NSArray *mediaArray = [userMediaItemCollection items];
    if (currItem != NULL && mediaArray != NULL) {
        if (playbackState == MPMusicPlaybackStatePlaying) {
            [BBUISettings instance].trackTitle = [currItem valueForProperty: MPMediaItemPropertyTitle];
        } else {
            [BBUISettings instance].trackTitle = nil;
        }
    } else {
        [BBUISettings instance].trackTitle = nil;
    }

}


#pragma mark Table view delegate methods________________

//// Invoked when the user taps the Done button in the table view.
//- (void) musicTableViewControllerDidFinish: (MusicTableViewController *) controller {
//	
//	[self dismissModalViewControllerAnimated: YES];
//	[self restorePlaybackState];
//}
//

// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications {
    
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
	[notificationCenter addObserver: self
						   selector: @selector (handle_NowPlayingItemChanged:)
							   name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object: musicPlayer];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_PlaybackStateChanged:)
							   name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object: musicPlayer];
    
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [notificationCenter addObserver: self
     selector: @selector (handle_iPodLibraryChanged:)
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
     */
    
	[musicPlayer beginGeneratingPlaybackNotifications];
}


// Configure the application.
- (void) viewDidLoad {
    
    [super viewDidLoad];
    
	[self setPlayedMusicOnce: NO];
    	        
    [self setMusicPlayer: [MPMusicPlayerController applicationMusicPlayer]];
    
    // By default, an application music player takes on the shuffle and repeat modes
    //		of the built-in iPod app. Here they are both turned off.
    [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
	
	[self registerForMediaPlayerNotifications];
}


// Set up play/pause buttons 
- (void) setupButtons {
    
    if ( [musicPlayer nowPlayingItem] ) {
        
        [self handle_NowPlayingItemChanged: nil];         // Update the UI to reflect the now-playing item. 
        
        if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
        }
    }
}



#pragma mark Application state management_____________

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void) viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
    /*
     // This sample doesn't use libray change notifications; this code is here to show how
     //		it's done if you need it.
     [[NSNotificationCenter defaultCenter] removeObserver: self
     name: MPMediaLibraryDidChangeNotification
     object: musicPlayer];
     
     [[MPMediaLibrary defaultMediaLibrary] endGeneratingLibraryChangeNotifications];
     
     */
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
												  object: musicPlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
												  object: musicPlayer];
    
	[musicPlayer endGeneratingPlaybackNotifications];
	[musicPlayer				release];
    
    
	[userMediaItemCollection	release];
    
    [_mediaItemCollectionTable release];    // AB Added
    
    
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"main_menu_music"];
    }
    return self;
}

#pragma mark -- Check and Uncheck table cells 

- (void)checkUncheck {
    // Uncheck everything first            
    for (int row = 0, rowCount = [_mediaItemCollectionTable numberOfRowsInSection:0]; row < rowCount; ++row)
    {
        UITableViewCell *cell = [_mediaItemCollectionTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //                    cell.accessoryView = nil;
    }
    
    MPMediaItem *currItem = [musicPlayer nowPlayingItem]; 
    NSArray *mediaArray = [userMediaItemCollection items];
    NSInteger currIndex = [mediaArray indexOfObject:currItem]; //find index of item at row    
    
    NSIndexPath *idx = [NSIndexPath indexPathForRow:currIndex inSection:0];
    // Check currently playing item cell
    UITableViewCell *nowPlayingCell = [_mediaItemCollectionTable cellForRowAtIndexPath:idx];
    nowPlayingCell.selectionStyle = UITableViewCellSelectionStyleNone ;
    nowPlayingCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

@end




