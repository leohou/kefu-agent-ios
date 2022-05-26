//
//  AdminInforViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/1/20.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "AdminInforViewController.h"
#import "AppDelegate.h"
#import "CompileTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "AdminInforEditViewController.h"
#import "LMJDropdownMenu.h"
#import "Masonry.h"
#import "KFPatternModel.h"
#define URLimage @"//kefu-prod-avatar.img-cn-hangzhou.aliyuncs.com/"

@interface AdminInforViewController () <AdminInforEditViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,LMJDropdownMenuDelegate, LMJDropdownMenuDataSource>{
    NSArray * _answerPatterns;
    NSArray * _answerSendPatterns;
    
    BOOL _isOn;
    
    int   answerMatchPattern;
    int   sendPattern ;
    
    
    NSMutableDictionary *_setPatternDic;
}

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *uploadImage;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UISwitch *greetingsSwitch;
@property (nonatomic, strong) UISwitch *appAssistantSwitch;
@property (nonatomic, strong) LMJDropdownMenu *menu; //匹配模式菜单
@property (nonatomic, strong) LMJDropdownMenu *sendMenu;//发送模式菜单
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) KFPatternModel *patternModel;

@end

@implementation AdminInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"个人信息";
    
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    self.tableView.backgroundColor = kTableViewHeaderAndFooterColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.headerView];
    self.tableView.top += self.headerView.height;
    self.tableView.height -= self.headerView.height;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    [self loadData];
    
    [self showCurrentVersion];
    
    
   
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self getMatchPattern];
}

- (void)showCurrentVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [NSString stringWithFormat:@"(%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    NSString *fullVersion = [version stringByAppendingString:build];
    UILabel  *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerView.width-150, self.headerView.height - 20, 140, 20)];
    versionLabel.font = [UIFont systemFontOfSize:10];
    versionLabel.textAlignment = NSTextAlignmentRight;
    versionLabel.textColor = [UIColor lightGrayColor];
    versionLabel.text = [NSString stringWithFormat:@"版本号:%@",fullVersion];
    [self.headerView addSubview:versionLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        // 需要重新加载数据并刷新
        [self loadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc ]init];
    }
    
    return  _dataArray;
}

- (UIView *)line
{
    if (_line == nil) {
        _line = [[UIView alloc] init];
        _line.frame = CGRectMake(0, 0, KScreenWidth, 1.0);
        _line.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
        _line.top = 50 - _line.height;
    }
    return _line;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        _headerView.backgroundColor = kNavBarBgColor;
        _headerView.userInteractionEnabled = YES;
        
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((KScreenWidth-48)/2, 0, 48, 48)];
        _headerImageView.userInteractionEnabled = YES;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[HDClient sharedClient].currentAgentUser.avatar ] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
        [_headerView addSubview:_headerImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadHeaderImage)];
        [self.headerImageView addGestureRecognizer:tap];
        
        _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth-200)/2, CGRectGetMaxY(_headerImageView.frame), 200, 40.f)];
        _nicknameLabel.text = [HDClient sharedClient].currentAgentUser.nicename;
        _nicknameLabel.font = [UIFont boldSystemFontOfSize:18.f];
        _nicknameLabel.textColor = [UIColor whiteColor];
        _nicknameLabel.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:_nicknameLabel];
    }
    return _headerView;
}

