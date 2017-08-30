//
//  GoodsShelfViewController.m
//  takePhotoAPP
//
//  Created by yanxin_yang on 22/8/17.
//  Copyright © 2017年 teamOutPut. All rights reserved.
//

#import "GoodsShelfViewController.h"
#import "GoodsShelfTableViewCell.h"

@interface GoodsShelfViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableViewList;
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation GoodsShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatUI];
    
}

-(void)creatUI
{
    self.tableViewList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH) style:UITableViewStylePlain];
    _tableViewList.delegate = self;
    _tableViewList.dataSource = self;
    [self.view addSubview:self.tableViewList];
    self.dataSource = [[NSMutableArray alloc] init];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"goodsShelfCell";
    GoodsShelfTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        GoodsShelfTableViewCell *cell = [[GoodsShelfTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
