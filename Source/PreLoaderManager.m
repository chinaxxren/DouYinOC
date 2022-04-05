//
// Created by 赵江明 on 2022/4/3.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//


#import "PreLoaderManager.h"

#import <KTVHTTPCache/KTVHCDataLoader.h>
#import <KTVHTTPCache/KTVHTTPCache.h>

#import "PreLoaderModel.h"
#import "Playable.h"

@interface PreLoaderManager () <KTVHCDataLoaderDelegate>

/// 预加载的模型数组
@property(nonatomic, strong) NSMutableArray<PreLoaderModel *> *preloadArr;

@end

@implementation PreLoaderManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static PreLoaderManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

/// 初始化
- (void)setup {
    _preLoadNum = 2;
    _nextLoadNum = 2;
    _preloadPrecent = 0.1;
    _initPreloadNum = 3;

    [KTVHTTPCache logSetConsoleLogEnable:NO];
    NSError *error = nil;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    }
    [KTVHTTPCache encodeSetURLConverter:^NSURL *(NSURL *URL) {
        return [NSURL URLWithString:URL.path];
    }];
    [KTVHTTPCache downloadSetUnacceptableContentTypeDisposer:^BOOL(NSURL *URL, NSString *contentType) {
        return YES;
    }];
    
    // 设置缓存最大容量
    [KTVHTTPCache cacheSetMaxCacheLength:1024 * 1024 * 1024];
}

- (NSURL *)playCurrentURL:(id <Playable>)playable {
    _playable = playable;
    
    // 预加载即将播放的视频
    [self preload:playable];
    
    NSURL *assetURL = [NSURL URLWithString:playable.videoUrl];
    NSURL *URL = [KTVHTTPCache cacheCompleteFileURLWithURL:assetURL];
    if (URL) {
        return URL;
    }
    return [KTVHTTPCache proxyURLWithOriginalURL:assetURL];
}

// MARK: - Setter
- (void)setPlayableArray:(NSArray <Playable> *)playableArray {
    _playableArray = playableArray;

    [self cancelAllPreload];

    // 默认预加载前几条数据
    NSRange range = NSMakeRange(0, _initPreloadNum);
    if (range.length > playableArray.count) {
        range.length = playableArray.count;
    }
    NSArray *subArr = [playableArray subarrayWithRange:range];
    for (id <Playable> model in subArr) {
        PreLoaderModel *preload = [self getPreloadModel:model.videoUrl];
        if (preload) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject:preload];
            }
        }
    }

    [self processLoader];
}

// MARK: - Preload
/// 根据传入的模型，预加载上几个，下几个的视频
- (void)preload:(id <Playable>)resource {
    if (self.playableArray.count <= 1)
        return;
    if (_nextLoadNum == 0 && _preLoadNum == 0)
        return;
    NSInteger start = [self.playableArray indexOfObject:resource];
    if (start == NSNotFound)
        return;
    [self cancelAllPreload];
    NSInteger index = 0;
    for (NSInteger i = start + 1; i < self.playableArray.count && index < _nextLoadNum; i++) {
        index += 1;
        id <Playable> model = self.playableArray[i];
        PreLoaderModel *preModel = [self getPreloadModel:model.videoUrl];
        if (preModel) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject:preModel];
            }
        }
    }
    index = 0;
    for (NSInteger i = start - 1; i >= 0 && index < _preLoadNum; i--) {
        index += 1;
        id <Playable> model = self.playableArray[i];
        PreLoaderModel *preModel = [self getPreloadModel:model.videoUrl];
        if (preModel) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject:preModel];
            }
        }
    }
    [self processLoader];
}

/// 取消所有的预加载
- (void)cancelAllPreload {
    @synchronized (self.preloadArr) {
        if (self.preloadArr.count == 0) {
            return;
        }
        [self.preloadArr enumerateObjectsUsingBlock:^(PreLoaderModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [obj.loader close];
        }];
        [self.preloadArr removeAllObjects];
    }
}

- (PreLoaderModel *)getPreloadModel:(NSString *)urlStr {
    if (!urlStr)
        return nil;

    NSURL *originURL = [NSURL URLWithString:urlStr];

    // 判断是否已在队列中
    __block Boolean res = NO;
    @synchronized (self.preloadArr) {
        [self.preloadArr enumerateObjectsUsingBlock:^(PreLoaderModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj.URL isEqual:originURL]) {
                res = YES;
                *stop = YES;
            }
        }];
    }
    if (res)
        return nil;

    // 判断缓存已经超过10%了
    KTVHCDataCacheItem *item = [KTVHTTPCache cacheCacheItemWithURL:originURL];
    double cachePrecent = 1.0 * item.cacheLength / item.totalLength;
    if (cachePrecent >= self.preloadPrecent) {
        return nil;
    }

    KTVHCDataRequest *req = [[KTVHCDataRequest alloc] initWithURL:originURL headers:[NSDictionary dictionary]];
    KTVHCDataLoader *loader = [KTVHTTPCache cacheLoaderWithRequest:req];
    PreLoaderModel *preModel = [[PreLoaderModel alloc] initWithURL:originURL loader:loader];
    return preModel;
}

- (void)processLoader {
    @synchronized (self.preloadArr) {
        if (self.preloadArr.count == 0)
            return;
        PreLoaderModel *model = self.preloadArr.firstObject;
        model.loader.delegate = self;
        [model.loader prepare];
    }
}

/// 根据loader，移除预加载任务
- (void)removePreloadTask:(KTVHCDataLoader *)loader {
    @synchronized (self.preloadArr) {
        PreLoaderModel *target = nil;
        for (PreLoaderModel *model in self.preloadArr) {
            if ([model.loader isEqual:loader]) {
                target = model;
                break;
            }
        }
        if (target)
            [self.preloadArr removeObject:target];
    }
}

// MARK: - KTVHCDataLoaderDelegate

- (void)ktv_loader:(KTVHCDataLoader *)loader didFailWithError:(NSError *)error {
    // 若预加载失败的话，就直接移除任务，开始下一个预加载任务
    [self removePreloadTask:loader];
    [self processLoader];
}

- (void)ktv_loader:(KTVHCDataLoader *)loader didChangeProgress:(double)progress {
    if (progress >= self.preloadPrecent) {
        [loader close];
        [self removePreloadTask:loader];
        [self processLoader];
    }
}

- (void)ktv_loaderDidFinish:(KTVHCDataLoader *)loader {
}

- (NSMutableArray<PreLoaderModel *> *)preloadArr {
    if (_preloadArr == nil) {
        _preloadArr = [NSMutableArray array];
    }
    return _preloadArr;
}

@end
