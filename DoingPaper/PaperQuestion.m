//
//  PaperQuestion.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperQuestion.h"

@implementation PaperQuestion

-(instancetype)init{
    if (self = [super init]) {
        _optionSelectedIndex = -1;
        _scores = @[@"0%",@"20%",@"40%",@"60%",@"80%",@"100%"];
        _scoreMarkedIndex = -1;
        _options = [NSMutableArray new];
        _inputAnswer = @"";
    }
    return self;
}

-(instancetype)initWithDict: (NSDictionary*)dict{
    if (self = [self init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+(PaperQuestion *)quickBuild{
    PaperQuestion *q = [PaperQuestion new];
    q.url = @"http://www.baidu.com";
    q.options = [NSMutableArray arrayWithArray:@[@"A、",@"B、",@"C、",@"D、"]];
    return q;
}

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"options"]) {
        for (NSDictionary *dict in value[@"option"]) {
            NSString *name = [NSString stringWithFormat:@"%@、%@",dict[@"optionIndex"], dict[@"text"]];
            [_options addObject: name];
        }
        return; // WARN
    }
    [super setValue:value[@"text"] forKey:key];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}

@end
