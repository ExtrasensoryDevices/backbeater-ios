//
//  LedView.h
//  BB
//
//  Created by Alina Kholcheva on 2012-11-16.
//
//

#import <UIKit/UIKit.h>

@interface LedView : UIImageView

-(void) reset;
-(void) bpmReading:(int)bpm average:(int) avg;

@end
