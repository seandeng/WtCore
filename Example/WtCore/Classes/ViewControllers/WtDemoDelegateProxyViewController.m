//
//  WtDemoDelegateProxyViewController.m
//  WtCore_Example
//
//  Created by wtfan on 2017/9/1.
//  Copyright © 2017年 JaonFanwt. All rights reserved.
//

#import "WtDemoDelegateProxyViewController.h"

#import <WtCore/WtCore.h>

#import "WtDemoCellGlue.h"


@interface WtDemoDelegateProxyViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@end


@implementation WtDemoDelegateProxyViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  self.title = @"WtDelegateProxy Library";
  [self createDatas];
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)createDatas {
  _datas = @[].mutableCopy;

  {
    WtDemoCellGlue *cellGlue = [[WtDemoCellGlue alloc] init];
    [_datas addObject:cellGlue];
    cellGlue.title = @"参考：使用NSInvocation执行block";
    [cellGlue.tableViewDelegate selector:@selector(tableView:didSelectRowAtIndexPath:) block:^(UITableView *tableView, NSIndexPath *indexPath) {
      CGAffineTransform (^block)(id x, int y, CGSize z) = ^(id x, int y, CGSize z) {
        CGAffineTransform t = {1, 2, 3, 4, 5, 6};
        return t;
      };

      const char *_Block_signature(void *);
      const char *signature = _Block_signature((__bridge void *)block);

      NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:signature];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
      [invocation setTarget:block];
      void *x = (__bridge void *)@"Foo";
      int y = 42;
      CGSize z = {320, 480};

      [invocation setArgument:&x atIndex:1];
      [invocation setArgument:&y atIndex:2];
      [invocation setArgument:&z atIndex:3];
      [invocation invoke];
      CGAffineTransform t;
      [invocation getReturnValue:&t];

      NSLog(@"%s - %@", __func__, NSStringFromCGAffineTransform(t));
    }];
  }

  {
    WtDemoCellGlue *cellGlue = [[WtDemoCellGlue alloc] init];
    [_datas addObject:cellGlue];
    cellGlue.title = @"DelegetaProxy举例";
    cellGlue.subTitle = @"UITableViewDataSource";
    [cellGlue.tableViewDelegate selector:@selector(tableView:didSelectRowAtIndexPath:) block:^(UITableView *tableView, NSIndexPath *indexPath) {

      id block = ^(UITableView *tableView, NSIndexPath *indexPath) {
        NSLog(@"%s - %@", __func__, indexPath);
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1233211234567"];
      };

      id block2 = ^(UITableView *tableView, NSIndexPath *indexPath) {
        NSLog(@"%s - %@", __func__, indexPath);
        return YES;
      };

      UITableViewCell * (^block3)(UITableView *tableView, NSIndexPath *indexPath) = ^(UITableView *tableView, NSIndexPath *indexPath) {
        NSLog(@"%s - %@", __func__, indexPath);
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abcdefg"];
      };

      void (^block4)(UITableView *tableView, NSIndexPath *indexPath, NSIndexPath *toIndexPath) = ^(UITableView *tableView, NSIndexPath *indexPath, NSIndexPath *toIndexPath) {
        NSLog(@"%s - From:%@ To:%@", __func__, indexPath, toIndexPath);
      };

      WtDelegateProxy<UITableViewDataSource> *proxy = (WtDelegateProxy<UITableViewDataSource> *)[[WtDelegateProxy alloc] initWithProtocol:@protocol(UITableViewDataSource)];
      [proxy selector:@selector(tableView:cellForRowAtIndexPath:) block:block];
      [proxy selector:@selector(tableView:canEditRowAtIndexPath:) block:block2];
      [proxy selector:@selector(tableView:cellForRowAtIndexPath:) block:block3];
      [proxy selector:@selector(tableView:moveRowAtIndexPath:toIndexPath:) block:block4];

      UITableViewCell *cell = [proxy tableView:[UITableView new] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:100 inSection:100]];
      [proxy tableView:[UITableView new] moveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];

      BOOL canEdit = [proxy tableView:[UITableView new] canEditRowAtIndexPath:[NSIndexPath indexPathForRow:200 inSection:200]];

      [proxy tableView:[UITableView new] moveRowAtIndexPath:[NSIndexPath indexPathForRow:300 inSection:300] toIndexPath:[NSIndexPath indexPathForRow:400 inSection:400]];

      NSLog(@"%s - %@", __func__, cell.reuseIdentifier);
      NSLog(@"%s - %d", __func__, canEdit);
    }];
  }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  WtCellGlue *cellGlue = _datas[indexPath.row];
  return [cellGlue.tableViewDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  WtCellGlue *cellGlue = _datas[indexPath.row];
  return [cellGlue.tableViewDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  WtCellGlue *cellGlue = _datas[indexPath.row];
  [cellGlue.tableViewDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
