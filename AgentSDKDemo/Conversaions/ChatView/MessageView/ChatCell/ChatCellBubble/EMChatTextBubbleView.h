/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "EMChatBaseBubbleView.h"


#define TEXTLABEL_MAX_WIDTH 200 // textLaebl 最大宽度
#define LABEL_FONT_SIZE 16      // 文字大小
#define LABEL_LINESPACE 5       // 行间距

extern NSString *const kRouterEventTextURLTapEventName;


@interface EMChatTextBubbleView : EMChatBaseBubbleView

@property (nonatomic, strong) YYLabel *textLabel;
+ (CGFloat)lineSpacing;
+ (UIFont *)textLabelFont;
+ (NSLineBreakMode)textLabelLineBreakModel;
+ (CGSize)textSize:(HDMessage *)message;
+ (NSAttributedString *)getAttributedString:(HDMessage *)message;
@end
