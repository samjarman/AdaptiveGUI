//
//  EPAppDelegate.m
//  411
//
//  Created by Sam Jarman on 1/09/14.
//  Copyright (c) 2014 Sam Jarman. All rights reserved.
//

#import "EPAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))


@implementation EPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Welcome to the experiment. First, you will have a few practice questions. Then, you'll have a larger set of questions to complete." defaultButton:@"Begin" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
    
    
    self.questionCount = 3;
    [self generateQuestions];
    
    
    [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"/Users/samjarman/Dropbox/Honours/COSC411/Logs/%lu.txt", (unsigned long)self.hash] contents:nil attributes:nil];

    
}
-(void)generateQuestions{
    self.trials = [[NSMutableArray alloc] init];
    for (int i = 0; i< self.questionCount; i++) {
        [self generateQuestionWithType:Control];
        [self generateQuestionWithType:EphemeralCorrect];
        [self generateQuestionWithType:EphemeralIncorrect];
        [self generateQuestionWithType:KineticonCorrect];
        [self generateQuestionWithType:KineticonIncorrect];
    }
    
    [self shuffleArray:self.trials];
    
    self.currentQ = 0;
    [self displayQuestion:self.trials[self.currentQ]];
    
}

-(void)generateQuestionWithType:(TrialType) type{
    
    Trial *t = [[Trial alloc] init];
    
    //Generate Numbers
    
    t.op1 = (int) RAND_FROM_TO(1, 10);
    t.op2 = (int) RAND_FROM_TO(1, 10);

    //Generate Op
    NSArray *ops = @[@"+", @"-", @"x"];
    NSUInteger randomIndex = arc4random() % [ops count];
    t.operatorString = ops[randomIndex];

    //Set answer
    t.answer = [self getAnswerForQuestionWithOperator:t.operatorString andOp1:t.op1 andOp2:t.op2];
    
    //Generate other answers (4)
    t.options = [[NSMutableArray alloc] init];
    [t.options addObject:[NSNumber numberWithInteger:t.op1 + t.op2]];
    [t.options addObject:[NSNumber numberWithInteger:t.op1 - t.op2]];
    [t.options addObject:[NSNumber numberWithInteger:t.op1 * t.op2]];
    [t.options addObject:[NSNumber numberWithInteger:t.op1 + t.op1 + t.op2 + t.op2]];
    [self shuffleArray:t.options];
    
    t.type = type;
    
    [self.trials addObject:t];
    
}


-(NSInteger)getAnswerForQuestionWithOperator:(NSString *)operator andOp1:(NSInteger)op1 andOp2:(NSInteger)op2{
    if ([operator isEqualToString:@"+"]) return op1 + op2;
    if ([operator isEqualToString:@"-"]) return op1 - op2;
    if ([operator isEqualToString:@"x"]) return op1 * op2;
    return 0;
}

