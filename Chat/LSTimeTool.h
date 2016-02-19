//
//  LSTimeTool.h
//  Chat
//
//  Created by skyharuhi on 16/2/11.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSTimeTool : NSObject

//时间戳 timeStamp:发送或接收消息的时间
+ (NSString *)timeString:(long long)timeStamp;

@end