- (UISwitch*)greetingsSwitch
{
    if (_greetingsSwitch == nil) {
        _greetingsSwitch = [[UISwitch alloc] init];
        [_greetingsSwitch addTarget:self action:@selector(greetingStateAction) forControlEvents:UIControlEventValueChanged];
        _greetingsSwitch.left = self.tableView.width - 10 - _greetingsSwitch.width;
        _greetingsSwitch.top = (DEFAULT_CELLHEIGHT - _greetingsSwitch.height) / 2;
    }
    return _greetingsSwitch;
}
- (UISwitch*)appAssistantSwitch
{
    if (_appAssistantSwitch == nil) {
        _appAssistantSwitch = [[UISwitch alloc] init];
        [_appAssistantSwitch addTarget:self action:@selector(appAssistantSwitchStateAction) forControlEvents:UIControlEventValueChanged];
        _appAssistantSwitch.left = self.tableView.width - 10 - _appAssistantSwitch.width;
        _appAssistantSwitch.top = (DEFAULT_CELLHEIGHT - _appAssistantSwitch.height) / 2;
    }
    return _appAssistantSwitch;
}
#pragma mark - Action

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingBackAction" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3 + self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (self.dataArray.count > 0) {
        if (section == 0) {
            return 6;
        } else if (section == 1) {
            return 3;
        }
        else if (section == 2) {
            return 2;
        }
        return 1;
    }else{
        if (section == 0) {
            return 6;
        } else if (section == 1) {
            return 2;
        }
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CompileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[CompileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
            cell.backgroundColor = UIColor.whiteColor;
            cell.textLabel.textColor = UIColor.grayColor;
        }
        switch (indexPath.row) {
            case 0:
            {
                cell.title.text = @"昵称";
                cell.nickName.text = [HDClient sharedClient].currentAgentUser.nicename;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 1:
            {
                cell.title.text = @"名字";
                cell.nickName.text = [HDClient sharedClient].currentAgentUser.truename;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 2:
            {
                cell.title.text = @"编号";
                cell.nickName.text = [HDClient sharedClient].currentAgentUser.agentNumber;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 3:
            {
                cell.title.text = @"手机";
                cell.nickName.text = [HDClient sharedClient].currentAgentUser.mobilePhone;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 4:
            {
                cell.title.text = @"邮箱";
                cell.nickName.text = [HDClient sharedClient].currentAgentUser.username;
                cell.nickName.textColor = [UIColor lightGrayColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
                break;
            case 5:
            {
                cell.title.text = @"密码";
                cell.nickName.text = @"******";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            default:
                break;
        }
        return cell;
    }
    
    if (self.dataArray.count > 0) {
        //有智能辅助
        if (indexPath.section == 1) {
            //创建 问候语cell
            return  [self createSmartCellAtIndexpath:indexPath];
        }else if(indexPath.section ==2){
            //创建 问候语cell
            return  [self createGreetingCellAtIndexpath:indexPath];
            
        }else{
            return  [self createLogoutCellAtIndexpath:indexPath];
        }
        
    }else{
        //没有智能辅助
        if (indexPath.section == 1) {
         
            //创建 问候语cell
            return  [self createGreetingCellAtIndexpath:indexPath];
        }else {
            
            return  [self createLogoutCellAtIndexpath:indexPath];
        }
    }
    
    
    return nil;
}
- (UITableViewCell *)createSmartCellAtIndexpath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SmartCellTypeConversation1"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SmartCellTypeConversation1"];
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.textColor = UIColor.grayColor;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"智能辅助";
        cell.textLabel.width =130;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"答案匹配模式";
        cell.textLabel.width =130;
        [cell addSubview:self.menu];
        [self.menu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.trailing.offset(-15);
//                make.width.offset(cell.width/2);
            make.leading.offset(cell.textLabel.width +20);
            
        }];
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"答案发送模式";
        cell.textLabel.width =130;
        [cell addSubview:self.sendMenu];
        [self.sendMenu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.trailing.offset(-15);
//                make.width.offset(cell.width/2);
            make.leading.offset(cell.textLabel.width +20);
            
        }];
    }
    
    return cell;
}
- (UITableViewCell *)createGreetingCellAtIndexpath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GreetingCellTypeConversation1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GreetingCellTypeConversation1"];
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.textColor = UIColor.grayColor;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"客服问候语";
        [cell addSubview:self.greetingsSwitch];
        [cell addSubview:self.line];
        [self.greetingsSwitch setOn:[HDClient sharedClient].currentAgentUser.greetingEnable];
    } else if (indexPath.row == 1) {
        if ([HDClient sharedClient].currentAgentUser.greetingContent <= 0) {
            cell.textLabel.text = @"会话分配到客服时，将自动发送客服个人的问候语";
            cell.textLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.textLabel.text = [HDClient sharedClient].currentAgentUser.greetingContent;
            cell.textLabel.textColor = [UIColor blackColor];
        }
        cell.textLabel.width = KScreenWidth - cell.textLabel.left;
    }
    return cell;
    
    
}
- (UITableViewCell *)createLogoutCellAtIndexpath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LogoutCellTypeConversation1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LogoutCellTypeConversation1"];
        cell.backgroundColor = UIColor.whiteColor;
    }
    cell.textLabel.text = @"退出登录";
    cell.textLabel.textColor = [UIColor redColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
    
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 5.f;
    } else if (section == 1) {
        return 5.f;
    }
    else if (section == 2) {
        return 20.f;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = kTableViewHeaderAndFooterColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = kTableViewHeaderAndFooterColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            return;
        }
        AdminInforEditViewController *admin = [[AdminInforEditViewController alloc] initWithType:(int)indexPath.row];
        admin.delegate = self;
        CompileTableViewCell *cell = (CompileTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        admin.title = cell.title.text;
        if (indexPath.row != 5) {
            admin.editContent = cell.nickName.text;
        }
        [self.navigationController pushViewController:admin animated:YES];
    }else{
        if (self.dataArray.count >0) {
            if (indexPath.section == 2) {
                if (indexPath.row == 1) {
                    AdminInforEditViewController *admin = [[AdminInforEditViewController alloc] initWithType:6];
                    admin.delegate = self;
                    admin.title = @"客服问候语";
                    admin.editContent = [HDClient sharedClient].currentAgentUser.greetingContent;
                    [self.navigationController pushViewController:admin animated:YES];
                }
            }  else if (indexPath.section == 3) {
                [self logoffButtonAction];
            }
        }else{
            if (indexPath.section == 1) {
                if (indexPath.row == 1) {
                    AdminInforEditViewController *admin = [[AdminInforEditViewController alloc] initWithType:6];
                    admin.delegate = self;
                    admin.title = @"客服问候语";
                    admin.editContent = [HDClient sharedClient].currentAgentUser.greetingContent;
                    [self.navigationController pushViewController:admin animated:YES];
                    
                }
            }  else if (indexPath.section == 2) {
                [self logoffButtonAction];
            }
            
        }
            
    }

}

