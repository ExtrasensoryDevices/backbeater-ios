//
//  MusicPlayerControllerHelper.m


#import "MusicPlayerViewControllerHelper.h"

@implementation MusicPlayerViewController (MusicPlayerViewControllerHelper)

static NSString *kCellIdentifier = @"Cell";


#pragma mark Table view methods________________________

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
    MPMediaItemCollection *currentQueue = self.userMediaItemCollection;
	return [currentQueue.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
	NSInteger row = [indexPath row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
									   reuseIdentifier: kCellIdentifier] autorelease];
	}
	
    MPMediaItemCollection *currentQueue = self.userMediaItemCollection;
    
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
	
	if (anItem) {
		cell.textLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
	}
    	
	return cell;
}

//
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    // SY: deselect, against Apple guideline otherwise.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger row = [indexPath row];    //There is only one section
    
    NSArray *mediaArray = [userMediaItemCollection items];
    
	MPMediaItem *currItem = [musicPlayer nowPlayingItem];
    
    NSInteger currIndex = [mediaArray indexOfObject:currItem]; //find index of item at row
    
    // If user select the item currently playing, do nothing.
    if (currIndex == indexPath.row) {
        return;
    }
    
    // Remove checkmark of cell currently playing. This may be redundant.
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:currIndex inSection:0];
    UITableViewCell *oldSelectedCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    oldSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    NSInteger diff = row - currIndex;
    
    for (int i=0; i<abs(diff); i++) {           //Move forward or back 
        if (diff > 0) {
            [musicPlayer skipToNextItem];
        }
        else {
            [musicPlayer skipToPreviousItem];
        }
    }
    
    // Checkmark new selection, this may be redundant.
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:currIndex inSection:0];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
}


@end
