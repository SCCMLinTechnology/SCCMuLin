//
//  UserOPViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/9/5.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "UserOPViewController.h"

@interface UserOPViewController ()

@end

@implementation UserOPViewController
@synthesize language;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"language==%@",language);
    UIScrollView *scroll = [UIScrollView new];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    float h = 0;
    if ([language isEqualToString:@"1"]) {
        //英文
        h = 1900*sWIDTH/375;
    }
    else{
        //中文
        h = 1650*sWIDTH/375;
    }
    
    scroll.contentSize = CGSizeMake(sWIDTH, h);
    scroll.zoomScale = 0.5f;   // 缩放比例
    [self.view addSubview:scroll];
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sWIDTH, h)];
    if ([language isEqualToString:@"1"]) {
        //英文
        img.image = [UIImage imageNamed:@"英文版"];
    }
    else{
        //中文
        img.image = [UIImage imageNamed:@"中文版"];
    }
    img.contentMode = UIViewContentModeScaleToFill;
    [scroll addSubview:img];
//    [img mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.mas_equalTo(0);
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
