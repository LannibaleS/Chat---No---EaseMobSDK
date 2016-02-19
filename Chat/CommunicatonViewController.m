//
//  CommunicatonViewController.m
//  Chat
//
//  Created by skyharuhi on 16/2/5.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//   05. 显示时间的cell - 15：18

#import "CommunicatonViewController.h"
#import "LSCommunicationCell.h"
#import "EMCDDeviceManager.h"
#import "LSAudioPlayTool.h"
#import "LSTimeCell.h"
#import "LSTimeTool.h"


@interface CommunicatonViewController () <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIScrollViewDelegate,EMChatManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//输入工具条底部的约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolbarBottomConstraint;

//数据源
@property (nonatomic, strong) NSMutableArray *dataSources;

//聊天界面的tableView
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

//计算高度的cell的工具对象
//@property (nonatomic, strong) LSCommunicationCell *comunicationCellTool;
@property (nonatomic, strong) LSCommunicationCell *chatCellTool;


//inputToolBar高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarHeightConstraint;

//录音按钮
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

//文本输入框
@property (weak, nonatomic) IBOutlet UITextView *textView;

//当前添加的时间
@property (nonatomic, copy) NSString *currentTimeString ;

//当前的会话对象
@property (nonatomic, strong) EMConversation *conversation;


@end

@implementation CommunicatonViewController

- (NSMutableArray *)dataSources
{
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景颜色
    self.chatTableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    //初始化数据
    //[self.dataSources addObject:@"lkfasfoaj"];
        
    //给计算高度的cell工具对象赋值
    self.chatCellTool= [self.chatTableView dequeueReusableCellWithIdentifier:ReceiverCell];
    //用receiver和sender都可以
    
    //显示好友的名字
    self.title = self.buddy.username;
    
    //加载本地数据库的聊天记录（messageV1）
    [self loadLocalChatRecords];
    
    //设置聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 1.监听键盘的弹出，把inputToobar往上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 2.监听键盘的退出，把inputToobar恢复原位
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - 获取本地聊天记录
- (void)loadLocalChatRecords
{
    //假设在数组的第一位置添加时间
    //[self.dataSources addObject:@"11:02"];
    
    // 要获取本地聊天记录，使用会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    self.conversation = conversation;
    // 加载与当前聊天对象，所有的聊天记录
    NSArray *messages = [conversation loadAllMessages];
    //NSLog(@"%@",messages);
    
    //遍历
//    for (id object in messages) {
//        NSLog(@"%@",[object class]);
//    }
    
    //添加到数据库
    //[self.dataSources addObjectsFromArray:messages];
    //遍历
    for (EMMessage *messageObject in messages) {
        [self addDataSourcesWithMessage:messageObject];
    }
}

#pragma MARK - 键盘显示时会触发的方法
- (void)kbWillShow:(NSNotification *)noti
{
    // 1.获取键盘的高度
    // 1.1获取键盘结束时的位置
    CGRect kbEndFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
    CGFloat kbHeight = kbEndFrame.size.height;
    
    // 2.更改inputToobar底部的约束
    self.inputToolbarBottomConstraint.constant = kbHeight;
    
    //添加动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 键盘隐藏时触发的方法
- (void)kbWillHide:(NSNotification *)noti
{
    //inputToobar恢复原位
    self.inputToolbarBottomConstraint.constant = 0;
}

#pragma mark - 销毁通知中心
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSources.count;
}

//cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果是时间的cell，返回高度为18
    if ([self.dataSources[indexPath.row] isKindOfClass:[NSString class]]) {
        return 18;
    }
    
    //设置label的数据
    // 1.获取消息模型
    EMMessage *msg = self.dataSources[indexPath.row];
    
    self.chatCellTool.message = msg;

#warning 计算高度之前，一定要给messageLabel.text赋值
    //self.chatCellTool.messageLabel.text = self.dataSources[indexPath.row];
    NSLog(@"%s", __func__);
    NSLog(@"heightforrow调用了");
    return [self.chatCellTool cellHeight];
    
}

