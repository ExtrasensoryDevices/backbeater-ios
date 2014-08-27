//
//  LedView.m
//  BB
//
//  Created by Alina Kholcheva on 2012-11-16.
//
//

#import "LedView.h"

@implementation LedView {
    int _ledNum;
}

static NSArray *amberLEDImgs;
static NSArray *redLEDImgs;
static NSString *allOffLED = @"all_off.png";

+(void) initialize {
    if (!amberLEDImgs)
        amberLEDImgs =[@[@"amber01.png", @"amber02.png",@"amber03.png",@"amber04.png",@"amber05.png",@"amber06.png",@"amber07.png",@"amber08.png"] retain];
    if (!redLEDImgs)
        redLEDImgs =  [@[@"red01.png", @"red02.png",@"red03.png",@"red04.png",@"red05.png",@"red06.png",@"red07.png",@"red08.png"] retain];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(NSString *) ledImageForNum:(int) num {
    if (num ==0) return allOffLED;
    int ledIdx = MIN(7, abs(num)-1);
    if (num <0) return amberLEDImgs[ledIdx];
    else return redLEDImgs[ledIdx];
}


-(void) showRunningLedsForNum: (int) num {
    if (!_ledNum) _ledNum =0;
    [self setImage:[UIImage imageNamed:[self ledImageForNum: num]]];
    NSMutableArray *animationImgs = [[NSMutableArray alloc] init];
    if (_ledNum < num) {
        for (int i=_ledNum +1; i <= num; i++) {
            [animationImgs addObject:[UIImage imageNamed:[self ledImageForNum: i]]];
        }
    } else if (_ledNum > num) {
        for (int i = _ledNum -1; i >= num; i--) {
            [animationImgs addObject:[UIImage imageNamed:[self ledImageForNum: i]]];
        }
    }
    self.animationImages = animationImgs;
    [animationImgs release];
    self.animationDuration = .5;
    self.animationRepeatCount =1;
    [self startAnimating];
    _ledNum = num;
}

-(void) reset {
    // scroll to beginning.
    [self bpmReading:0 average:0];
}

-(void) bpmReading:(int)bpm average:(int) avg {
    //    NSLog(@" bpm: %d avg: %d", bpm, avg);
    // normalize received average value as we can't display more than 210 bpm
    int normalizedBpm = MIN(avg, 210);
    int ledNum;
    if (bpm ==0) {
         ledNum =0;
    } else {
        ledNum = bpm - normalizedBpm;
    }
    
    
    [self showRunningLedsForNum:ledNum];
    
}

@end
