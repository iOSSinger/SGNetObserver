//
//  SGNetObserver.m
//  SGNetObserverDemo
//
//  Created by apple on 16/9/19.
//  Copyright © 2016年 iOSSinger. All rights reserved.
//

#import "SGNetObserver.h"
#import "Reachability.h"
#import "SimplePinger.h"

NSString *SGReachabilityChangedNotification = @"SGNetworkReachabilityChangedNotification";

@interface SGNetObserver()

@property (nonatomic,copy) NSString *host;

@property (nonatomic,strong) Reachability *hostReachability;

@property (nonatomic,strong) SimplePinger *pinger;
@end

@implementation SGNetObserver
#pragma mark - 初始化
+ (instancetype)defultObsever{
    SGNetObserver *obsever = [[self alloc] init];
    obsever.host = @"www.baidu.com";
    return obsever;
}

+ (instancetype)observerWithHost:(NSString *)host{
    SGNetObserver *obsever = [[self alloc] init];
    obsever.host = host;
    return obsever;
}

- (instancetype)init{
    if (self = [super init]) {
        _networkStatus = -1;
        _failureTimes = 2;
        _interval = 1.0;
    }
    return self;
}

- (void)dealloc{
    [self.hostReachability stopNotifier];
    [self.pinger stopNotifier];
}
#pragma mark - function

- (void)startNotifier{
    [self.hostReachability startNotifier];
    [self.pinger startNotifier];
}

- (void)stopNotifier{
    [self.hostReachability stopNotifier];
    [self.pinger stopNotifier];
}

#pragma mark - delegate
- (void)networkStatusDidChanged{
    
    //获取两种方法得到的联网状态,并转为BOOL值
    BOOL status1 = [self.hostReachability currentReachabilityStatus];
    
    BOOL status2 =  self.pinger.reachable;
    
    //综合判断网络,判断原则:Reachability -> pinger
    if (status1 && status2) {//有网
        self.networkStatus = self.netWorkDetailStatus;
    }else{//无网
        self.networkStatus = SGNetworkStatusNone;
    }
}

#pragma mark - setter
- (void)setNetworkStatus:(SGNetworkStatus)networkStatus{
    if (_networkStatus != networkStatus) {
        _networkStatus = networkStatus;
        
        NSLog(@"网络状态-----%@",self.networkDict[@(networkStatus)]);
        
        //有代理
        if(self.delegate){//调用代理
            if ([self.delegate respondsToSelector:@selector(observer:host:networkStatusDidChanged:)]) {
                [self.delegate observer:self host:self.host networkStatusDidChanged:networkStatus];
            }
        }else{//发送全局通知
            NSDictionary *info = @{@"status" : @(networkStatus),
                                   @"host"   : self.host      };
            [[NSNotificationCenter defaultCenter] postNotificationName:SGReachabilityChangedNotification object:nil userInfo:info];
        }
    }
    
}
#pragma mark - getter

- (Reachability *)hostReachability{
    if (_hostReachability == nil) {
        _hostReachability = [Reachability reachabilityWithHostName:self.host];
        
        __weak typeof(self) weakSelf = self;
        [_hostReachability setNetworkStatusDidChanged:^{
            [weakSelf networkStatusDidChanged];
        }];
    }
    return _hostReachability;
}

- (SimplePinger *)pinger{
    if (_pinger == nil) {
        _pinger = [SimplePinger simplePingerWithHostName:self.host];
        _pinger.supportIPv4 = self.supportIPv4;
        _pinger.supportIPv6 = self.supportIPv6;
        _pinger.interval = self.interval;
        _pinger.failureTimes = self.failureTimes;
        
        __weak typeof(self) weakSelf = self;
        [_pinger setNetworkStatusDidChanged:^{
            [weakSelf networkStatusDidChanged];
        }];
    }
    return _pinger;
}
#pragma mark - tools
- (SGNetworkStatus)netWorkDetailStatus{
    UIApplication *app = [UIApplication sharedApplication];
    UIView *statusBar = [app valueForKeyPath:@"statusBar"];
    UIView *foregroundView = [statusBar valueForKeyPath:@"foregroundView"];
    
    UIView *networkView = nil;
    
    for (UIView *childView in foregroundView.subviews) {
        if ([childView isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            networkView = childView;
        }
    }
    
    SGNetworkStatus status = SGNetworkStatusNone;
    
    if (networkView) {
        int netType = [[networkView valueForKeyPath:@"dataNetworkType"]intValue];
        switch (netType) {
            case 0:
                status = SGNetworkStatusNone;
                break;
            case 1://实际上是2G
                status = SGNetworkStatusUkonow;
                break;
            case 2:
                status = SGNetworkStatus3G;
                break;
            case 3:
                status = SGNetworkStatus4G;
                break;
            case 5:
                status = SGNetworkStatusWifi;
                break;
            default:
                status = SGNetworkStatusUkonow;
                break;
        }
    }
    return status;
}

- (NSDictionary *)networkDict{
    return @{
             @(SGNetworkStatusNone)   : @"无网络",
             @(SGNetworkStatusUkonow) : @"未知网络",
             @(SGNetworkStatus3G)     : @"3G网络",
             @(SGNetworkStatus4G)     : @"4G网络",
             @(SGNetworkStatusWifi)   : @"WIFI网络",
            };
}
@end
