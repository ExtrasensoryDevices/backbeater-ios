//
//  DialView.m
//  BB
//
//  Created by Alina Kholcheva on 2012-09-19.
//
//

#import "DialView.h"

@implementation DialView{
    float _angle;
}


-(void) bpmReading:(int)bpm average:(int) avg {
//    NSLog(@" bpm: %d avg: %d", bpm, avg);
    // normalize received average value as we can't display more than 210 bpm
    int normalizedBpm = MIN(avg, 210);
    float rotation;
    if (bpm ==0) {
        // rotate to initial position
        rotation =0;
    } else {
        rotation = - (normalizedBpm - 20) * 1.8f;
    }
   
    [UIView animateWithDuration:1 delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _dialView.transform = CGAffineTransformMakeRotation(degreesToRadians(rotation));
                     }
                     completion:NULL];
}

-(void) reset {
     // scroll to beginning.
    [self bpmReading:0 average:0];
}

- (void)dealloc {
    [_dialView release];
    [super dealloc];
}
+(DialView*) view{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"DialView" owner:nil options:nil];
    return (DialView*)[subviewArray objectAtIndex:0];
}

@end
