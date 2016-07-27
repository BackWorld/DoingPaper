//
//  PaperQuestion.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    SingleSelect = 0, // 单选
    MultiSelect = 1, // 多选
    TianKong = 2, // 填空
    JianDa = 3, // 简答
} PaperQuestionType;


@interface PaperQuestion : NSObject

/*
 <orderid>1</orderid>
 <qstId>111979</qstId>
 <tqId>3</tqId>
 <qtype>1</qtype>
 <typeId>82714</typeId>
 <time>3</time>
 <score>3</score>
 <difficultId>82707</difficultId>
 <difficultName>四星</difficultName>
 <categoryId>92500</categoryId>
 <categoryName>复数</categoryName>
 <parentid>0</parentid>
 <has_sub>0</has_sub>
 <questionContent>...</questionContent>
 <answer>B</answer>
 <analysis>...</analysis>
 <options>...</options>
 */

@property(nonatomic,strong)NSString * orderid;
@property(nonatomic,strong)NSString * qstId;
@property(nonatomic,strong)NSString * tqId;
@property(nonatomic,strong)NSString * typeId;
@property(nonatomic,strong)NSString * parentid;
@property(nonatomic,strong)NSString * time;
@property(nonatomic,strong)NSString * score;
@property(nonatomic,strong)NSString * difficultId;
@property(nonatomic,strong)NSString * difficultName;
@property(nonatomic,strong)NSString * categoryId;
@property(nonatomic,strong)NSString * categoryName;
@property(nonatomic,strong)NSString * has_sub;
@property(nonatomic,strong)NSString * answer;
@property(nonatomic,strong)NSString * analysis;
@property(nonatomic,strong)NSString * questionContent;
@property(nonatomic,strong)NSMutableArray *options; // 选项s

// custom props
@property(nonatomic,strong)NSString *url;
@property(nonatomic,assign)NSInteger optionSelectedIndex; // 选择的选项
@property(nonatomic,assign)NSInteger scoreMarkedIndex; //评分
@property(nonatomic,strong,readonly)NSArray *scores;
@property(nonatomic,strong)NSString *inputAnswer; //输入的答案
@property(nonatomic,assign)BOOL isTeacher;

-(instancetype)initWithDict: (NSDictionary*)dict;

@end
