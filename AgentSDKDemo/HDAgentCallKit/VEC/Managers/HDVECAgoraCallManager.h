//
//  HDAgoraCallManager.h
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "HDVECAgoraCallOptions.h"
#import "HDVECAgoraCallManagerDelegate.h"
#import "HDVECTicketModel.h"
#import "HDVECRingingCallModel.h"

NS_ASSUME_NONNULL_BEGIN
static NSString * _Nonnull kVECUserDefaultState = @"KEFU_AGENT_KEY_BXL_DEFAULT_STATE"; // 接收屏幕共享(开始/结束 状态)监听的Key

static NSString * _Nonnull kVECAppGroup = @"group.com.easemob.kefuapp";
static void *VECKVOContext = &VECKVOContext;
@interface HDVECAgoraCallManager : NSObject
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (strong, nonatomic) AgoraScreenCaptureParameters2 * screenCaptureParams;
@property (nonatomic, weak) id <HDVECAgoraCallManagerDelegate> roomDelegate;
@property (nonatomic, strong) HDKeyCenter *keyCenter;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, strong) HDMessage * message;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSArray *recordDetails;
@property (nonatomic, strong) UserModel *chatter;

@property (nonatomic, assign) HDAgentServiceType currentAgentServiceType; // 当前坐席类型
@property (nonatomic, strong) HDVECRingingCallModel * ringingCallModel;

+ (instancetype _Nullable )shareInstance;

/// 解析振铃数据
/// @param dic  获取通行证接口返回的源数据
- (HDVECRingingCallModel *)vec_parseKefuRtcCallRingingData:(NSDictionary *)dic;

/// 解析获取的通行证接口的数据
/// @param dic  获取通行证接口返回的源数据
- (BOOL)vec_setAgoraTicketModel:(NSDictionary *)dic;

///获取坐席加入房间的数据
- (HDVECTicketModel *)vec_getAgentTicketCallOptions;

///获取访客加入房间的数据
- (HDVECTicketModel *)vec_getVisitorTicketCallOptions;

/// 获取屏幕分享加入房间的数据
- (HDVECTicketModel *)vec_getShareScreenTicketCallOptions;

/// 设置视频坐席状态
/// @param type  坐席类型
/// @param completion  设置状态结果回调
- (void)vec_SetVECAgentStatus:(HDAgentServiceType )type completion:(void (^_Nullable)(id responseObject, HDError * error))completion;

/// VEC-  获取坐席状态
/// @param completion  结果回调
- (void)vec_GetVECAgentStatusCompletion:(void (^_Nullable)(id responseObject, HDError * error))completion;

/// 初始化 声网 agora init
- (void)vec_createTicketDidReceiveAgoraInit;

/// 设置设置项
/// @param aOptions HDVECAgoraCallOptions
- (void)setCallOptions:(HDVECAgoraCallOptions *_Nullable)aOptions;

/// 获取通话状态  YES 通话中。NO 未通话
- (BOOL)getCallState;

/// 获取设置项
/// @result Setting options
- (HDVECAgoraCallOptions *_Nullable)getCallOptions;

/// 接受视频会话
/// @param nickname  传递自己的昵称到对方
/// @param completion 完成回调
- (void)vec_acceptCallWithNickname:(NSString *)nickname completion:(void (^_Nullable)(id, HDError *))completion;

/// 获取已经加入的members
///@result 已经加入的成员
- (NSArray *_Nullable)hasJoinedMembers;

/// 切换摄像头
- (void)switchCamera;

/// 暂停语音数据传输
- (void)pauseVoice;

/// 恢复语音数据传输
- (void)resumeVoice;

/// 暂停视频图像数据传输
- (void)pauseVideo;

/// 开启/关闭视频模块
/// @param enabled  yes 开启 no 关闭
- (void)enableLocalVideo:(BOOL )enabled;

/// 恢复视频图像数据传输
- (void)resumeVideo;

/// 开启/关闭扬声器播放。
/// @param enableSpeaker  yes 打开 no 关闭
- (void)setEnableSpeakerphone:(BOOL)enableSpeaker;

/// 开启/关闭 虚拟背景。
/// @param enable yes 开启 no 关闭
- (void)setEnableVirtualBackground:(BOOL)enable;

/// 结束视频会话。
- (void)vec_endCall;

/// 销毁对象
/// 一个 App ID 只能用于创建一个 AgoraRtcEngineKit。如需更换 App ID，必须先调用 destroy 销毁当前 AgoraRtcEngineKit，并在 destroy 成功返回后，再调用 sharedEngineWithAppId 重新创建 AgoraRtcEngineKit。
- (void)destroy;

/// 初始化本地视图。
/// @param localView 设置本地视频显示属性。
- (void)setupLocalVideoView:(UIView *)localView;

