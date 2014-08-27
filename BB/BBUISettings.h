//
//  BBUISettings.h
//  BB
//
//  Created by Alina Kholcheva on 2012-10-05.
//
//

#import <Foundation/Foundation.h>

@interface BBUISettings : NSObject

@property (nonatomic) BOOL bpmDigitalViewOff;
@property (nonatomic) BOOL runViewOff;
@property (nonatomic, assign) int strikesFilterNum;
@property (nonatomic, assign) int timeSignatureNum;

@property (nonatomic, retain) NSString *trackTitle;

+(BBUISettings*) instance;
@end
