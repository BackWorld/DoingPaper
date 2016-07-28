//
//  DoingPaperMainController.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "DoingPaperMainController.h"
#import "PaperItemCell.h"
#import "ImageTitleButton.h"
#import "PaperParam.h"
#import "PaperItem.h"
#import "PaperModel.h"
#import "PaperDataManager.h"

@interface DoingPaperMainController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic,strong)UICollectionView* collectionView;
@property(nonatomic,strong)UIView *headView;
// 答题用时
@property(nonatomic,assign)NSInteger totalUsedTime;
@property(nonatomic,strong)PaperParam *param;
@property(nonatomic,strong)PaperModel *paper;

@end

@implementation DoingPaperMainController
{
    CGFloat screenW;
    CGFloat screenH;
    CGFloat headViewH;
    UILabel *indexLabel;
    UILabel *timeLabel;
    UILabel *questionTypeLabel;
}

-(instancetype)initWithParams: (NSDictionary*)dict{
    if (self = [super init]) {
        _paper = [PaperModel new];
        dict = @{
            @"parent_id": @"568D0276-799B-96E5-7F78-7B41C668DBFE",
            @"projeck_host": @"http://172.19.42.53:8509",
            @"quizid": @"9303620D-0287-243B-28A1-300FB890A541",
            @"role": @"student",
            @"simulate_exam_result_id": @"112002",
            @"status":  @"1",
            @"user_id": @"EFDD8B11-3038-137A-0217-C8BCF9D1D384",
            @"uuid": @"0BD17A83-87C2-0308-3B50-201075BFBDB5"
        };
        _param = [PaperParam new];
        [_param setValuesForKeysWithDictionary: dict];
        screenW = [UIScreen mainScreen].bounds.size.width;
        screenH = [UIScreen mainScreen].bounds.size.height;
        headViewH = 44;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self loadPaper];
}

-(void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // nav
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"答题卡" style:UIBarButtonItemStylePlain target:self action:@selector(loadPaper)];
    
    [self.view addSubview: self.headView]; // 手动调用 self.才行而不能 _headView
    [self.view addSubview: self.collectionView];
    
    // bottom tool bar
    [self setupToolbar];
}

-(BOOL)canBecomeFirstResponder{
    return true;
}

-(void)setupToolbar{
    self.navigationController.toolbarHidden = false;
    UIToolbar *toolBar = self.navigationController.toolbar;
    toolBar.translucent = false;
    toolBar.barTintColor = [UIColor darkGrayColor];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (_param.isTeacher) {
        self.toolbarItems = @[flexItem, [self toolbarItemWithTitle:@"点评" iconName:@"icon_toolbar_comment" action:@selector(sendComment)]];
        return;
    }
    self.toolbarItems = @[flexItem, [self toolbarItemWithTitle:@"交卷" iconName:@"icon_toolbar_submit" action:@selector(submitPaper)]];
}

-(UIBarButtonItem*)toolbarItemWithTitle: (NSString*)title iconName: (NSString*)icon action: (SEL)action{
    ImageTitleButton *btn = [[ImageTitleButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44) imageName:@"icon_toolbar_submit" title:@"交卷"];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc]initWithCustomView: btn];
}

-(void)setPaper:(PaperModel *)paper{
    if (paper) {
        self.navigationItem.title = paper.title;
        _paper = paper;
        _paper.paperId = _param.simulate_exam_result_id;
        
        if (_param.submited) { //加载答案
            [self scanPaper];
        }
        else{
            [self.collectionView reloadData];
        }
        self.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
}

// setters
-(void)setCurrentIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item + 1;
    if (indexPath && section < _paper.items.count) {
        for (int i=0; i<section; i++) {
            item += [_paper.items[i] questions].count; //垒加
        }
        indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", item, _paper.totalQuestionsCount];
        [_collectionView scrollToItemAtIndexPath: indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:true];
        
        // cell结束编辑
        [self becomeFirstResponder];
        
        _currentIndexPath = indexPath;
    }
//    NSLog(@"item: %ld",item);
}