#pragma MARK - CELL的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *ReceiverCell = @"ReceiverCell";
//    static NSString *SenderCell = @"SenderCell";
    
    // 判断数据源的类型
    if ([self.dataSources[indexPath.row] isKindOfClass:[NSString class]]) {
        //显示时间的cell
        LSTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell"];
        timeCell.timeLabel.text = self.dataSources[indexPath.row];
        return timeCell;
        
    }
    
    // 1.先获取消息模型
    EMMessage *message = self.dataSources[indexPath.row];
    //EMMessage
    //from:lannibales to:cj 发送方（自己）
    //from:cj to:lannibales 接收方（好友）
    
    LSCommunicationCell *cell = nil;
    if (!cell) {
        if ([message.from isEqualToString:self.buddy.username]) {
            //接收方
            cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
        }else{
            //发送方
            cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
        }
    }
    //显示内容
    cell.message = message;
    [self scrollToBottom];
    
    return cell;
}

#pragma mark - UITextView的代理
- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"contentOffset %@", NSStringFromCGPoint(textView.contentOffset));
    
    NSLog(@"%@",NSStringFromCGSize(textView.contentSize));
    // 1.计算TextView的高度，调整整个输入框的高度
    CGFloat textViewH = 0;
    CGFloat minHeight = 33; //textView的最小高度
    CGFloat maxHeight = 68; //textView的最大高度
    
    // 获取contentSize的高度
    CGFloat contentHeight = textView.contentSize.height;
    if (contentHeight < minHeight) {
        textViewH = minHeight;
    } else if (contentHeight > maxHeight){
        textViewH = maxHeight;
    }else{
        textViewH = contentHeight;
    }
    
    // 2.监听send事件 -- 判断最后的一个字符是不是换行字符
    //如果是换行字符，就是发送
    if ([textView.text hasSuffix:@"\n"]) {
        //NSLog(@"发送操作");
        
        [self sendText:textView.text];
        
        //清空textView里面的文字
        textView.text = nil;
        
        // 发送时，textView的高度为33（最小高度）
        textViewH = minHeight;
    }
    
    // 3.调整整个inputToolBar的高度
    self.inputToolBarHeightConstraint.constant = 6 + 6 + textViewH;
    
    //加个动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // 4.让光标回到原位置 contentOffset回到（0，0）
#warning 技巧
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange];
    
}

#pragma mark - 发送文字消息 把最后一个换行字符去掉
- (void)sendText:(NSString *)text
{
    // 把最后一个换行字符去掉
    //换行字符 只占用一个长度
    text = [text substringToIndex:text.length - 1];
    
    //http 消息 = 消息头 + 消息体
#warning 每一种消息类型对应一种消息体
    //EMTextMessageBody 文本消息体
    //EMVoiceMessageBody 录音消息体
    //EMLocationMessageBody 位置消息体
    //EMVideoMessageBody 视频消息体
    //EMImageMessageBody 图片消息体
    
    NSLog(@"要发送给谁 %@",self.buddy.username);
    //return;
    
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    // 创建一个文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc]initWithChatObject:chatText];

    [self sendMessage:textBody];
}


#pragma mark - 发送语音文件
- (void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration
{
    // 1.构造一个 语音消息体
    //displayName:代表显示消息的类型（语音、文字、视频什么的）
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
    // chatVoice.duration = duration;
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    [self sendMessage:voiceBody];
}

#pragma mark - 发送图片
- (void)sendImage:(UIImage *)selectedImage
{
    // 1.构造一个 图片消息体
    /*
     (EMChatImage *) 第一个参数：原始大小的图片对象 1000 * 1000
     thumbnailImage:<#(EMChatImage *)#> 第二个参数：缩略图的图片对象 100* 100
     自己不设置缩略图的大小，环信有自己的算法,也可以自己设置
    */
    EMChatImage *originalChatImage = [[EMChatImage alloc] initWithUIImage:selectedImage displayName:@"[图片]"];
    
    EMImageMessageBody *imageBody = [[EMImageMessageBody alloc] initWithImage:originalChatImage thumbnailImage:nil];
    
    [self sendMessage:imageBody];
    
}

#pragma mark - 发送消息方法抽取
- (void)sendMessage:(id<IEMMessageBody>)body
{
    // 2.构造一个消息对象
    EMMessage *messageObject = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    // 单聊
    //消息的类型
    //    @constant eMessageTypeChat            单聊消息
    //    @constant eMessageTypeGroupChat       群聊消息
    //    @constant eMessageTypeChatRoom        聊天室消息
    messageObject.messageType = eMessageTypeChat;
    
    // 3.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:messageObject progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送图片");
        
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            NSLog(@"图片发送成功");
        }else{
            NSLog(@"图片发送失败 %@", error);
        }
    } onQueue:nil];
    
    // 4.把消息添加到数据源，然后再刷新表格
    [self addDataSourcesWithMessage:messageObject];
    [self.chatTableView reloadData];
    
    // 5.把最新消息滚动显示在顶部
    [self scrollToBottom];
}

