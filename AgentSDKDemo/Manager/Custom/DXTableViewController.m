//
//  DXTableViewController.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTableViewController.h"

@interface DXTableViewController ()

@end

@implementation DXTableViewController

@synthesize backItem = _backItem;
@synthesize dataSource = _dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    _dataSource = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)titleBtn
{
    if (!_titleBtn) {
        _titleBtn = [[UIButton alloc] init];
        _titleBtn.frame = CGRectMake(0, 0, 100.0f, 44.0f);
        _titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleBtn addTarget:self action:@selector(scrollToTopAction:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [_titleBtn setTitle:self.title forState:UIControlStateNormal];
    }
    return _titleBtn;
}

#pragma mark - property

- (UIBarButtonItem *)backItem
{
    if (_backItem == nil) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
    return _backItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TabelViewCell"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TabelViewCell"];
    }
    
    return cell;
}


#pragma mark - action

- (void)dxDelegateAction:(NSDictionary *)userInfo {
    if (_dxDelegate && [_dxDelegate respondsToSelector:@selector(dxtableView:userInfo:)]) {
        [_dxDelegate dxtableView:self userInfo:userInfo];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scrollToTopAction:(id)sender withEvent:(UIEvent*)event {
    
    UITouch* touch = [[event allTouches] anyObject];
    if (touch.tapCount == 2) {
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
