//
// Created by 赵江明 on 2022/4/5.
// Copyright (c) 2022 Jiangmingz. All rights reserved.
//


#import "DouYinBaseCell.h"

#import <ZFPlayer/UIImageView+ZFCache.h>
#import <ZFPlayer/UIView+ZFFrame.h>
#import <ZFPlayer/ZFUtilities.h>

#import "VideoData.h"
#import "DonYinConstant.h"

@interface DouYinBaseCell ()

@property(nonatomic, strong) UIImageView *coverImageView;

@property(nonatomic, strong) UIButton *likeBtn;

@property(nonatomic, strong) UIButton *commentBtn;

@property(nonatomic, strong) UIButton *shareBtn;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIImage *placeholderImage;

@end

@implementation DouYinBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.coverImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.likeBtn];
        [self.contentView addSubview:self.commentBtn];
        [self.contentView addSubview:self.shareBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverImageView.frame = self.contentView.bounds;

    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.zf_width;
    CGFloat min_view_h = self.zf_height;
    CGFloat margin = 30;

    min_w = 40;
    min_h = min_w;
    min_x = min_view_w - min_w - 20;
    min_y = min_view_h - min_h - 80;
    self.shareBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);

    min_w = CGRectGetWidth(self.shareBtn.frame);
    min_h = min_w;
    min_x = CGRectGetMinX(self.shareBtn.frame);
    min_y = CGRectGetMinY(self.shareBtn.frame) - min_h - margin;
    self.commentBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);

    min_w = CGRectGetWidth(self.shareBtn.frame);
    min_h = min_w;
    min_x = CGRectGetMinX(self.commentBtn.frame);
    min_y = CGRectGetMinY(self.commentBtn.frame) - min_h - margin;
    self.likeBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);

    min_x = 20;
    min_h = 20;
    min_y = min_view_h - min_h - 50;
    min_w = self.likeBtn.zf_left - margin;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    return _likeBtn;
}


- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    }
    return _shareBtn;
}

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = [ZFUtilities imageWithColor:[UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1] size:CGSizeMake(1, 1)];
    }
    return _placeholderImage;
}

- (void)setData:(VideoData *)data {
    _data = data;
    [self.coverImageView setImageWithURLString:data.cover placeholder:[UIImage imageNamed:@"loading_bgView"]];
    self.titleLabel.text = data.title;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.tag = kPlayerViewTag;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

@end
