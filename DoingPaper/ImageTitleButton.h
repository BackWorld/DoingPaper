//
//  ImageTitleButton.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTitleButton : UIButton

-(instancetype)initWithFrame:(CGRect)frame imageName: (NSString*)img title: (NSString*)title;
-(void)setImage: (NSString*)imageName;

@end
