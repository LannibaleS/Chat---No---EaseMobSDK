//
//  LSCommunicationCell.h
//  Chat
//
//  Created by skyharuhi on 16/2/5.
//  Copyright © 2016年 LannibaleS. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *ReceiverCell = @"ReceiverCell";
static NSString *SenderCell = @"SenderCell";

@interface LSCommunicationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

//消息模型，内部的setter方法 显示文字
@property (nonatomic, strong) EMMessage *message;


//返回cell的高度
-(CGFloat)cellHeight;

@end
