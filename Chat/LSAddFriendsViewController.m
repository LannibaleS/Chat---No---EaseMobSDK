//
//  LSAddFriendsViewController.m
//  Chat
//
//  Created by skyharuhi on 16/2/2.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSAddFriendsViewController.h"
#import "EaseMob.h"

@interface LSAddFriendsViewController () <EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addFriendTextField;

@end

@implementation LSAddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#warning 代理放在conversation比较好
    //添加聊天管理器的代理
   // [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (IBAction)addFriendAction:(id)sender {
    //添加好友
    // 1.获取要添加好友的名字
    NSString *username = self.addFriendTextField.text;
    
    // 2.向服务器发送添加好友的请求
    // message：请求添加好友的 额外的信息
    // 获取当前用户的用户名 loginInfo
    NSString *loginIdentity = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *message = [@"我是" stringByAppendingString:loginIdentity];
    
    EMError *error = nil;
    [[EaseMob sharedInstance].chatManager addBuddy:username message:message error:&error];
    
    if (error) {
        NSLog(@"添加好友有问题 :%@", error);
    } else {
        NSLog(@"添加好友成功");
    }
}


////移除聊天管理器的代理
//- (void)dealloc
//{
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//}
@end
