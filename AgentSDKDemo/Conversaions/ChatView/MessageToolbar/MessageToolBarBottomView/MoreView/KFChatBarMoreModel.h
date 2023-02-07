//
//  KFChatBarMoreModel.h
//  AgentSDKDemo
//
//  Created by easemob on 2022/11/15.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    KFChatMoreBtnVideoCall, //视频通话
    KFChatMoreBtnCustomMessage, //自定义消息
    KFChatMoreBtnIframeBase, //iframe base
    KFChatMoreBtnIframeRobot, // robot iframe
}KFChatMoreBtnType;
NS_ASSUME_NONNULL_BEGIN

@interface KFChatBarMoreModel : NSObject
@property (nonatomic, copy) NSString *btnName;
@property (nonatomic, copy) UIButton *btn;
@property (nonatomic, assign) KFChatMoreBtnType btnType;
@end

NS_ASSUME_NONNULL_END