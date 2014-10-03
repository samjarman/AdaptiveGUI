//
//  EPAppDelegate.h
//  411
//
//  Created by Sam Jarman on 1/09/14.
//  Copyright (c) 2014 Sam Jarman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Trial.h"
@interface EPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

//Trial Data
@property (strong) NSMutableArray *trials;


//UI
@property (weak) IBOutlet NSTextField *questionText;
@property (weak) IBOutlet NSButton *btn1;
@property (weak) IBOutlet NSButton *btn2;
@property (weak) IBOutlet NSButton *btn3;
@property (weak) IBOutlet NSButton *btn4;
- (IBAction)buttonPressed:(id)sender;


//Tracking Data
@property NSInteger currentQ;
@property NSDate *startTime;
@property NSInteger questionCount;




@end
