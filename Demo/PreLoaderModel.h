//
// Created by 赵江明 on 2022/4/3.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@class KTVHCDataLoader;
@class KTVHCDataLoader;

NS_ASSUME_NONNULL_BEGIN

/// 预加载模型
@interface PreLoaderModel : NSObject

/// 加载的URL
@property(nonatomic, strong, readonly) NSURL *URL;

/// 请求URL的Loader
@property(nonatomic, strong, readonly) KTVHCDataLoader *loader;

- (instancetype)initWithURL:(NSURL *)URL loader:(KTVHCDataLoader *)loader;

@end

NS_ASSUME_NONNULL_END
