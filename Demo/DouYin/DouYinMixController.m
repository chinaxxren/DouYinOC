//
//  DouYinMixController.m
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/6/21.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "DouYinMixController.h"

#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>

#import "VideoData.h"
#import "DonYinConstant.h"
#import "DouYinImageCell.h"
#import "DouYinPlayerCell.h"
#import "DouYinPlayerCellDelegate.h"

static NSString *kImageIdentifier = @"kImageIdentifier";
static NSString *kPlayerIdentifier = @"kPlayerIdentifier";

@interface DouYinMixController () <UITableViewDelegate, UITableViewDataSource, DouYinPlayerCellDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) ZFPlayerController *player;
@property(nonatomic, strong) ZFPlayerControlView *controlView;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation DouYinMixController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.dataSource = @[].mutableCopy;

    [self requestData];

    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];

    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:playerManager containerViewTag:kPlayerViewTag];
    self.player.controlView = self.controlView;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 0.8;
    /// 播放器view露出一半时候开始播放
    self.player.playerApperaPercent = .5;

    @zf_weakify(self)
    self.player.playerDidToEnd = ^(id _Nonnull asset) {
        @zf_strongify(self)
        [self.player stopCurrentPlayingCell];
    };

    self.player.orientationWillChange = ^(ZFPlayerController *_Nonnull player, BOOL isFullScreen) {
        kAPPDelegate.allowOrentitaionRotation = isFullScreen;
    };

    /// 停止的时候找出最合适的播放(只能找到设置了tag值cell)
    self.player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath *_Nonnull indexPath) {
        @zf_strongify(self)
        if (!self.player.playingIndexPath) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
        }
    };


    /// 滑动中找到适合的就自动播放
    /// 如果是停止后再寻找播放可以忽略这个回调
    /// 如果在滑动中就要寻找到播放的indexPath，并且开始播放，那就要这样写
    self.player.zf_playerShouldPlayInScrollView = ^(NSIndexPath *_Nonnull indexPath) {
        @zf_strongify(self)
        if ([indexPath compare:self.player.playingIndexPath] != NSOrderedSame) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
        }
    };

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @zf_weakify(self)
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @zf_strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
    }];
}

- (void)requestData {
    NSArray<VideoData *> *videoDatas = [VideoData testItems];
    [self.dataSource addObjectsFromArray:videoDatas];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIScrollViewDelegate   列表播放必须实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        DouYinPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlayerIdentifier];
        cell.delegate = self;
        cell.data = self.dataSource[indexPath.row];
        return cell;
    }
    DouYinImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kImageIdentifier];
    cell.data = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - private method

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollAnimated:(BOOL)animated {
    VideoData *data = self.dataSource[indexPath.row];
    [self.player playTheIndexPath:indexPath assetURL:[NSURL URLWithString:data.videoUrl]];

    [self.controlView showTitle:data.title
                 coverURLString:data.avatar
                 fullScreenMode:ZFFullScreenModeLandscape];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[DouYinPlayerCell class] forCellReuseIdentifier:kPlayerIdentifier];
        [_tableView registerClass:[DouYinImageCell class] forCellReuseIdentifier:kImageIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.pagingEnabled = YES;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.frame = self.view.bounds;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.rowHeight = _tableView.frame.size.height;
    }
    return _tableView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

- (void)zf_douyinRotation {

}

@end
