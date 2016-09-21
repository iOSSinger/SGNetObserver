//
//  ViewController.m
//  SGNetObserverDemo
//
//  Created by apple on 16/9/19.
//  Copyright © 2016年 iOSSinger. All rights reserved.
//

#import "ViewController.h"
#import "SGNetObserver.h"

@interface ViewController ()
@property (nonatomic,strong) SGNetObserver *observer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.observer = [SGNetObserver defultObsever];
    [self.observer startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:SGReachabilityChangedNotification object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SGReachabilityChangedNotification object:nil];
}
- (void)networkStatusChanged:(NSNotification *)notify{
    NSLog(@"notify-------%@",notify.userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
