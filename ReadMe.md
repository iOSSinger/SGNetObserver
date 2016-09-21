#iOS完美的网络状态判断工具
大多数App都严重依赖于网络,一款用户体验良好的的app是必须要考虑网络状态变化的.iOSSinger下一般使用Reachability这个类来检测网络的变化.
####Reachability
这个是苹果开发文档里面的一个类,官方写的,用来判断网络的变化,包括无网络,wifi,和蜂窝三种情况.官方地址:[**点我查看**](<https://developer.apple.com/library/content/samplecode/Reachability/Introduction/Intro.html>).Reachability类实际上是苹果公司对SCNetworkReachability API的封装,使用方法比较简单,这里不再介绍.说说它的优缺点:

* 优点
   * 使用简单,只有一个类,官方还有Demo,容易上手 
   * 灵敏度高,基本网络一有变化,基本马上就能判断出来
   * 能够判断有网状态的切换比如2G/3G/4G切换
* 缺点
   * 不能判断路由器本身是否能联网
   * 能否连接到指定服务器,比如国内访问墙外的服务器
   * 有网,但是信号很差,网速很慢,跟没网一样.这时候应该认为无网.
   
####解决方案
事实上Reachability已经很好了,但是实际上客户端到达服务器需要很多道"关卡",例如路由器,电信服务器,防火墙等.其实说白了就是解决一个问题:***`客户端是否能够成功访问服务器`***.这里介绍另外一个官方的类:SimplePing[**点我查看**](https://developer.apple.com/library/content/samplecode/SimplePing/Introduction/Intro.html#//apple_ref/doc/uid/DTS10000716-Intro-DontLinkElementID_2).

####SimplePing
SimplePing也是官方文档的一个类,目的是ping服务器,可以判断客户端是否可以连接到指定服务器.ping 类似于心跳包功能,隔一段时间就ping下服务器,看是否畅通无阻.因此ping不可能做到及时判断网络变化,会有一定的延迟.可能大家已经猜到了我的思路,没错,把他们两个合在一起.下面说说我的思路:

  * 首先利用Reachability判断设备是否联网,至于能不能连接到服务器用ping来检查
  * 如果Reachability判断为有网,并且ping也判断为有网,那么表示真的有网,否则就是没网.
  * ping 虽然能够判断客户端到服务器是否畅通,但是由于网络抖动或者网络很弱等原因,可能出现ping失败的情况,解决方案就是加上失败次数限制,超过限制就认为断网了.
  * 2/3/4G切换的时候,Reachability虽然检测到了网络变化,但是类型还是蜂窝移动,不能给出具体的网络类型.这里可以通过获取状态栏上的属性来判断.
  
  ```
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
  
  ```
  可喜的是,即使隐藏了状态栏,判断依然有效!

####其他细节
* 默认采用host为`www.baidu.com`,别喷我,不是给百度打广告,而是因为百度真的只适合判断有没有网,因为响应真的很快.当然也可以用自己的服务器地址,这样更加真实,万一你家的服务器很渣或者突然crash了也能够完美判断.
* 判断具体网络类型的时候,实际上用kvc获取了控件的私有属性,根据网上的反应,没有因此被拒的情况,因此不用担心.如果因为这个原因被拒,请联系我第一时间修改.
* 支持全局通知和代理的方式.默认全局发送通知,如果设置了'delegate'这个属性,那么只有代理会收到通知,不在发送全局通知.如果想两种方式并存,可以新建一个'SGNetObserver'对象.
       
  PS:貌似苹果官方的原话是'调用了系统的私有api会被拒'.
  
* 支持模拟器,支持IPv4,IPv6

详细代码在这里:github地址:<https://github.com/iOSSinger/SGNetObserver>,支持cocoapods,欢迎使用!
  
最后,如果有什么不对,欢迎大家留言指正.