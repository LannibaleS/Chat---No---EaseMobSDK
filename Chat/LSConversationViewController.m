//
//  LSConversationViewController.m
//  Chat
//
//  Created by skyharuhi on 16/2/2.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSConversationViewController.h"
#import "EaseMob.h"
#import "CommunicatonViewController.h"

@interface LSConversationViewController () <EMChatManagerDelegate,UIAlertViewDelegate>

//好友的名称
@property (nonatomic, copy) NSString *buddyUsername;

//历史会话消息
@property (nonatomic, strong) NSArray *conversations;

@end

@implementation LSConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //[[EaseMob sharedInstance].chatManager addDelegate:<#(id<EMChatManagerDelegate>)#> delegateQueue:<#(dispatch_queue_t)#>];
    
    //获取历史会话记录
    [self loadConversations];
    
    
    // 2.监听自动连接的状态
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark - 获取历史会话消息
- (void)loadConversations
{
    //获取历史会话记录
    // 1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    // 2.如果内存里没有会话记录，从数据库里获取（conversation表）
    if (conversations.count == 0) {
        //从数据库加载
        conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    NSLog(@"xxxx %@",conversations);
    self.conversations = conversations;
    
    //显示总的未读数
    [self showTabBarBadge];

}


#pragma mark - chatManager的代理方法
// 1.监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开，未连接。。。");
        self.title = @"未连接";
    } else {
        NSLog(@"网络已连接~~~");
    }
}

- (void)willAutoReconnect
{
    NSLog(@"将自动重新连接");
    self.title = @"正在连接中";
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    if (!error) {
        NSLog(@"自动重新连接成功");
        self.title = @"聊天";
    }else{
        NSLog(@"自动重新连接失败。。%@", error );
    }
}

#pragma mark - 好友添加的代理方法
//好友请求被同意
- (void)didAcceptedByBuddy:(NSString *)username
{
    NSString *message = [NSString stringWithFormat:@"%@ 同意了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加信息" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加信息" message:message preferredStyle:UIAlertControllerStyleAlert];
    //
    //    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    //
    //    [alert addAction:defaultAction];
    //    [self presentViewController:alert animated:YES completion:nil];
    
}

//被拒绝
- (void)didRejectedByBuddy:(NSString *)username
{
    NSString *message = [NSString stringWithFormat:@"%@ 拒绝了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加信息" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 接收好友的请求
- (void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message
{
    //赋值
    self.buddyUsername = username;

    //对话框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加请求" message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alert show];
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加请求" message:message preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    
//    [alert addAction:action];
//    
//    [self presentViewController:alert animated:YES completion:nil];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //拒绝好友请求
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.buddyUsername reason:@"我不认识你" error:NULL];
    }else{
        //同意好友请求
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.buddyUsername error:NULL];
    }
}

#pragma mark - 监听被好友删除
- (void)didRemovedByBuddy:(NSString *)username
{
    NSString *message = [username stringByAppendingString:@" 把你删除了"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"xxxx" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

//移除聊天管理器的代理
- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"大哥求你了！！！！！！！！！！！！！！");
    static NSString *ID = @"ConversationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    
        }
    //获取会话模型
    EMConversation *conversation = self.conversations[indexPath.row];
    
    //显示数据
    //头像
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    // 1.显示用户名
    cell.textLabel.text = [NSString stringWithFormat:@"%@ === 未读的消息数:%ld",conversation.chatter, [conversation unreadMessagesCount]];
    
    // 2.显示最新的一条记录
    // 获取消息体
    id body = conversation.latestMessage.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        cell.detailTextLabel.text = textBody.text;

    } else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        EMVoiceMessageBody *voiceBody = body;
        cell.detailTextLabel.text = voiceBody.displayName;
        
    } else if ([body isKindOfClass:[EMImageMessageBody class]]){
        EMImageMessageBody *imageBody = body;
        cell.detailTextLabel.text = imageBody.displayName;
    } else{
        cell.detailTextLabel.text = @"未知的消息类型";
    }

    return cell;
}

#pragma mark - 历史会话列表更新
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    //给数据源重新复制
    self.conversations = conversationList;
    
    // 刷新表格
    [self.tableView reloadData];
    
    //显示总的未读数
    [self showTabBarBadge];

}

#pragma mark - 未读消息数改变
- (void)didUnreadMessagesCountChanged
{
    //更新表格
    [self.tableView reloadData];
    
    //显示总的未读数
    [self showTabBarBadge];
}

#pragma mark - 在tabbar显示未读消息总和	;
- (void)showTabBarBadge
{
    //便利所有的会话记录，将未读消息数进行累加
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversatiuons in self.conversations) {
        totalUnreadCount += [conversatiuons unreadMessagesCount];
    }
    
    if (totalUnreadCount == 0) {
        self.navigationController.tabBarItem.badgeValue = nil;
    }else{
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",totalUnreadCount];

    }
}

#pragma mark - 选中tableViewCell，跳转到CommunicationViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 进入到聊天控制器
    // 1.从storuboard加载聊天控制器
    CommunicatonViewController *communicationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommunicationPage"];
    
    //会话
    EMConversation *conversation = self.conversations[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    
    // 2.设置好友属性
    communicationVC.buddy = buddy;
    
    // 3.展现聊天界面
    [self.navigationController pushViewController:communicationVC animated:YES];

}

@end
