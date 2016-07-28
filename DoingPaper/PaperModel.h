//
//  PaperModel.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaperModel : NSObject
/*
 <papertitle>2009年普通高等学校招生全国统一考试 数学(理工农医类)(北京卷)</papertitle>
 <papertime>null</papertime>
 <paperscore>60.0</paperscore>
 <paperauthor>海尔老师2</paperauthor>
 <uuid>9303620D-0287-243B-28A1-300FB890A541</uuid>
 */

@property(nonatomic,strong)NSString *usedTime; // 答题所用时间
@property(nonatomic,strong)NSString* paperId; // _param.
@property(nonatomic,strong)NSString* title;
@property(nonatomic,strong)NSString* titme;
@property(nonatomic,strong)NSString* score;
@property(nonatomic,strong)NSString* author;
@property(nonatomic,strong)NSString* uuid;
@property(nonatomic,strong)NSMutableArray *items;
@property(nonatomic,assign,readonly)NSUInteger totalQuestionsCount;

-(instancetype)initWithDict: (NSDictionary*)dict;

@end
