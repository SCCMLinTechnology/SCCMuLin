//
//  DrawImageViewController.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/8.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "BaseViewController.h"
#import "DotView.h"
@interface DrawImageViewController : BaseViewController{
    
}

@property(nonatomic,retain)NSArray *opArr;

-(UIImage *)getImageByData:(NSArray *)data;

@end
