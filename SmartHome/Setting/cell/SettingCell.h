//
//  SettingCell.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/7/6.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *scaleImgView;

@property(nonatomic,weak)IBOutlet UIButton *delBtn;
@end
