//
// Created by 赵江明 on 2022/4/5.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import "DouYinImageCell.h"
#import "VideoData.h"


@implementation DouYinImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor grayColor];
    }
    return self;
}

@end