#pragma mark - AdminInforEditViewControllerDelegate

- (void)saveParameter:(NSString *)value key:(NSString *)key
{
    [self.navigationController popToViewController:self animated:YES];
    if ([key isEqualToString:@"content"]) {
        WEAK_SELF
        [[HDClient sharedClient].setManager updateGreetingContent:value completion:^(id responseObject, HDError *error) {
            if (error == nil) {
                [weakSelf showHint:@"保存成功"];
                [weakSelf refreshView];
            } else {
                [weakSelf showHint:@"保存失败"];
            }
        }];
    } else {
        [self showHintNotHide:@"修改个人信息..."];
        WEAK_SELF
        [[HDClient sharedClient].setManager modifyInfoWithKey:key value:value completion:^(id responseObject, HDError *error) {
            if (error == nil) {
                [weakSelf.navigationController popToViewController:weakSelf animated:YES];
                [weakSelf showHint:@"修改成功"];
                [weakSelf hideHud];
                [weakSelf refreshView];
            } else {
                [weakSelf showHint:@"修改失败"];
                [weakSelf hideHud];
            }
        }];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
    } else if (buttonIndex == 1) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orgImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    }];
    
    NSData *data = UIImageJPEGRepresentation(orgImage, 0.5);
    [self showHintNotHide:@"上传头像..."];
    WEAK_SELF
    [[HDClient sharedClient].setManager asyncUploadImageWithFile:data completion:^(NSString *url, HDError *error) {
        [weakSelf hideHud];
        if (error == nil) {
            [weakSelf saveParameter:url key:USER_AVATAR];
            weakSelf.uploadImage = orgImage;
            [weakSelf refreshView];
        }else {
            [weakSelf showHint:@"修改失败"];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark private

- (void)greetingStateAction
{
    BOOL isOn = _greetingsSwitch.isOn;
    WEAK_SELF
    [[HDClient sharedClient].setManager enableGreeting:isOn completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            [weakSelf refreshView];
        } else {
            [weakSelf showHint:@"保存失败"];
            
        }
    }];
}


- (void)appAssistantSwitchStateAction
{
    
    BOOL isOn = _appAssistantSwitch.isOn;
    WEAK_SELF
    [[HDClient sharedClient].setManager enableAppAssistant:isOn completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            [weakSelf refreshView];
            [weakSelf showHint:@"保存成功"];
        } else {
            [weakSelf showHint:@"保存失败"];
            [weakSelf.appAssistantSwitch setOn:NO];
        }
    }];
}

