//
// Created by 赵江明 on 2022/4/3.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

@protocol Playable;

@interface PreLoaderManager : NSObject

/// 预加载上几条
@property(nonatomic, assign) NSUInteger preLoadNum;

/// 预加载下几条
@property(nonatomic, assign) NSUInteger nextLoadNum;

/// 预加载的的百分比，默认10%
@property(nonatomic, assign) double preloadPrecent;

/// 设置playableAssets后，马上预加载的条数
@property(nonatomic, assign) NSUInteger initPreloadNum;

/// 可播放的视频的模型数组，若是混合区域，模型需要实现XSTPlayable
/// set之后，先预加载几个
@property(nonatomic, strong) NSArray <Playable> *playableArray;

/// 当前正在播放的 MPPlayable 资源
@property(nonatomic, strong, readonly) id <Playable> playable;

+ (instancetype)shared;

/// 播放指定的url
- (NSURL *)playCurrentURL:(id <Playable>)playable;

@end
