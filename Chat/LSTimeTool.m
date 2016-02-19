//
//  LSTimeTool.m
//  Chat
//
//  Created by skyharuhi on 16/2/11.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import "LSTimeTool.h"

@implementation LSTimeTool

//时间戳 timeStamp:发送或接收消息的时间
+ (NSString *)timeString:(long long)timeStamp
{
    //返回时间格式
//    今天 -- 时：分 （HH：mm）
//    昨天 -- 昨天 + 时 +分  （昨天 HH：mm）
//    昨天以前（前天） -- 年：月：日 时 分 （2016 - 2 -9  10：41）
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 1.获取当前的时间
    NSDate *currentDate = [NSDate date];
    
    // 获取 - 当前时间的 - 年，获取月，获取日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    // 取出当前的年月日
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month ;
    NSInteger currentDay = components.day;

    //NSLog(@"currentYear %ld",components.year);
//    NSLog(@"currentMonth %ld",components.month);
//    NSLog(@"currentDay %ld",components.day);

    // 2.获取消息发送或者接收的时间
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
    // 获取 - 发送时间的 - 年，获取月，获取日
    NSDateComponents *Mcomponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:messageDate];
    //取出消息的年月日
    NSInteger messageYear = Mcomponents.year;
    NSInteger messageMonth = Mcomponents.month;
    NSInteger messageDay = Mcomponents.day;

    
//    NSLog(@"messageYear %ld",Mcomponents.year);
//    NSLog(@"messageMonth %ld",Mcomponents.month);
//    NSLog(@"messageDay %ld",Mcomponents.day);
   
    // 3.判断
    //格式化消息时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if (currentYear == messageYear
        && currentMonth == messageMonth
        && currentDay == messageDay) {
        //今天
        dateFormatter.dateFormat = @"HH:mm";
    } else if (currentYear == messageYear
               && currentMonth == messageMonth
               && currentDay - 1 == messageDay){
        //昨天
        dateFormatter.dateFormat = @"昨天 HH:mm";

    }else{
        //昨天以前
        dateFormatter.dateFormat = @"yyy-MM-dd HH:mm";
    }
    
    return [dateFormatter stringFromDate:messageDate];
}

@end
