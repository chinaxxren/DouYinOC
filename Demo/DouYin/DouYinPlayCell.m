//
//  DouYinPlayCell.m
//  ZFPlayer_Example
//
//  Created by 紫枫 on 2018/6/4.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "DouYinPlayCell.h"

#import <ZFPlayer/UIView+ZFFrame.h>

#import "VideoData.h"

@interface DouYinPlayCell ()

@property(nonatomic, strong) UIImageView *coverImageView;

@property(nonatomic, strong) UIButton *likeBtn;

@property(nonatomic, strong) UIButton *commentBtn;

@property(nonatomic, strong) UIButton *shareBtn;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIImage *placeholderImage;

@property(nonatomic, strong) UIButton *rotation;

@end

@implementation DouYinPlayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.rotation];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.coverImageView.frame = self.contentView.bounds;

    CGFloat min_view_h = self.zf_height;
    CGFloat min_x = 20;
    CGFloat min_w = 50;
    CGFloat min_h = 50;
    CGFloat min_y = (min_view_h - min_h) / 2;

    self.rotation.frame = CGRectMake(min_x, min_y, min_w, min_h);
}

#pragma mark - action

- (void)rotationClick {
    if ([self.delegate respondsToSelector:@selector(zf_douyinRotation)]) {
        [self.delegate zf_douyinRotation];
    }
}

#pragma mark - getter

- (void)setData:(VideoData *)data {
    [super setData:data];

    if (data.width > data.height) { /// 横屏视频才支持旋转
        self.rotation.hidden = NO;
    } else {
        self.rotation.hidden = YES;
    }
}

- (UIButton *)rotation {
    if (!_rotation) {
        _rotation = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotation setImage:[UIImage imageNamed:@"zfplayer_rotaiton"] forState:UIControlStateNormal];
        [_rotation addTarget:self action:@selector(rotationClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotation;
}

@end
