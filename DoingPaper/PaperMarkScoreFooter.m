//
//  PaperMarkScoreFooter.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperMarkScoreFooter.h"
#import "ImageTitleButton.h"

@implementation PaperMarkScoreFooter
{
    PaperQuestion *_question;
}

-(instancetype)initWithPaperQuestion: (PaperQuestion*)question{
    self = [super init];
    if (self) {
        _question = question;
        self.backgroundColor = [UIColor cyanColor];
        CGFloat h = 44;
        CGFloat space20 = 20;
        CGFloat space10 = 10;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(space20, 0, 80, h)];
        label.text = @"评分:";
        [self addSubview:label];
        
        CGSize btnSize = CGSizeMake(80, h);
        CGPoint btnOrigin = CGPointMake(CGRectGetMaxX(label.bounds)+space10, 0);
        
        for (NSInteger i=0; i<question.scores.count; i++) {
            CGRect frame = CGRectMake(btnOrigin.x, btnOrigin.y, btnSize.width, btnSize.height);
            ImageTitleButton *btn = [[ImageTitleButton alloc]initWithFrame:frame imageName:@"radio_icon" title:question.scores[i]];
            btn.tag = 1000+i;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            if (question.scoreMarkedIndex == i) {
                [btn setImage: @"radio_icon_sel"];
            }
            else{
                [btn setImage: @"radio_icon"];
            }
            btnOrigin.x += btnSize.width + space10;
            [self addSubview:btn];
        }
        
    }
    return self;
}

-(void)btnClicked: (ImageTitleButton*)sender {
    ImageTitleButton *lastBtn = [self viewWithTag: _question.scoreMarkedIndex+1000];
    [lastBtn setImage: @"radio_icon"];
    
    [sender setImage:@"radio_icon_sel"];
    NSInteger index = sender.tag - 1000;
    _question.scoreMarkedIndex = index;
}

@end