/// 初始化远端视图。
/// @param remoteView  远端试图
/// @param uid  远端的uid
- (void)setupRemoteVideoView:(UIView *)remoteView withRemoteUid:(NSInteger )uid;
- (void)initSettingWithCompletion:(void(^)(id  responseObject, HDError *error))aCompletion ;

/// 保存屏幕共享需要的数据
- (void)hd_saveShareDeskData:(HDKeyCenter*)keyCenter;

/// 获取会话全部视频通话详情
- (void)getAllVideoDetailsSession:(NSString *)sessionId completion:(void(^)(id responseObject,HDError *error))aCompletion;

/// 构造给访客端加入房间的参数
- (NSDictionary *)vec_getSendVisitorTicketWithVisitorNickname:(NSString *)nickName withVisitorTrueName:(NSString *)trueName;

//发送 cmd 消息 把访客端需要加入房间的数据带过去
- (void)vec_sendCmdMessage:(NSDictionary *)msgtypeDic withSessionId:(NSString *)sessionId withToUser:(NSString *)toUser completion:(void (^)(HDMessage * _Nonnull, HDError * _Nonnull))aCompletionBlock;

/// 获取对端访客视频截图
- (void)vec_getVisitorScreenshotCompletion:(void(^)(NSString * url,HDError *error))aCompletion;

/// json 转字典
/// @param jsonString
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/// 组装视频记录 所需要的body体数据
- (NSDictionary *)vec_getSessionhistoryParameteData;
/**
   获取视频记录
 Integer pageNum 页码(默认0)
 Integer pageSize 页大小（默认10）
 Integer tenantId 租户ID
 String agentUserId 客服ID
 String visitorUserId 访客ID
 Date createDateFrom 通话创建时间（开始范围条件）
 Date createDateTo 通话创建时间（结束范围条件）
 Date startDateFrom 首次通话接起时间（开始范围条件）
 Date startDateTo 首次通话接起时间（结束范围条件）
 Date stopDateFrom 结束时间（开始范围条件）
 Date stopDateTo 通话结束时间（结束范围条件）
 List<TechChannel> techChannels 关联（TechChannel对象参数，String techChannelType 关联类型，String techChannelId 关联ID）
 List<String> originType 渠道类型
 boolean isAgent 是否使用客服角色进行查询（坐席/管理员）
 String sortField  排序字段（默认createDatetime）
 String sortOrder 正序倒序标识（默认desc）
 String rtcSessionId 视频ID，如果指定了这个，别的条件就不生效了
 List<Integer> queueIds 技能组Ids
 List<String> hangUpReason 挂断类型
 List<String> hangUpUserType 挂断方
 String customerName 客户名
 String visitorName 访客名
 List<String> state 通话状态（结束为"Terminal","Abort"）
 @param data   请求参数体  是一个json串 里边设置筛选条件参数 参数请参考以上字段
 */
- (void)vec_getRtcSessionhistoryParameteData:(NSDictionary*)data
                       completion:(void (^)(id responseObject, HDError *error))completion;


/*
 * 获取视频详情
 */

- (void)vec_getCallVideoDetailWithRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion;

//待接入 相关接口
/*
 * 待接入数量 这个接口需要需要轮训获取排队数量
 */

- (void)vec_getSessionsCallWaitWithAgentId:(NSString *)agentId Completion:(void(^)(id responseObject, HDError *error))completion;


/// 组装待接入列表 所需要的body体数据
- (NSDictionary *)vec_getSessionCallWaitListParameteData;

/*
 * 待接入列表 这个接口需要需要轮训获取排队列表
 {
   "page": 0,
   "size": 20,
   "mode": "agent", //  如果要获取管理员下所有的列表 传admin
   "beginDate": "2022-05-05T00:00:00",
   "endDate": "2022-05-06T00:00:00",
   "techChannelId": 27230,
   "originType": "app",
   "visitorUserId": "id"
 }'
 */
- (void)vec_postSessionsCallWaitListParameteData:(NSDictionary*)data Completion:(void(^)(id responseObject, HDError *error))completion;

/*
 * 待接入 获取接听 音视频ticket 通行证
 */
- (void)vec_getSessionsCallWaitTicketWithAgentId:(NSString *)agentId withRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion;

/*
 * 拒接待接入通话
 */
- (void)vec_postSessionsCallWaitRejectWithAgentId:(NSString *)agentId withRtcSessionId:(NSString *)rtcSessionId Completion:(void(^)(id responseObject, HDError *error))completion;

/*
 *  坐席未接通时 访客点击拒绝 关掉 接通界面 数据解析 返回是不是 取消通知 其他收到的消息过滤掉
 */
- (BOOL)vec_isVisitorCancelInvitationMessage:(NSDictionary *)dic;

/// 开启屏幕共享
- (void)vec_startScreenCapture;

/// 关闭屏幕共享
- (void)vec_stopScreenCapture;

@end

NS_ASSUME_NONNULL_END
