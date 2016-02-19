//
//  LSAudioPlayTool.m
//  Chat
//
//  Created by skyharuhi on 16/2/9.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSAudioPlayTool.h"
#import "EMCDDeviceManager.h"

//正在执行动画的imageView
static UIImageView *animatingImageView;

@implementation LSAudioPlayTool

+(void)playWithMessage:(EMMessage *)message messageLabel:(UILabel *)messageLabel receiver:(BOOL)receiver
{
    //把以前的动画一出
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
    
    // 1.播放语音
    // 1.1 获取语音的路径（从消息体获取）
    EMVoiceMessageBody *voiceBody = message.messageBodies[0];
    
    // 本地语音文件路径
    NSString *path = voiceBody.localPath;
    
    // 如果本地语音文件不存在，使用服务器语音
    NSFileManager *manger = [NSFileManager defaultManager];
    if (![manger fileExistsAtPath:path]) {
        path = voiceBody.remotePath;
        
    }
    
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        NSLog(@"语音播放完毕 %@", error);
        
        // 语音播放结束后，停止动画，之后移除
        [animatingImageView stopAnimating];
        //[animatingImageView removeFromSuperview];
    }];
    
    // 2.添加动画
    // 2.1 创建一个UIImageView，添加到Label上
    UIImageView *imageView = [[UIImageView alloc]init];
    [messageLabel addSubview:imageView];
    
    // 2.2添加动画图片 -- 56:43
    if (receiver)
    {//接收方
        imageView.animationImages = @[
        [UIImage imageNamed:@"chat_receiver_audio_playing000"],
        [UIImage imageNamed:@"chat_receiver_audio_playing001"],
        [UIImage imageNamed:@"chat_receiver_audio_playing002"],
        [UIImage imageNamed:@"chat_receiver_audio_playing003"]];
        imageView.frame = CGRectMake(0, 0, 30, 30);

    }
    else
    {//发送方
        imageView.animationImages = @[
                                      
        [UIImage imageNamed:@"chat_sender_audio_playing_000"],
        [UIImage imageNamed:@"chat_sender_audio_playing_001"],
        [UIImage imageNamed:@"chat_sender_audio_playing_002"],
        [UIImage imageNamed:@"chat_sender_audio_playing_003"]];
        imageView.frame = CGRectMake(messageLabel.bounds.size.width - 30, 0, 30, 30);
    }
    
    //设置动画持续时间
    imageView.animationDuration = 1;
    [imageView startAnimating];
    animatingImageView = imageView;
    
    
}

#pragma mark - 停止播放语音
+(void)stop
{
    //停止播放语音
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    //移除动画
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
}

@end
