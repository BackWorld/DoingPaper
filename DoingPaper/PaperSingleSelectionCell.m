 //
//  PaperSingleSelectionCell.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperSingleSelectionCell.h"

@interface PaperSingleSelectionCell()

@property(nonatomic,strong)UIImageView *radioIcon;
@property(nonatomic,strong)UILabel *nameLabel;

@end

@implementation PaperSingleSelectionCell
{
    CGFloat off10;
    CGFloat off20;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor yellowColor];
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor redColor];
        
        off10 = 10;
        off20 = 20;
        
        [self addSubview: self.radioIcon];
        [self addSubview: self.nameLabel];
    }
    return self;
}

// getters
-(UIImageView *)radioIcon{
    if (!_radioIcon) {
        CGRect frame = CGRectMake(off20, CGRectGetHeight(self.bounds)/2-23/2.0, 23, 23);
        UIImageView *iv = [[UIImageView alloc]initWithFrame: frame];
        _radioIcon = iv;
    }
    return _radioIcon;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(CGRectGetMaxX(_radioIcon.frame)+off10, 0, CGRectGetWidth([UIScreen mainScreen].bounds)-CGRectGetMaxX(_radioIcon.frame)-off10-off20, CGRectGetHeight(self.bounds))];
        label.text = @"选项";
        
        _nameLabel = label;
    }
    return _nameLabel;
}


// setters

-(void)setSelectionName:(NSString *)selectionName{
    _nameLabel.text = selectionName; //cell 复用时，应该更新数据
    
    _selectionName = selectionName;
}

-(void)setChoosed:(BOOL)choosed{ //用自定义属性 控制icon，selected不好用
    if (choosed) {
        _radioIcon.image = [UIImage imageNamed:@"radio_icon_sel"];
    }else{
        _radioIcon.image = [UIImage imageNamed:@"radio_icon"];
    }
}

@end