#pragma mark - 界面滚动，显示最新消息
- (void)scrollToBottom
{
    if (self.dataSources.count == 0) {
        return;
    }
    
    // 1.获取最后一行
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSources.count - 1 inSection:0];
    
    // 2.滚动到某一行
    [self.chatTableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - 接受好友的回复消息
- (void)didReceiveMessage:(EMMessage *)message
{
    // 判断到底是谁发的
    // from一定要等于当前的聊天用户
    // cj - lannibales
    if ([message.from isEqualToString:self.buddy.username]) {
        // 1.把接收的消息添加到数据源
        //[self.dataSources addObject:message];
        [self addDataSourcesWithMessage:message];
        
        // 2.刷新表格
        [self.chatTableView reloadData];
        
        // 3.显示数据到底部
        [self scrollToBottom];
    }
    
}

#pragma mark - 录音按钮的action
- (IBAction)voiceAction:(UIButton *)sender
{
    // 1.显示录音按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    //textView hidden取反
    self.textView.hidden = !self.textView.hidden;
    
    // 2.让输入框大小还原
    if (self.recordBtn.hidden == NO) {// 录音按钮显示
        // 2.1 inputToolBar的高度要回到默认高度 46
        self.inputToolBarHeightConstraint.constant = 46;
        
        // 2.2 隐藏键盘
        [self.view endEditing:YES];
    }else{
        // 当不录音的时候，键盘要显示
        [self.textView becomeFirstResponder];
        
        //调用textViewDidBeginEditing
        // 回复InputToolBar的高度
        [self textViewDidChange:self.textView];
        
    }
}

#pragma mark - 按钮点下去就开始录音
- (IBAction)beginRecordAction:(id)sender
{
    NSLog(@"按钮点下去，开始录音");
    
    // 文件名以时间命名 定义fileName
    // 随机数
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    // 拿到时间戳，在拼接一个随机数
    NSString *fileName = [NSString stringWithFormat:@"%d%d", (int)time, x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音成功");
        }
    }];
}

#pragma mark - 松开按钮 停止录音
- (IBAction)endRecordAction:(id)sender
{
    NSLog(@"按钮松开，结束录音");
    
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"录音成功");
            //NSLog(@"%@", recordPath);
            //NSLog(@"%ld",(long)aDuration);
            
            //发送语音给服务器
            [self sendVoice:recordPath duration:aDuration];
        }
    }];
}

#pragma mark - 手指在按钮外面松开，结束录音
- (IBAction)cancelRecordAction:(id)sender
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    
}


#pragma mark - 发送图片
- (IBAction)showImagePickerAction:(id)sender
{
    // 显示图片选择的控制器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // 设置源
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
    
    
}

// 用户选中图片的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 1.获取用户选中的图片
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    // 2.发送图片
    [self sendImage:selectedImage];
    
    // 3.隐藏当前的图片选择控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark - scrollView将要开始滚动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //停止播放语音
    [LSAudioPlayTool stop];
}

#pragma mark - 添加数据源
- (void)addDataSourcesWithMessage:(EMMessage *)message
{
    // 1.判断EMMessage对象前面是否要加“时间”  timeStamp:发送或接收消息的时间
    NSString *timeString = [LSTimeTool timeString:message.timestamp];
    
    //如果当前时间不等于消息时间，就要添加当前时间
    if (![self.currentTimeString isEqualToString:timeString]) {
        [self.dataSources addObject:timeString];
        self.currentTimeString = timeString;
    }
    
    // 2.再加EMMeaasge
    [self.dataSources addObject:message];
    
    // 3.设置消息为已读
    [self.conversation markMessageWithId:message.messageId asRead:YES];
}

@end