- (void)logoffButtonAction
{
    [self showHintNotHide:@"退出登录中..."];
    WEAK_SELF
    
    [[HDClient sharedClient] logoutCompletion:^(HDError *error) {
        [weakSelf hideHud];
        if (error == nil) {
            [[KFManager sharedInstance] showLoginViewController];
        } else {
            [self showHint:@"退出出错"];
        }
    }];
}

- (void)uploadHeaderImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照上传", @"本地相册", nil];
    [actionSheet showInView:self.view];

}
- (void)saveAnswerMatchPattern:(NSInteger)answerMatchPattern withSendPattern:(NSInteger)sendPattern{
    
    
    [[HDClient sharedClient].setManager kf_setCooperationWithsendPattern:sendPattern withAnswerMatchPattern:answerMatchPattern Completion:^(id responseObject, HDError *error) {
        
        NSLog(@"======%@",responseObject);
        
        
        
        
    }];
    
    
}
- (void)getMatchPattern{
    
    
    [[HDClient sharedClient].setManager kf_getCooperationWithPatternCompletion:^(id responseObject, HDError *error) {
        
        NSLog(@"-----%@",responseObject);
        WEAK_SELF
        if (error == nil) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary * dic = responseObject;
                if ([[dic allKeys] containsObject:@"entity"]) {
                    
                    NSDictionary * entity = [dic objectForKey:@"entity"];
                    
                    int open  =  [[entity valueForKey:@"open"] intValue];
                    
                    if (open == 1) {
                        //判断接口有没有 开启这个开关
                        [weakSelf.dataArray addObject:@(open)];
                    }else{
                        
                        [weakSelf.dataArray removeAllObjects];
                        
                    }
                    
                    //精准模式 是1   模糊是 1
                    //自动发送 1  手动发送 0
                     answerMatchPattern = [[entity valueForKey:@"answerMatchPattern"] intValue];
                     sendPattern = [[entity valueForKey:@"sendPattern"] intValue];
                    
                    if (answerMatchPattern == 1) {
                        
                        _answerPatterns = @[@"模糊匹配",@"精准匹配"];
                        
                    }else{
                        
                        _answerPatterns = @[@"精准匹配",@"模糊匹配"];
                    }
                    
                    if (sendPattern == 1) {
                        _answerSendPatterns = @[@"自动发送",@"手动发送"];
                    }else{
                        
                        _answerSendPatterns = @[@"手动发送",@"自动发送"];
                    }
                    self.menu.title = [_answerPatterns firstObject];
                    self.sendMenu.title =[_answerSendPatterns firstObject];
                    
                    self.patternModel = [[KFPatternModel alloc] init];
                    
                    self.patternModel.sendPattern =sendPattern;
                    self.patternModel.answerMatchPattern =answerMatchPattern;
                    self.patternModel.sendPatternName = self.menu.title;
                    self.patternModel.answerMatchPatternName = self.sendMenu.title;
    
                    [self.tableView reloadData];
                }
            }
        }
        
    }];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.dataArray.count > 0) {
        [self saveAnswerMatchPattern:self.patternModel.answerMatchPattern withSendPattern:self.patternModel.sendPattern];
    }
}

- (void)refreshView
{
    if (self.uploadImage) {
        _headerImageView.image = self.uploadImage;
    } else {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[HDClient sharedClient].currentAgentUser.avatar] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AvatarChanged" object:nil];
    _nicknameLabel.text = [HDClient sharedClient].currentAgentUser.nicename;
    [self.tableView reloadData];
}

- (void)loadData
{
    [self refreshView];
}