- (void)shuffleArray:(NSMutableArray *) array {
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform(remainingCount);
        [array exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

-(void)displayQuestion:(Trial *)t{
    
    self.btn1.alphaValue = 0;
    self.btn2.alphaValue = 0;
    self.btn3.alphaValue = 0;
    self.btn4.alphaValue = 0;

    
    self.questionText.stringValue = [NSString stringWithFormat:@"What is %ld %@ %ld?", t.op1, t.operatorString, t.op2];
    self.btn1.title = [NSString stringWithFormat:@"%@", t.options[0]];
    self.btn2.title = [NSString stringWithFormat:@"%@", t.options[1]];
    self.btn3.title = [NSString stringWithFormat:@"%@", t.options[2]];
    self.btn4.title = [NSString stringWithFormat:@"%@", t.options[3]];
    
    NSButton *correctAnswer;
    
    if (t.answer == [t.options[0] integerValue]) {
        correctAnswer = self.btn1;
    }
    if (t.answer == [t.options[1] integerValue]) {
        correctAnswer = self.btn2;
    }
    if (t.answer == [t.options[2] integerValue]) {
        correctAnswer = self.btn3;
    }
    if (t.answer == [t.options[3] integerValue]) {
        correctAnswer = self.btn4;
    }
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithArray:@[self.btn1, self.btn2, self.btn3, self.btn4]];
    [buttons removeObject:correctAnswer];
    
    NSButton *wrong;
   
    int wrongIndex =arc4random() % [buttons count];
    wrong = (NSButton *)[buttons objectAtIndex:wrongIndex];

    //t.type = EphemeralIncorrect;
    switch (t.type) {
        case EphemeralCorrect:
            //Show correct first, fade in the rest.
            correctAnswer.alphaValue = 1;
            for (int i = 0; i < [buttons count]; i ++) {
                [self fadeInButton:buttons[i]];
            }

            break;
        case EphemeralIncorrect:
            //Show a wrong one first and then fade in rest
            [buttons removeObjectAtIndex:wrongIndex];
            wrong.alphaValue = 1;
            
            for (int i = 0; i < [buttons count]; i ++) {
                [self fadeInButton:buttons[i]];
            };
            [self fadeInButton:correctAnswer];
            break;
            
        case KineticonCorrect:
            //Show all, wiggle correct.
            for (int i = 0; i < [buttons count]; i ++) {
                ((NSButton *)buttons[i]).alphaValue = 1;
            }
            correctAnswer.alphaValue = 1;
            [self wiggleButton:correctAnswer];

            break;
        case KineticonIncorrect:
            //Show all, wiggle incorrect.
            for (int i = 0; i < [buttons count]; i ++) {
                ((NSButton *)buttons[i]).alphaValue = 1;
            }
            correctAnswer.alphaValue = 1;

            [self wiggleButton:wrong];
            break;
        default:
            for (int i = 0; i < [buttons count]; i ++) {
                ((NSButton *)buttons[i]).alphaValue = 1;
            }
            correctAnswer.alphaValue = 1;
            break;
    }
    
    self.startTime = [NSDate date];
    

    
}

- (void)fadeInButton:(NSButton *) button{

    button.wantsLayer = YES;
    

    CABasicAnimation *fadeInAndOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAndOut.duration = 1.0; //TODO decide this
    fadeInAndOut.autoreverses = NO;
    fadeInAndOut.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAndOut.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAndOut.repeatCount = 0;
    fadeInAndOut.fillMode = kCAFillModeBoth;
    //update the model position
    button.alphaValue = 1;
    [button.layer addAnimation:fadeInAndOut forKey:nil];
    
    
}

- (void)wiggleButton:(NSButton *) button{
//    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    
//    CGFloat wobbleAngle = 0.25f;
//    
//    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
//    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
//    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
//    
//    animation.autoreverses = YES;
//    animation.duration = 0.5;
//    animation.repeatCount = 1;
//    [button.layer addAnimation:animation forKey:nil];
    
    button.wantsLayer = YES;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values = @[ @0, @10, @-10, @10, @0 ];
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 1.0;
    animation.additive = YES;
    [button.layer addAnimation:animation forKey:@"shake"];
    
    
}



- (IBAction)buttonPressed:(id)sender {
    NSButton *b = (NSButton *)sender;
    //NSLog(@"Button with answer %@ pressed", b.title);
    Trial *t  = self.trials[self.currentQ];
    
    //Log out trial
    
    NSString *str = [NSString stringWithFormat:@"\n %ld, %ld, %0.5f, %i", (long)self.currentQ, t.type,[[NSDate date] timeIntervalSinceDate:self.startTime], [b.title integerValue] == t.answer]; //Your text or XML
    
    NSError* error = nil;
    NSString* contents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/Users/samjarman/Dropbox/Honours/COSC411/Logs/%lu.txt", (unsigned long)self.hash]
                                                   encoding:NSUnicodeStringEncoding
                                                      error:&error];
    //NSUTF8StringEncoding
    
    contents = [contents stringByAppendingString:str];
    
    if(error) { // If error object was instantiated, handle it.
        NSLog(@"ERROR while loading from file: %@", error);
        // …
    }
    [contents writeToFile:[NSString stringWithFormat:@"/Users/samjarman/Dropbox/Honours/COSC411/Logs/%lu.txt", (unsigned long)self.hash]  atomically:YES
                 encoding:NSUnicodeStringEncoding
                    error:&error];
    
    
    NSLog(@"%ld, %ld, %0.5f, %i", (long)self.currentQ, t.type,[[NSDate date] timeIntervalSinceDate:self.startTime], [b.title integerValue] == t.answer);

    
    self.currentQ ++;
    if (self.currentQ < self.trials.count){
        [self displayQuestion:self.trials[self.currentQ]];
    } else if( self.questionCount == 3){ //End of trial
        NSAlert *alert = [NSAlert alertWithMessageText:@"End of the practice round. You now have a longer series of questions to answer. Please answer as quickly and as accurately as you can." defaultButton:@"Start" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
        self.questionCount = 20;
        [self generateQuestions];
    } else {
        self.questionText.stringValue = @"Thank you";
        [self.btn1 setHidden:YES];
        [self.btn2 setHidden:YES];
        [self.btn3 setHidden:YES];
        [self.btn4 setHidden:YES];

        NSAlert *alert = [NSAlert alertWithMessageText:@"End of the Experiment. Thank you." defaultButton:@"Done" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    }
    
}





@end
