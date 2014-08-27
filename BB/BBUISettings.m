//
//  BBUISettings.m
//  BB
//
//  Created by Alina Kholcheva on 2012-10-05.
//
//

#import "BBUISettings.h"

@implementation BBUISettings

static  BBUISettings *_sharedInstance;

+(BBUISettings*) instance {
    return _sharedInstance;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        _sharedInstance = [[BBUISettings alloc] init];
        _sharedInstance.bpmDigitalViewOff = NO;
        _sharedInstance.runViewOff = YES;
        _sharedInstance.strikesFilterNum = 4;
        _sharedInstance.timeSignatureNum = 1;
        
       _sharedInstance.trackTitle = nil;
    }
}
@end