- (LMJDropdownMenu *)menu{
    if (!_menu) {
        
        _menu = [[LMJDropdownMenu alloc] init];
        _menu.delegate   = self;
        _menu.dataSource = self;
        
        _menu.layer.borderColor  = [UIColor whiteColor].CGColor;
        _menu.layer.cornerRadius  = 5;
        
//        _menu.title           = @"精准匹配";
        _menu.titleBgColor    = [UIColor groupTableViewBackgroundColor];
        _menu.titleFont       = [UIFont boldSystemFontOfSize:15];
        _menu.titleColor      = [UIColor blackColor];
        _menu.titleAlignment  = NSTextAlignmentLeft;
        _menu.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        _menu.rotateIcon      = [UIImage imageNamed:@"setting_arrowIcon"];
        _menu.rotateIconSize  = CGSizeMake(15, 15);

        _menu.optionBgColor       = _menu.titleBgColor;
        _menu.optionFont          = [UIFont systemFontOfSize:15];
        _menu.optionTextColor     = [UIColor blackColor];
        _menu.optionTextAlignment = NSTextAlignmentLeft;
        _menu.optionNumberOfLines = 0;
        _menu.optionLineColor     = [UIColor whiteColor];
        _menu.optionIconSize      = CGSizeMake(15, 15);
    }
    
    return _menu;
}
- (LMJDropdownMenu *)sendMenu{
    if (!_sendMenu) {
        
        _sendMenu = [[LMJDropdownMenu alloc] init];
        _sendMenu.delegate   = self;
        _sendMenu.dataSource = self;
        
        _sendMenu.layer.borderColor  = [UIColor whiteColor].CGColor;
        _sendMenu.layer.cornerRadius  = 5;
        
//        _sendMenu.title           = @"自动发送";
        _sendMenu.titleBgColor    = [UIColor groupTableViewBackgroundColor];
        _sendMenu.titleFont       = [UIFont boldSystemFontOfSize:15];
        _sendMenu.titleColor      = [UIColor blackColor];
        _sendMenu.titleAlignment  = NSTextAlignmentLeft;
        _sendMenu.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        _sendMenu.rotateIcon      = [UIImage imageNamed:@"setting_arrowIcon"];
        _sendMenu.rotateIconSize  = CGSizeMake(15, 15);

        _sendMenu.optionBgColor       = _menu.titleBgColor;
        _sendMenu.optionFont          = [UIFont systemFontOfSize:15];
        _sendMenu.optionTextColor     = [UIColor blackColor];
        _sendMenu.optionTextAlignment = NSTextAlignmentLeft;
        _sendMenu.optionNumberOfLines = 0;
        _sendMenu.optionLineColor     = [UIColor whiteColor];
        _sendMenu.optionIconSize      = CGSizeMake(15, 15);
    }
    
    return _sendMenu;
}


#pragma mark - LMJDropdownMenu DataSource
- (NSUInteger)numberOfOptionsInDropdownMenu:(LMJDropdownMenu *)menu{
    
    if (menu == self.sendMenu) {
        
        return _answerSendPatterns.count;
    }
    
    return _answerPatterns.count;
}
- (CGFloat)dropdownMenu:(LMJDropdownMenu *)menu heightForOptionAtIndex:(NSUInteger)index{
    return 44;
}
- (NSString *)dropdownMenu:(LMJDropdownMenu *)menu titleForOptionAtIndex:(NSUInteger)index{
    
    if (menu == self.sendMenu) {
        
        return _answerSendPatterns[index];
    }
    return _answerPatterns[index];
}

#pragma mark - LMJDropdownMenu Delegate
- (void)dropdownMenu:(LMJDropdownMenu *)menu didSelectOptionAtIndex:(NSUInteger)index optionTitle:(NSString *)title{
    NSLog(@"你选择了(you selected)：menu1，index: %ld - title: %@", index, title);
    
    
    if (menu == self.sendMenu) {
       
        if (![self.patternModel.sendPatternName isEqualToString:title]) {
            
            if (self.patternModel.sendPattern == 1) {
                self.patternModel.sendPattern = 0;
            }else{
                self.patternModel.sendPattern=1;
            }
        }
        
    }else{
         if (![self.patternModel.answerMatchPatternName isEqualToString:title]) {
             if (self.patternModel.answerMatchPattern == 1) {
                 self.patternModel.answerMatchPattern = 0;
             }else{
                 self.patternModel.answerMatchPattern=1;
             }

         }
    }
    
}



@end
