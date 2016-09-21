//
//  SimpleHeartbeat.m
//  SGNetObserverDemo
//
//  Created by apple on 16/9/20.
//  Copyright © 2016年 iOSSinger. All rights reserved.
//

#import "SimplePinger.h"
#import "SimplePing.h"
#include <netdb.h>

@interface SimplePinger()<SimplePingDelegate>

@property (nonatomic,strong) SimplePing *pinger;

@property (nonatomic,copy)   NSString *hostName;

@property (nonatomic,strong) NSTimer *sendTimer;

/**
 *  发送失败记录,失败次数为failuretimes时,认为断网.
 */
@property (nonatomic,strong) NSMutableArray *array;

@end

@implementation SimplePinger

#pragma mark - 初始化
+ (instancetype)simplePingerWithHostName:(NSString *)hostName{
    SimplePinger *pinger = [[SimplePinger alloc] init];
    pinger.hostName = hostName;
    return pinger;
}

- (instancetype)init{
    if(self = [super init]){
        self.interval = 1.0;
        self.failureTimes = 2;
        self.reachable = YES;
    }
    return self;
}
- (void)dealloc{
    
    [self stopPing];
    [self.array removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendPing) object:nil];
}
#pragma mark - function

- (void)startNotifier{
    [self startForceIPv4:self.supportIPv4 forceIPv6:self.supportIPv6];
}

- (void)stopNotifier{
    [self stopPing];
}

- (void)startForceIPv4:(BOOL)forceIPv4 forceIPv6:(BOOL)forceIPv6{
    self.pinger = [[SimplePing alloc] initWithHostName:self.hostName];
    if (forceIPv4 && !forceIPv6) {
        self.pinger.addressStyle = SimplePingAddressStyleICMPv4;
    }else if (forceIPv6 && !forceIPv4){
        self.pinger.addressStyle = SimplePingAddressStyleICMPv6;
    }else{
        self.pinger.addressStyle = SimplePingAddressStyleAny;
    }
    
    self.pinger.delegate = self;
    
    [self.pinger start];
}

- (void)sendPing{
    [self.pinger sendPingWithData:nil];
}

- (void)stopPing{
    [self.pinger stop];
     self.pinger.delegate = nil;
     self.pinger = nil;
    
    [self.sendTimer invalidate];
     self.sendTimer = nil;
}

#pragma mark - delegaet
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address{
    NSLog(@"didStartPingWithAddress: %@",[self addressWithData:address]);
    
    [self sendPing];
    
    if (!_sendTimer) {
        _sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    }
}

//发送成功,sequenceNumber范围:0~65535,超范围后从 0 开始
- (void)simplsentePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
     NSLog(@"#%u sent", sequenceNumber);
    
    if(sequenceNumber == 0){//重置
        [self.array removeAllObjects];
    }
    
    //根据failuretimes判断是否有网
    if (self.array.count >= self.failureTimes) {
        self.reachable = NO;
        [self.array removeAllObjects];
    }
    
    //将本次记录加入
    [self.array addObject:@(sequenceNumber)];
}

//发送失败
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error{
    NSLog(@"#%u fail sent",sequenceNumber);
    
    //发送失败,直接认为断网
     self.reachable = NO;
    [self.array removeAllObjects];
}

//接收成功
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber{
    //有网
     self.reachable = YES;
    [self.array removeAllObjects];
}

//未知失败,重启ping
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error{
     self.reachable = NO;
    [self stopPing];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startNotifier];
    });
    
}

//根据data,计算host
- (NSString *)addressWithData:(NSData *)address{
    char *hostStr = malloc(NI_MAXHOST);
    memset(hostStr, 0, NI_MAXHOST);
    BOOL success = getnameinfo((const struct sockaddr *)address.bytes, (socklen_t)address.length, hostStr, (socklen_t)NI_MAXHOST, nil, 0, NI_NUMERICHOST) == 0;
    NSString *result;
    if (success) {
        result = [NSString stringWithUTF8String:hostStr];
    }else{
        result = @"?";
    }
    free(hostStr);
    return  result;
}
#pragma mark - setter
- (void)setReachable:(BOOL)reachable{
    if (_reachable != reachable) {
        _reachable = reachable;
        if (self.networkStatusDidChanged) {
            self.networkStatusDidChanged();
        }
    }
}

- (void)setFailureTimes:(NSUInteger)failureTimes{
    if (failureTimes < 2) {
        failureTimes = 2;
    }
    _failureTimes = failureTimes;
}

- (NSMutableArray *)array{
    if (_array == nil) {
        _array = [NSMutableArray array];
    }
    return _array;
}
@end
