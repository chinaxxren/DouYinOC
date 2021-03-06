//
// Created by 赵江明 on 2022/4/4.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import "DouYinPlayerController.h"

#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <MJRefresh/MJRefresh.h>

#import "DouYinPlayerCell.h"
#import "DouYinControlView.h"
#import "FullControlView.h"
#import "PreLoaderManager.h"
#import "DonYinConstant.h"
#import "DouYinImageCell.h"
#import "VideoData.h"

static NSString *kPlayIdentifier = @"kPlayIdentifier";
static NSString *kImageIdentifier = @"kImageIdentifier";

@interface DouYinPlayerController () <UITableViewDelegate, UITableViewDataSource, DouYinPlayerCellDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) ZFPlayerController *player;
@property(nonatomic, strong) DouYinControlView *controlView;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) FullControlView *fullControlView;
@property(nonatomic, assign) BOOL isInited;

@end

@implementation DouYinPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];

    NSLog(@"%@", NSTemporaryDirectory());
    [self requestData];

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_header = header;

    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];

    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:playerManager containerViewTag:kPlayerViewTag];
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    self.player.controlView = self.controlView;

    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    
    /// 1.0是完全消失时候
    self.player.playerDisapperaPercent = 1.0;
    /// 播放器view露出一半时候开始播放
    self.player.playerApperaPercent = .5;

    @zf_weakify(self)
    self.player.playerDidToEnd = ^(id _Nonnull asset) {
        @zf_strongify(self)
        [self.player.currentPlayerManager replay];
    };

    self.player.orientationWillChange = ^(ZFPlayerController *_Nonnull player, BOOL isFullScreen) {
        kAPPDelegate.allowOrentitaionRotation = isFullScreen;
        @zf_strongify(self)
        self.player.controlView.hidden = YES;
    };

    self.player.orientationDidChanged = ^(ZFPlayerController *_Nonnull player, BOOL isFullScreen) {
        @zf_strongify(self)
        self.player.controlView.hidden = NO;
        if (isFullScreen) {
            self.player.controlView = self.fullControlView;
        } else {
            self.player.controlView = self.controlView;
        }
    };

    /// 更新另一个控制层的时间
    self.player.playerPlayTimeChanged = ^(id <ZFPlayerMediaPlayback> _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @zf_strongify(self)
        if ([self.player.controlView isEqual:self.fullControlView]) {
            [self.controlView videoPlayer:self.player currentTime:currentTime totalTime:duration];
        } else if ([self.player.controlView isEqual:self.controlView]) {
            [self.fullControlView videoPlayer:self.player currentTime:currentTime totalTime:duration];
        }
    };

    /// 更新另一个控制层的缓冲时间
    self.player.playerBufferTimeChanged = ^(id <ZFPlayerMediaPlayback> _Nonnull asset, NSTimeInterval bufferTime) {
        @zf_strongify(self)
        if ([self.player.controlView isEqual:self.fullControlView]) {
            [self.controlView videoPlayer:self.player bufferTime:bufferTime];
        } else if ([self.player.controlView isEqual:self.controlView]) {
            [self.fullControlView videoPlayer:self.player bufferTime:bufferTime];
        }
    };

    /// 停止的时候找出最合适的播放(只能找到设置了tag值cell)
    self.player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if (indexPath.row == self.dataSource.count - 1) {
            /// 加载下一页数据
            [self requestData];
            [self.tableView reloadData];
        }
        
        if (!self.player.playingIndexPath) {
            [self playTheVideoAtIndexPath:indexPath];
        }
    };

     
    /// 滑动中找到适合的就自动播放
    /// 如果是停止后再寻找播放可以忽略这个回调
    /// 如果在滑动中就要寻找到播放的indexPath，并且开始播放，那就要这样写
    self.player.zf_playerShouldPlayInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @zf_strongify(self)
        if ([indexPath compare:self.player.playingIndexPath] != NSOrderedSame) {
            [self playTheVideoAtIndexPath:indexPath];
        }
    };
    
    self.player.presentationSizeChanged = ^(id <ZFPlayerMediaPlayback> _Nonnull asset, CGSize size) {
        @zf_strongify(self)
        if (size.width >= size.height) {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
        } else {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        }
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    if (!self.isInited) {
        self.isInited = YES;
        
        @zf_weakify(self)
        [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
            @zf_strongify(self)
            [self playTheVideoAtIndexPath:indexPath];
        }];
    }
}

- (void)loadNewData {
    [self.dataSource removeAllObjects];

    @zf_weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        /// 下拉时候一定要停止当前播放，不然有新数据，播放位置会错位。
        [self.player stopCurrentPlayingCell];
        [self requestData];
        [self.tableView reloadData];

        /// 找到可以播放的视频并播放
        [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
            @zf_strongify(self)
            if (indexPath.row % 2 != 0) {
                [self playTheVideoAtIndexPath:indexPath];
            }
        }];
    });
}

- (void)requestData {
    NSArray<VideoData *> *videoDatas = [VideoData testItems];
    [self.dataSource addObjectsFromArray:videoDatas];
    [PreLoaderManager shared].playableArray = videoDatas;
    [self.tableView.mj_header endRefreshing];
}

- (void)playTheIndex:(NSInteger)index {

    /// 指定到某一行播放
    @zf_weakify(self)
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @zf_strongify(self)
        [self playTheVideoAtIndexPath:indexPath];
    }];

    /// 如果是最后一行，去请求新数据
    if (index == self.dataSource.count - 1) {
        /// 加载下一页数据
        [self requestData];
        [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIScrollViewDelegate  列表播放必须实现

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

#pragma mark - ZFDouYinCellDelegate

- (void)zf_douyinRotation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if (self.player.isFullScreen) {
        orientation = UIInterfaceOrientationPortrait;
    } else {
        orientation = UIInterfaceOrientationLandscapeRight;
    }
    [self.player rotateToOrientation:orientation animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row % 2 == 0) {
        DouYinPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlayIdentifier];
        cell.delegate = self;
        [cell fillData:self.dataSource[row]];
        return cell;
    } else {
        DouYinImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kImageIdentifier];
        [cell fillData:self.dataSource[row]];
        return cell;
    }
}

#pragma mark - private method

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    VideoData *data = self.dataSource[indexPath.row];
    PreLoaderManager *manager = [PreLoaderManager shared];
    NSURL *URL = [manager playCurrentURL:data];
    [self.player playTheIndexPath:indexPath assetURL:URL];
    [self.controlView resetControlView];
    [self.controlView showCoverViewWithUrl:data.cover];
    [self.fullControlView showTitle:@"custom landscape controlView" coverURLString:data.cover fullScreenMode:ZFFullScreenModeLandscape];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.pagingEnabled = YES;
        [_tableView registerClass:[DouYinPlayerCell class] forCellReuseIdentifier:kPlayIdentifier];
        [_tableView registerClass:[DouYinImageCell class] forCellReuseIdentifier:kImageIdentifier];
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.frame = self.view.bounds;
        _tableView.rowHeight = _tableView.frame.size.height;
        _tableView.scrollsToTop = NO;
    }
    return _tableView;
}

- (DouYinControlView *)controlView {
    if (!_controlView) {
        _controlView = [DouYinControlView new];
    }
    return _controlView;
}

- (FullControlView *)fullControlView {
    if (!_fullControlView) {
        _fullControlView = [[FullControlView alloc] init];
    }
    return _fullControlView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

@end
