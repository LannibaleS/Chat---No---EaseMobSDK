//
//  LSAddressBookTableViewController.m
//  Chat
//
//  Created by skyharuhi on 16/2/2.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSAddressBookTableViewController.h"
#import "EaseMob.h"
#import "CommunicatonViewController.h"

@interface LSAddressBookTableViewController () <EMChatManagerDelegate>

//好友列表数据源
@property (nonatomic, strong) NSArray *buddyList;

@end

@implementation LSAddressBookTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    /*
     获取好友列表注意
     1。好友列表buddyList需要在自动登录成功后才有值
     2。buddyList的数据，是从本地数据库获取的
     3。如果要从服务器获取好友列表
     - (void *)asyncFetchBuddyListWithCompletion:(void (^)(NSArray *buddyList, EMError *error))completion
                                         onQueue:(dispatch_queue_t)queue;
     4。如果当前有添加好友的请求，环信的SDK内部回望数据库的buddyList添加好友记录
     5。如果程序删除，或者用户第一次登陆，buddyList表是没有记录的，要从服务器获取好友列表
     //让环信的SDK在第一次登录完成之后，自动从服务器获取好友列表，添加到本地数据库
     [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
     */
    //获取好友列表
    
#warning 好友列表buddyList需要在自动登录成功后才有值
    self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    //NSLog(@"buddyList：%@", self.buddyList);
    
#warning 强调：buddyList没有值得两种情况：1.第一次登陆 2.自动登录还没有完成
//    if (self.buddyList == 0) {
//        
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"BuddyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 1.获取h好友模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    
    // 2.显示头像和名称
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    
    // 3.显示名称
    cell.textLabel.text = buddy.username;
    
    return cell;
}

#pragma mark - chatManager的代理
#pragma mark - 监听自动登录成功
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        //登陆成功，此时buddyList有值
        NSLog(@"自动登录成功");
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"buddy：%@", self.buddyList);

        //刷新列表
        [self.tableView reloadData];
    } else {
        NSLog(@"自动登录失败");
    }
}

#pragma mark - 好友添加请求同意监听 
//没有用
- (void)didAcceptedByBuddy:(NSString *)username
{
    //把新的好友显示到表格
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    
    NSLog(@"好友添加请求同意 %@",buddyList);
#warning buddylist的个数，仍然是没有添加好友之前的个数，从服务器获取最新数据
    
    //调用
    [self loadBuddyListFromServer];
}

#pragma mark - 从服务器获取好友列表
- (void)loadBuddyListFromServer
{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        NSLog(@"从服务器获取好友列表: %@", buddyList);
        
        //赋值数据源
        self.buddyList = buddyList;
        
        //刷新
        [self.tableView reloadData];
        
    } onQueue:nil];
}

#pragma mark - 更新好友列表数据
//坑的，也没用
- (void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd
{
    NSLog(@"更新好友列表数据: %@", buddyList);
    
    //重新赋值数据源
    self.buddyList = buddyList;
    //刷新
    [self.tableView reloadData];
}

#pragma mark - 监听被好友删除
- (void)didRemovedByBuddy:(NSString *)username
{
    //刷新表格
    [self loadBuddyListFromServer];
}

#pragma mark - 删除好友代理 出现表格的delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取移除好友的名字,获取好友模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    NSString *deleteUsername = buddy.username;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除好友
        //removeFromRemote 是否将自己从对方的好友列表中删除
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:NULL];
    }
}

#pragma mark - 获取选中行的buddy属性
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //往聊天界面 传递一个 buddy的值
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[CommunicatonViewController class]]) {
        
        //获取点中的行
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        
        CommunicatonViewController *chatVC = destVC;
        chatVC.buddy = self.buddyList[selectedRow];
    }
}

@end
