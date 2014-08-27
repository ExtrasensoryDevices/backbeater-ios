//
//  RunController.m
//  BB
//
//  Created by Alina Kholcheva on 2012-10-22.
//
//

#import "RunController.h"
#import "BBSetting.h"
#import "BBUISettings.h"

#define kMaxHistory 20
#define kFileName @"stats.txt"

@implementation RunData


-(id) initWithDate:(NSDate *)date runNumber:(NSUInteger)runNumber averageBPM:(NSUInteger)averageBPM length:(NSUInteger)length score:(NSUInteger)score trackTitle:(NSString*)trackTitle
{
    self = [super init];
    if (self){
        _date = [date retain];
        _runNumber = runNumber;
        _averageBPM = averageBPM;
        _length = length;
        _score = score;
        _scoreString = [@"" retain];//TODO: add score string
        _trackTitle = [trackTitle retain];
    }
    return self;
}

-(NSString*) toString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    NSString *dateString=[dateFormatter stringFromDate:_date];
    [dateFormatter release];

    return [NSString stringWithFormat:@"%@::%d::%d::%d::%d::%@\n", dateString, _runNumber, _averageBPM, _length, _score, _trackTitle?_trackTitle:@""];
}

+(RunData*) fromString:(NSString*)data
{
    NSArray * a = [data componentsSeparatedByString:@"::"];
    
    if (a.count < 6){
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    NSDate *date=[dateFormatter dateFromString:[a objectAtIndex:0]];
    [dateFormatter release];
    
    NSInteger runNumber = [[a objectAtIndex:1] integerValue];
    NSInteger averageBPM = [[a objectAtIndex:2] integerValue];
    NSInteger length = [[a objectAtIndex:3] integerValue];
    NSInteger score = [[a objectAtIndex:4] integerValue];
    NSString *trackTitle = [a objectAtIndex:5];
    return [[[RunData alloc] initWithDate:date runNumber:runNumber averageBPM:averageBPM length:length score:score trackTitle:trackTitle] autorelease];
}


-(void)dealloc
{
    [_date release];
    [_trackTitle release];
    [_scoreString release];
    [super dealloc];
}


@end






@interface RunController(){
    NSUInteger _latestRunNumber;
    NSMutableArray *_runStats;
    
    // current run
    NSMutableArray *_currentRunData;
    NSUInteger _strikesFilterNum;
    NSString *_trackTitle;
}

@end

@implementation RunController

static  RunController *_sharedInstance;

+(RunController*) instance {
    return _sharedInstance;
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        _sharedInstance = [[RunController alloc] init];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self readRunDataFromStorage];
        _isCounting = NO;
    }
    return self;
}


-(void) readRunDataFromStorage
{
    // read data from storage
    _runStats = [[self loadFromFile]retain];
    [self sortArray:_runStats acsending:YES];
    _latestRunNumber = [[_runStats lastObject] runNumber];
}

-(void) saveRunDataToStorage{
    [self writeToFile];
}


- (NSUInteger) getValidStrikesNumber
{
    if (_isCounting){
        NSInteger valid = _currentRunData.count - (_strikesFilterNum - 1);
        return MAX(0, valid);
    } else {
        return 0;
    }
}



-(void) startRun
{
    _strikesFilterNum = [BBUISettings instance].strikesFilterNum;
    
    if (_currentRunData){
        [_currentRunData removeAllObjects];
    } else {
        _currentRunData = [[NSMutableArray alloc] init];
    }
    
    _trackTitle = [[BBUISettings instance].trackTitle retain];
    _isCounting = YES;
}



-(void) stopRun:(NSInteger) average
{
    
    if (!_isCounting){
        return;
    }
    
    _isCounting = NO;
    
    BOOL isValid = (_currentRunData.count > _strikesFilterNum-1);
    
    if (isValid){
        
        // copy run data before user starts new run
        NSArray *runData = [_currentRunData copy];
        int strikesFilterNum = _strikesFilterNum;
        
        int driftSum = 0;
        int validStrikes = runData.count - (strikesFilterNum - 1);
        // count strikes above averaging value
        for (int i =strikesFilterNum-1; i<runData.count; i++) {
            int drift = ((NSNumber*)[runData objectAtIndex:i]).intValue;
            driftSum += drift;
        }
        int score = 1000 * (1 - (float)driftSum / (8 * (float)validStrikes));        
        
        _latestRunNumber++;
        // add new run and save it to storage
        RunData *data = [[RunData alloc]initWithDate:[NSDate date] runNumber:_latestRunNumber averageBPM:average length:validStrikes score:score trackTitle:_trackTitle];
        
        [_runStats addObject:data];
        
        if (_runStats.count > kMaxHistory){
            [_runStats removeObjectAtIndex:0];
        }
        
        [self saveRunDataToStorage];
        [data release];
        [runData release];
    }
    [self clearRun];
        
}


-(void) recordBPM:(float)currentBpm average: (float) averageBpm {
    if (_isCounting){
        currentBpm = MIN(currentBpm, 210); // normalize bpm
        int drift = MIN(8, abs(averageBpm - currentBpm));
        [_currentRunData addObject: [NSNumber numberWithFloat:drift]];
    }
}


-(RunData*) getLatestRun
{
    return [_runStats lastObject];
}



-(NSArray*) getRunStatsAscending:(BOOL) ascending
{
    NSMutableArray *copy = [self sortArray: [[_runStats mutableCopy]autorelease] acsending:ascending] ;
    return copy;
}


-(void) clearRun
{
    [_currentRunData removeAllObjects];
    _strikesFilterNum = 0;
    [_trackTitle release];
    _trackTitle = nil;
}

-(void) dealloc
{
    [_runStats release];
    [_currentRunData release];
    [_trackTitle release];
    // TODO: add more
    [super dealloc];
}




-(NSMutableArray *) sortArray:(NSMutableArray*)array acsending:(BOOL) ascending
{
    if (array.count > 1){
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"runNumber" ascending:ascending];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        [array sortUsingDescriptors:sortDescriptors];
        [sortDescriptor release];
    }
    
    return array;
}

#pragma mark - 
#pragma mark serialization 

- (void) writeToFile {
    
    if (_runStats.count == 0){
        return;
    }
    
    
    NSString *textToWrite = @"";
    for (RunData *d in _runStats){
        textToWrite = [textToWrite stringByAppendingString:[d toString]];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kFileName];
    NSError *error;
    [textToWrite writeToFile:filePath atomically:YES encoding:NSUnicodeStringEncoding error: &error];
};


- (NSMutableArray *) loadFromFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:kFileName];
    NSError *error;
    NSString *textToLoad = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error: &error];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (textToLoad) {
        NSArray *a = [textToLoad componentsSeparatedByString:@"\n"];
        for (NSString *s in a){
            RunData *d = [RunData fromString:s];
            if (d){
                [result addObject:d];
            }
        }
    }
    return [result autorelease];
};


@end
