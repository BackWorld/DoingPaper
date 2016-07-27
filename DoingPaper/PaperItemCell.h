//
//  PaperItemCell.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperQuestion.h"
#import "PaperQuestionWebCell.h"
#import "PaperItemCellTableView.h"

typedef enum : NSUInteger {
    WebDidLoad,
} PaperWebDidLoadNotificationName;

@interface PaperItemCell : UICollectionViewCell

@property(nonatomic,strong)PaperQuestion *question;

@end
