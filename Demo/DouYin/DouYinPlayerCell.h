//
//  DouYinPlayerCell.h
//  ZFPlayer_Example
//
//  Created by 紫枫 on 2018/6/4.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DouYinPlayerCellDelegate.h"

@class VideoData;

@interface DouYinPlayerCell : UITableViewCell

@property(nonatomic, weak) id <DouYinPlayerCellDelegate> delegate;

- (void)fillData:(VideoData *)data;

@end
