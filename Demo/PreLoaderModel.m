//
// Created by 赵江明 on 2022/4/3.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//


#import "PreLoaderModel.h"

#import <KTVHTTPCache/KTVHCDataLoader.h>

@implementation PreLoaderModel

- (instancetype)initWithURL:(NSURL *)URL loader:(KTVHCDataLoader *)loader {
    if (self = [super init]) {
        _URL = URL;
        _loader = loader;
    }
    return self;
}

@end