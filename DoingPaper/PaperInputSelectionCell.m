//
//  PaperInputSelectionCell.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/27.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperInputSelectionCell.h"

@interface PaperInputSelectionCell()<UITextViewDelegate>

@property(nonatomic,strong)UILabel *placeLabel; //模拟 placeholder
@property(nonatomic,strong)UITextView *textView;

@end

@implementation PaperInputSelectionCell
{
    CGSize cellSize;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor lightTextColor];
        cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 200);
        
        [self addSubview:self.textView];
    }
    return self;
}

// setters
-(void)setQuestion:(PaperQuestion *)question{
    if (question) {
        // 更新输入的内容
        _textView.text = question.inputAnswer;
        _question = question;
    }
}

// getters

-(UILabel *)placeLabel{
    if (!_placeLabel) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 16)];
        label.text = @"请输入答案...";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor lightGrayColor];
        label.userInteractionEnabled = false;
        _placeLabel = label;
    }
    return _placeLabel;
}

-(UITextView *)textView{
    if (!_textView) {
        UITextView *tv = [[UITextView alloc]initWithFrame: CGRectMake(20, 20, cellSize.width-40, cellSize.height-40)];
        tv.font = [UIFont systemFontOfSize:16];
        tv.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
        tv.delegate = self;
        tv.layer.borderColor = [UIColor grayColor].CGColor;
        tv.layer.borderWidth = 1;
        tv.layer.cornerRadius = 4;
        tv.backgroundColor = [UIColor lightTextColor];
        [tv addSubview: self.placeLabel];
        tv.keyboardType = UIKeyboardTypeDefault;
        tv.returnKeyType = UIReturnKeyDone;
        
        _textView = tv;
    }
    return _textView;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {// return key
        [textView resignFirstResponder];
        return false;
    }
    return true;
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        _placeLabel.text = @"请输入答案...";
    }else{
        _placeLabel.text = @"";
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    _question.inputAnswer = [textView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

@end
