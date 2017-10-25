//
//  HomeViewController.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "BaseViewController.h"

#import "LayoutSofaViewController.h"
#import "SettingViewController.h"
#import "PZMessageUtils.h"

#import "OPAPViewController.h"


#import "TestViewController.h"
#import "SettingViewController.h"

@interface HomeViewController : BaseViewController<UIAlertViewDelegate>{
    float   angle ;
    UIImageView *componyImg;
    UIButton *apBtn;
    UIImageView *bleImg;
    
}




@end
