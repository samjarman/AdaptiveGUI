//
//  Trial.h
//  411
//
//  Created by Sam Jarman on 3/09/14.
//  Copyright (c) 2014 Sam Jarman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trial : NSObject

typedef NS_ENUM(NSInteger, TrialType) {
    Control,
    EphemeralCorrect,
    EphemeralIncorrect,
    KineticonCorrect,
    KineticonIncorrect
};
@property NSString  *operatorString;
@property NSInteger op1;
@property NSInteger op2;
@property NSInteger answer;
@property NSMutableArray   *options;
@property TrialType type;



@end
