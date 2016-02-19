//
//  LSCommunicationCell.m
//  Chat
//
//  Created by skyharuhi on 16/2/5.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSCommunicationCell.h"
#import "EMCDDeviceManager.h"
#import "LSAudioPlayTool.h"
#import "UIImageView+WebCache.h"

@interface LSCommunicationCell()

//聊天图片，懒加载必须用strong属性
@property (nonatomic, strong) UIImageView *chatImageView;

@end

@implementation LSCommunicationCell

-(UIImageView *)chatImageView
{
    if (!_chatImageView) {
        _chatImageView = [[UIImageView alloc]init];
    }
    return _chatImageView;
}

#pragma mark - 做些初始化
- (void)awakeFromNib
{
    //在此方法做一些初始化操作
    // 1.给label添加敲击收拾
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];
}

#pragma mark - messageLabel点击的触动方法
- (void) messageLabelTap:(UITapGestureRecognizer *)recognizer
{
    //NSLog(@"%s",__func__);
    
    // 播放语音
    // 只有当前的类型是语音类型时才播放
    // 1.获取消息体
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        NSLog(@"播放语音");
    
        // 2.播放语音
        BOOL receiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
        [LSAudioPlayTool playWithMessage:self.message messageLabel:self.messageLabel receiver:receiver];
    }
}

#pragma mark - 重写Message的setter方法
- (void)setMessage:(EMMessage *)message
{
    //cell重用时，把聊天图片控件移除，不会占用label的空间
    [self.chatImageView removeFromSuperview];
    
    _message = message;
    
    // 1.获取消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        //如果消息类型是文本消息
        EMTextMessageBody *textbody = body;
        self.messageLabel.text = textbody.text;
        
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        //self.messageLabel.text = @"语音类型";
        self.messageLabel.attributedText = [self voiceAtt];
        
    }else if ([body isKindOfClass:[EMImageMessageBody class]]){
        //图片消息类型
        [self showImage];
        
    }else{
        self.messageLabel.text = @"未知类型";

    }
}

#pragma mark - 发送后，显示图片
- (void)showImage
{
    // 2.1 获取图片的消息体
    EMImageMessageBody *imageBody = self.message.messageBodies[0];
    CGRect *thumbnailFrame = &((CGRect){0,0,imageBody.thumbnailSize});
    
    // 设置Label的尺寸足够现实UIImageView
    // 添加一个富文本，目的是占位
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.bounds = *(thumbnailFrame);
    
    NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    self.messageLabel.attributedText = imageAtt;
    
    //用富文本也可以显示图片，但是麻烦
    //用SDWebImage
    // 1.cell里面添加一个UIImageView
    [self.messageLabel addSubview:self.chatImageView];
    self.chatImageView.backgroundColor = [UIColor redColor];
    
    // 2.设置图片控件为缩略图的尺寸(从图片的消息体获取)
    
    self.chatImageView.frame = *(thumbnailFrame);
    
    //label的高度和宽度不足以显示图片
    
    // 3.下载图片
    // 如果本地图片存在，直接显示；不存在，从网络加载图片
    NSFileManager *manger = [NSFileManager defaultManager];
    UIImage *placeHolderImage = [UIImage imageNamed:@"chatBar_colorMore_camera"];
    if ([manger fileExistsAtPath:imageBody.thumbnailLocalPath]) {
#warning 本地路径使用fileURLWithPath方法
        [self.chatImageView sd_setImageWithURL:[NSURL fileURLWithPath:imageBody.thumbnailLocalPath] placeholderImage:placeHolderImage];
    } else {
        //本地图片不存在，从网络加载图片
        //服务器使用URLWithString方法
        [self.chatImageView sd_setImageWithURL:[NSURL URLWithString:imageBody.thumbnailRemotePath] placeholderImage:placeHolderImage];
    }
}

#pragma mark - 返回语音的富文本
- (NSAttributedString *)voiceAtt
{
    //创建一个可变的富文本
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc]init];
    // 1. 接收方的富文本 = 图片 + 时间
    if ([self.reuseIdentifier isEqualToString:ReceiverCell]) {
        //  1.1 接收方的语音图片
        UIImage *receiverImage = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        
        // 1.2 创建图片附件
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc]init];
        
        imageAttachment.image = receiverImage;
        
        imageAttachment.bounds = CGRectMake(0, -8, 30, 30);
        // 1.3 图片富文本
        NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        // 1.4 拼接
        [voiceAttM appendAttributedString:imageAtt];
        
        // 1.5 创建时间的富文本
        // 获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeString = [NSString stringWithFormat:@"%ld'",(long)duration];
        
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeString];
        
        [voiceAttM appendAttributedString:timeAtt];
        
        
    }else{
        // 2. 发送方的富文本 = 事件 + 图片
        // 2.1 创建时间的富文本
        // 获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeString = [NSString stringWithFormat:@"%ld'",(long)duration];
        
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeString];
        
        [voiceAttM appendAttributedString:timeAtt];
        
        // 2.1 接收方的语音图片
        UIImage *receiverImage = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        
        // 2.3 创建图片附件
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc]init];
        
        imageAttachment.image = receiverImage;
        
        imageAttachment.bounds = CGRectMake(0, -8, 30, 30);
        // 2.4 图片富文本
        NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        
        // 2.5 拼接
        [voiceAttM appendAttributedString:imageAtt];
    }
    
    //返回是不可变的，但是拼接的时候必须是可变的
    return [voiceAttM copy];
}

//返回cell的高度
-(CGFloat)cellHeight
{
    //重新布局子控件
    [self layoutIfNeeded];
    
    NSLog(@"返回cell高度执行了");
    NSLog(@"%s", __func__);
    return  5 + 10 + self.messageLabel.bounds.size.height + 5 + 10;
    
}

@end
