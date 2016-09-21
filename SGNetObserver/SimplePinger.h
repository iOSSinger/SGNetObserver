//
//  SimpleHeartbeat.h
//  SGNetObserverDemo
//
//  Created by apple on 16/9/20.
//  Copyright © 2016年 iOSSinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

@interface SimplePinger : NSObject

/**
 *  是否ping的通
 */
@property (nonatomic,assign) BOOL reachable;

/**
 *  有很小概率ping失败,设定多少次ping失败认为是断网,默认2次, 必须 >= 2
 */
@property (nonatomic,assign) NSUInteger failureTimes;

/**
 *  ping 的频率,默认1s
 */
@property (nonatomic,assign) NSTimeInterval interval;

/**
 *  是否支持IPv4,默认全部支持
 */
@property (nonatomic,assign) BOOL supportIPv4;

/**
 *  是否支持IPv6
 */
@property (nonatomic,assign) BOOL supportIPv6;

/**
 *  回调
 */
@property (nonatomic,copy) void(^networkStatusDidChanged)();


+ (instancetype)simplePingerWithHostName:(NSString *)hostName;

- (void)startNotifier;

- (void)stopNotifier;
@end
