//
//  ImageTitleButton.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "ImageTitleButton.h"
@implementation ImageTitleButton
{
    UIImageView *iv;
}

-(void)setImage:(NSString *)imageName{
    if (imageName) {
        iv.image = [UIImage imageNamed:imageName];
    }
}

-(instancetype)initWithFrame:(CGRect)frame imageName: (NSString*)img title: (NSString*)title{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:img];
        CGSize ivSize = CGSizeMake(image.size.width/2, image.size.height/2);
        iv = [[UIImageView alloc]initWithImage: image];
        CGFloat y = CGRectGetHeight(frame)/2 - ivSize.height/2;
        iv.frame = CGRectMake(0, y, ivSize.width, ivSize.height);
        [self setTitle:title forState:UIControlStateNormal];
        [self addSubview:iv];
        
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; // 默认是居中显示的
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10+CGRectGetMaxX(iv.bounds), 0, 0)];
    }
    return self;
}

@end