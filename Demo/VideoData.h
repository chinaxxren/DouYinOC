//
//  VideoModel.h
//  Demo
//
//  Created by Jiangmingz on 2022年4/3.
//  Copyright © 2022年 Jiangmingz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playable.h"

@interface VideoData : NSObject<Playable>

@property(nonatomic, assign) NSInteger id;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *cover;
@property(nonatomic, copy, nullable) NSString *avatar;
@property(nonatomic, copy, nullable) NSString *nickname;
@property(nonatomic, copy, nullable) NSString *videoUrl;

+ (NSArray<VideoData *> *)testItems;

+ (NSArray<VideoData *> *)testItemsWithCount:(NSInteger)count;

+ (VideoData *)testItem;

@end
