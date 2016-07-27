//
//  PaperItemCellTableView.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperItemCellTableView.h"
#import "PaperSingleSelectionCell.h"
#import "PaperQuestionWebCell.h"
#import "PaperMarkScoreFooter.h"
#import "DoingPaperMainController.h"
#import "PaperInputSelectionCell.h"


@interface PaperItemCellTableView() <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,assign)CGFloat webCellH;

@end

@implementation PaperItemCellTableView
{
    NSIndexPath *lastSelectedCellIndexPath;
    DoingPaperMainController *mainVC;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        _webCellH = 80; // 默认值
        mainVC = [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers[0];
        self.backgroundColor = [UIColor greenColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (mainVC.isTeacher) {
            self.allowsSelection = false;
        }
        
        [self registerClass:[PaperSingleSelectionCell class] forCellReuseIdentifier:@"PaperSingleSelectionCell"];
        [self registerClass:[PaperQuestionWebCell class] forCellReuseIdentifier:@"PaperQuestionWebCell"];
        [self registerClass:[PaperInputSelectionCell class] forCellReuseIdentifier:@"PaperInputSelectionCell"];
        
        // 添加通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(webCellDidLoadNoti:) name:@"PaperWebDidLoadNotification" object:nil];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

-(void)endEditing{
    self.editing = false;
}

// webview did load noti
-(void)webCellDidLoadNoti: (NSNotification*)noti{
    self.webCellH = [noti.userInfo[@"PaperWebDidLoadHeightKey"] floatValue];
}

-(void)setQuestion:(PaperQuestion *)question{
    _question = question;
    [self reloadData];
}

// set webCellH
-(void)setWebCellH:(CGFloat)webCellH{
    [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    _webCellH = webCellH;
}

#pragma mark UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 80;//_webCellH;
    }
    NSInteger count = _question.options.count;
    if (count > 0) {
        return 44;
    }
    return 200; // 非选择题选项
}

-(NSInteger)numberOfSections{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = _question.options.count;
    if (count > 0) {
        return count + 1;
    }
    return 2; //1 + 1非选择题
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (mainVC.isTeacher && _question.options.count == 0) { // 教师，且为非单选题
        return 44;
    }
    return 0; // 学生
}

// footer view
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    PaperMarkScoreFooter *footer = [[PaperMarkScoreFooter alloc]initWithPaperQuestion:_question];
    return footer;
}

-(void)paperMarkScoreFooterDidScore:(float)score selectedBtnIndex:(NSInteger)index{
    NSLog(@"score: %f, index: %ld",score,index);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        PaperQuestionWebCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaperQuestionWebCell" forIndexPath:indexPath];
        cell.url = _question.url;
        return cell;
    }
    // 输入答案的题
    if (_question.options.count == 0) {
        PaperInputSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaperInputSelectionCell" forIndexPath:indexPath];
        cell.question = _question;
        return cell;
    }
    
    // 单选题
    PaperSingleSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaperSingleSelectionCell" forIndexPath:indexPath];
    cell.selectionName = _question.options[indexPath.row-1]; // 记得-1
    if (indexPath.row == _question.optionSelectedIndex) { // 选中的选项
        cell.choosed = true;
        lastSelectedCellIndexPath = indexPath;
    }
    else{
        cell.choosed = false;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return;
    }
    if (lastSelectedCellIndexPath) {
        PaperSingleSelectionCell *lastCell = [tableView cellForRowAtIndexPath:lastSelectedCellIndexPath];
        lastCell.choosed = false;
    }
    // 选中项
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    PaperSingleSelectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.choosed = true;
    _question.optionSelectedIndex = indexPath.row;
    lastSelectedCellIndexPath = indexPath;
    
    // 下一页
    [mainVC scrollToNextQuestionPage];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
