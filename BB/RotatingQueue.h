//
//  RotatingQueue.h
//  BackBeater
//
//  Created by Alina Kholcheva on 2012-09-17.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RotatingQueue : NSObject
@property (nonatomic, readonly) int average;
@property (nonatomic, readonly) int capacity;

- (id)initWithCapacity: (int) capacity;
- (id) enqueue:(NSNumber *) value;
- (NSNumber*) lastValue;
- (void) reset;

@end
