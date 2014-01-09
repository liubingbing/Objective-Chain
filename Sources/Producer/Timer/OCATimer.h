//
//  OCATimer.h
//  Objective-Chain
//
//  Created by Martin Kiss on 31.12.13.
//  Copyright © 2014 Martin Kiss. All rights reserved.
//

#import "OCAProducer.h"

@class OCAQueue;





/// Timer is a Producer, that periodically sends current dates.
@interface OCATimer : OCAProducer



#pragma mark Creating Timer

- (instancetype)initWithTarget:(OCAQueue *)targetQueue
                         delay:(NSTimeInterval)delay
                      interval:(NSTimeInterval)interval
                        leeway:(NSTimeInterval)leeway
                     untilDate:(NSDate *)date;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval;
+ (instancetype)timerWithInterval:(NSTimeInterval)interval until:(NSDate *)date;

+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval;
+ (instancetype)backgroundTimerWithInterval:(NSTimeInterval)interval until:(NSDate *)date;


#pragma mark Attributes of Timer

@property (atomic, readonly, strong) OCAQueue *queue;

@property (atomic, readonly, assign) NSTimeInterval delay;
@property (atomic, readonly, assign) NSTimeInterval interval;
@property (atomic, readonly, assign) NSTimeInterval leeway;
@property (atomic, readonly, copy) NSDate *date;


#pragma mark Stopping Timer

- (void)stop;



@end


