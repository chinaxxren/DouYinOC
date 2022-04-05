//
// Created by 赵江明 on 2022/4/3.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 播放的模型，必须实现这个协议
@protocol Playable <NSObject>

/// string 视频链接
@property(nonatomic, copy) NSString *videoUrl;

@end
