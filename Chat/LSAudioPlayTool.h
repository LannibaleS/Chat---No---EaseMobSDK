//
//  LSAudioPlayTool.h
//  Chat
//
//  Created by skyharuhi on 16/2/9.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSAudioPlayTool : NSObject

//类方法
+ (void)playWithMessage:(EMMessage *)message messageLabel:(UILabel *)messageLabel receiver:(BOOL)receiver;

//停止播放语音
+ (void)stop;

@end
