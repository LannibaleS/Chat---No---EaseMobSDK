//
//  LoginViewController.m
//  Chat
//
//  Created by skyharuhi on 16/2/2.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LoginViewController.h"
#import "EaseMob.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UITextField *IDField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)registerAction:(id)sender {
}

- (IBAction)loginAction:(id)sender {

    //让环信的SDK在第一次登录完成之后，自动从服务器获取好友列表，添加到本地数据库
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];

    NSString *identity = self.IDField.text;
    NSString *password = self.passwordField.text;
    
    if (identity.length == 0 || password.length == 0) {
        NSLog(@"请输入用户名和密码");
        return;
    }
    
    //登陆
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:identity password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        //登陆请求完成后的block回调
        if (!error) {
            NSLog(@"登陆成功 loginInfo：%@", loginInfo);
            
            //设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            
            //来主界面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
        } else {
            NSLog(@"登录失败 error：%@", error);
            //user do not exist
            //每一个应用都有自己注册用户
        }
    } onQueue:dispatch_get_main_queue()];
}

@end
