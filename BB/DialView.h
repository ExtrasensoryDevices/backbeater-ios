//
//  DialView.h
//  BB
//
//  Created by Alina Kholcheva on 2012-09-19.
//
//

#import <UIKit/UIKit.h>
#define degreesToRadians(x) (M_PI * x / 180.0)
@interface DialView : UIView 
@property (retain, nonatomic) IBOutlet UIImageView *dialView;


-(void) bpmReading:(int) bpm average:(int) avg;
-(void) reset;
+(DialView*) view;
@end
