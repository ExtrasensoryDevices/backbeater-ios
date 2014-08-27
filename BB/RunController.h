//
//  RunController.h
//  BB
//
//  Created by Alina Kholcheva on 2012-10-22.
//
//

#import <Foundation/Foundation.h>



@interface RunData: NSObject

@property (readonly) NSDate *date;
@property (readonly) NSUInteger runNumber;
@property (readonly) NSUInteger averageBPM;
@property (readonly) NSUInteger length;
@property (readonly) NSUInteger score;
@property (readonly) NSString *scoreString;
@property (readonly) NSString *trackTitle;

- (id) initWithDate:(NSDate*)date runNumber:(NSUInteger) runNumber averageBPM:(NSUInteger)averageBPM length:(NSUInteger)length score:(NSUInteger) score trackTitle:(NSString*)trackTitle;
@end



@interface RunController : NSObject

@property (readonly) BOOL isCounting;

+(RunController*) instance;

-(void) startRun;
-(void) stopRun:(NSInteger) average;
-(RunData*) getLatestRun;
-(NSArray*) getRunStatsAscending:(BOOL) ascending;

-(void)recordBPM:(float)currentBpm average:(float) averageBPM;
- (NSUInteger) getValidStrikesNumber;


@end
