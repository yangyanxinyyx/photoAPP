//
//  GoodsShelfViewController.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 22/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GoodsShelfViewController.h"
#import "GoodsShelfTableViewCell.h"
#import "GoodsShelfTopBar.h"
#import "DataBaseManager.h"
#import "GoodsShelfDataManager.h"
#import "CameraViewController.h"

@interface GoodsShelfViewController ()<UITableViewDelegate,UITableViewDataSource,GoodsShelfTopBarDelegate>
@property (nonatomic,strong) UITableView *tableViewList;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) GoodsShelfTopBar *topbar;
@end

@implementation GoodsShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addModelNotify:) name:kAddModelNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uodateModelNotify:) name:kUpdateModelNotify object:nil];
    [self creatUI];
    [self requestData];
    if (_tableViewList && self.dataSource.count >0) {
        [self.tableViewList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddModelNotify object:nil];
}

-(void)creatUI
{
    self.view.backgroundColor = UICOLOR(248, 248, 248, 1);
    _topbar = [[GoodsShelfTopBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    _topbar.topBarDelegate = self;
    [self.view addSubview:_topbar];
    
    self.tableViewList = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+8, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 8 -226/2) style:UITableViewStylePlain];
    _tableViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewList.delegate = self;
    _tableViewList.dataSource = self;
    _tableViewList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableViewList];
    self.dataSource = [[NSMutableArray alloc] init];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addBtn];
    addBtn.frame = CGRectMake((SCREEN_WIDTH - 180)/2, SCREEN_HEIGHT-155/2, 180, 45);
    addBtn.layer.cornerRadius = 45/2;
    addBtn.layer.masksToBounds = YES;
    addBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [addBtn setTitle:@"添加货架" forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"add_shelf"] forState:UIControlStateNormal];
    addBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    addBtn.backgroundColor = UICOLOR(213, 41, 39, 1);
    [addBtn addTarget:self action:@selector(pressToAddShelf) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)requestData
{
    NSArray *array = [[GoodsShelfDataManager shareInstance] datas];
    self.dataSource  = [NSMutableArray arrayWithArray:array];
    [self.tableViewList reloadData];
}

#pragma mark- tableviewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 20;
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"goodsShelfCell";
    GoodsShelfTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GoodsShelfTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];

    }
    GoodsShelfModel *model = _dataSource[indexPath.row];
    cell.thumbImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",model.thumbLink]];
    cell.state = model.goodUploadState;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO]; 
    GoodsShelfModel *model = _dataSource[indexPath.row];
    if ([model.goodUploadState isEqualToString: GoodsUploadStateFail]) {
        NSLog(@"重发");
        [[GoodsShelfDataManager shareInstance] reSendImagewithModel:model];
    }
}

- (void)addModelNotify:(NSNotification *)notify
{
    [self requestData];
    [self.tableViewList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)uodateModelNotify:(NSNotification *)notify
{
    NSInteger index = [notify.object[@"index"] integerValue];
    NSArray *array = [[GoodsShelfDataManager shareInstance] datas];
    self.dataSource  = [NSMutableArray arrayWithArray:array];
    if (index>0 && index < self.dataSource.count) {
            [self.tableViewList reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pressToBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressToAddShelf
{
    NSLog(@"添加货架");
    
    NSArray *array = self.navigationController.viewControllers;
    for (int i=0; i<array.count; i++) {
        if ([array[i] isKindOfClass:[CameraViewController class]]) {
            [self.navigationController popToViewController:array[i] animated:YES];
        }
    }
}

- (void)pressToFinish
{
    NSDictionary *param = @{@"thumbLink":@"123",
                            @"imagePaths":@[@"1",@"2",@"3"]};
    [[GoodsShelfDataManager shareInstance] sendImageWithParam:param];
    
    NSLog(@"完成 跳转微信");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
