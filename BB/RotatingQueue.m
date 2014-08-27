//
//  RotatingQueue.m
//  BackBeater
//
//  Created by Alina Kholcheva on 2012-09-17.
//  Copyright (c) 2012. All rights reserved.
//

#import "RotatingQueue.h"

@implementation RotatingQueue
{
    int _capacity;
    NSMutableArray* _array;
    long _sum;
}

- (id)initWithCapacity: (int) capacity
{
    self = [super init];
    if (self) {
        _capacity = capacity;
        [self setArray:[NSMutableArray array]];
    }
    return self;
}

-(void) setArray:(NSMutableArray *)array
{
    if (_array != array)
    {
        [array retain];
        [_array release];
        _array = array;
    }
}

-(id) enqueue:(NSNumber*)value {
    NSNumber *fadingObject = nil;
    if (_array.count == _capacity){
        fadingObject = [_array objectAtIndex:0];
        [_array removeObjectAtIndex:0];
    }
    [_array addObject:value];
    [self updateAverageObjectRemoved:fadingObject objectAdded:value];
    return self;
}

-(NSNumber*) lastValue {
    return  [_array lastObject];
}

-(int) average {
    if (_array.count == 0){
        return 0;
    }
    return _sum / _array.count;
}

-(void) updateAverageObjectRemoved:(NSNumber*)objectRemoved objectAdded:(NSNumber*)objectAdded{
    if (_array.count == 0){
        _sum = 0;
        return;
    }
    if (objectRemoved){
        _sum -= [objectRemoved intValue];
    }
    if (objectAdded){
        _sum += [objectAdded intValue];
    }
    
}

-(NSString*) description {
    NSMutableString *res = [NSMutableString string];
    for (NSNumber *num in _array) {
        [res appendString:[NSString stringWithFormat:@", %@",num]];

    }
    return res;
}
-(void) reset {
    _sum =0;
    [_array removeAllObjects];
}
- (void)dealloc
{
    [_array release];
    [super dealloc];
}

@end