#pragma mark 懒加载
-(UIView *)headView{
    if (!_headView) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenW, headViewH)];
        view.backgroundColor = [UIColor lightGrayColor];
        
        // 左边显示当前第几题 1/3
        indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, headViewH)];
        indexLabel.text = @"0/0";
        
        // 右边计时label
        timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenW-100, 0, 100, headViewH)];
        timeLabel.text = @"00:00:00";
        
        // 题型label
        questionTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2 - 50, 0, 100, headViewH)];
        questionTypeLabel.text = @"单选题";
        questionTypeLabel.textAlignment = NSTextAlignmentCenter;
        
        [view addSubview:indexLabel];
        [view addSubview:timeLabel];
        [view addSubview:questionTypeLabel];
        
        _headView = view;
    }
    
    return _headView;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        CGRect frame = CGRectMake(0, headViewH, screenW, screenH - headViewH-20);
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = frame.size;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.pagingEnabled = true;
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.backgroundColor = [UIColor whiteColor];
        [collectionView registerClass:[PaperItemCell class] forCellWithReuseIdentifier:@"PaperItemCell"];
        
        _collectionView = collectionView;
    }
    
    return _collectionView;
}

/**
 *  答完题浏览
 */
-(void)scanPaper{
    __weak typeof(self) weakSelf = self;
    [[PaperDataManager sharedManager]scanPaperWithSubmitedPaper:_paper Param:_param succeed:^{
        [weakSelf.collectionView reloadData];
    } finished:^{
        
    } failed:^(NSError *error) {
        NSLog(@"get answer error: %@",error.localizedDescription);
    }];
}

/**
 *  加载试题
 */
-(void)loadPaper{
    PaperModel *paper = [[PaperDataManager sharedManager] loadPaperWithPaperId:_param.simulate_exam_result_id];
    if (paper) {
        self.paper = paper;
    }
    else{
        [self initPaper];
    }
}

/**
 *  网络获取试题
 */
-(void)initPaper{
    __weak typeof(self) weakSelf = self;
    [[PaperDataManager sharedManager]getPaperWithParam:_param succeed:^(PaperModel *paper) {
        weakSelf.paper = paper;
    } finished:^{
        NSLog(@"finished");
    } failed:^(NSError *error) {
        NSLog(@"error: %@",error.localizedDescription);
    }];
}

/**
 *  交卷
 */
-(void)submitPaper{
    // 停止计时
    _paper.usedTime = [NSString stringWithFormat:@"%ld",_totalUsedTime];
    [[PaperDataManager sharedManager]submitPaperAnwserWithPaper: _paper PaperParam: _param succeed:^{
        NSLog(@"交卷成功");
    } finished:^{
        
    } failed:^(NSError *error) {
        NSLog(@"error: %@", error.localizedDescription);
    }];
}

/**
 *  评语
 */
-(void)sendComment{
    
}

#pragma mark - UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _paper.items.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    PaperItem *item = _paper.items[section];
    return item.questions.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PaperItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PaperItemCell" forIndexPath:indexPath];
    PaperItem *item = _paper.items[indexPath.section];
    cell.question = item.questions[indexPath.item];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat x = scrollView.contentOffset.x + _collectionView.center.x;
    CGFloat y = _collectionView.center.y;
    CGPoint point = CGPointMake(x, y);
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if (indexPath && indexPath != _currentIndexPath) {
        self.currentIndexPath = indexPath;
//        NSLog(@"point: %@ - item: %ld - section: %ld",NSStringFromCGPoint(point),indexPath.item,indexPath.section);
    }
}

// scroll to next
-(void)scrollToNextQuestionPage{
    CGFloat x = _collectionView.contentOffset.x + _collectionView.center.x + CGRectGetWidth(self.collectionView.bounds);
    CGFloat y = _collectionView.center.y;
    CGPoint point = CGPointMake(x, y);
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if (indexPath) {
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:true];
    }
}

-(BOOL)isTeacher{
    return _param.isTeacher;
}

@end
