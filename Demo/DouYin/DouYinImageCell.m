//
// Created by 赵江明 on 2022/4/5.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import "DouYinImageCell.h"

@interface DouYinImageCell ()

@end

@implementation DouYinImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)fillData:(VideoData *)data {
    [self setData:data isPlayerView:NO];
}

@end
