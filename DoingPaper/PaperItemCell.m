//
//  PaperItemCell.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperItemCell.h"
#import "PaperSingleSelectionCell.h"

@interface PaperItemCell()

// 题目web+选项cells
@property(nonatomic,strong)PaperItemCellTableView *tableView;

@end

@implementation PaperItemCell


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        [self addSubview: self.tableView];
    }
    
    return self;
}

-(PaperItemCellTableView *)tableView{
    if (!_tableView) {
        PaperItemCellTableView *tb = [[PaperItemCellTableView alloc]initWithFrame:self.bounds];
        _tableView = tb;
    }
    return _tableView;
}

// 可以发起web request, tableView reloadData
-(void)setQuestion:(PaperQuestion *)question{
    if (question != nil) { // 复用时应刷新数据
        self.tableView.question = question; // 会自动触发reloadData
        _question = question;
    }
}

@end
