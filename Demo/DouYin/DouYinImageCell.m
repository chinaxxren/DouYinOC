//
// Created by 赵江明 on 2022/4/5.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//

#import "DouYinImageCell.h"
#import "DouYinView.h"


@interface DouYinImageCell ()

@property(nonatomic, strong) DouYinView *douYinView;

@end

@implementation DouYinImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.douYinView];
    }
    return self;
}

- (void)fillData:(VideoData *)data {
    self.douYinView.data = data;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.douYinView.frame = self.bounds;
}

- (DouYinView *)douYinView {
    if (!_douYinView) {
        _douYinView = [DouYinView new];
    }
    return _douYinView;
}

@end
