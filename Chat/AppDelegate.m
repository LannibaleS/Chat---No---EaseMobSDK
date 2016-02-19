//
//  AppDelegate.m
//  Chat
//
//  Created by skyharuhi on 16/2/2.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "AppDelegate.h"
#import "EaseMob.h"

@interface AppDelegate () <EMChatManagerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"沙盒路径:%@", NSHomeDirectory());
    
    //registerSDKWithAppKey:注册的appKey，详细见下面注释。
    //apnsCertName:推送证书名(不需要加后缀)，详细见下面注释。
//    [[EaseMob sharedInstance] registerSDKWithAppKey:@"5678#lschat" apnsCertName:nil];
    
    // 1.初始化SDK 并隐藏环信SDK的日志输出
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"5678#lschat" apnsCertName:nil otherConfig:@{kSDKConfigEnableConsoleLogger:@(NO)}];

    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // 2.监听自动登录的状态
    //设置chatManager代理
    //nil默认在主线程调用
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 3.如果登陆过，直接来到主界面
    if ([[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
        self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    }
    return YES;
}

#pragma  自动登录的回调
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        NSLog(@"自动登录成功: %@",loginInfo);
    } else {
        NSLog(@"自动登录失败: %@",error);
    }
}

//移除聊天管理器的代理
- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

@end
