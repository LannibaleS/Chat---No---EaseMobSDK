//
//  LSMyselfTableViewController.m
//  Chat
//
//  Created by skyharuhi on 16/2/5.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSMyselfTableViewController.h"
#import "EaseMob.h"

@interface LSMyselfTableViewController ()
- (IBAction)logoutAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end

@implementation LSMyselfTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前登录的用户名
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    
    NSString *logoutTitile = [NSString stringWithFormat:@"退出(%@)",loginUsername];
    // 1.设置退出按钮的文字
    [self.logoutBtn setTitle:logoutTitile forState:UIControlStateNormal];
}

- (IBAction)logoutAction:(id)sender
{
    //UnbindDeviceToken 不绑定DeviceToken
    //DeviceToken 推送
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            NSLog(@"退出失败 %@", error);
        } else {
            NSLog(@"退出成功");
            //回到登陆界面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
        }
    } onQueue:nil];
}
@end
