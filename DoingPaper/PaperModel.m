//
//  PaperModel.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperModel.h"
#import "PaperItem.h"

@implementation PaperModel

-(instancetype)init{
    if (self = [super init]) {
        _items = [NSMutableArray new];
    }
    return self;
}

-(instancetype)initWithDict: (NSDictionary*)dict{
    if (self = [super init]) {
        _items = [NSMutableArray new];
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"papersource"]) {
        _author = value[@"paperauthor"][@"text"];
        _score = value[@"paperscore"][@"text"];
        _titme = value[@"papertime"][@"text"];
        _title = value[@"papertitle"][@"text"];
        _uuid = value[@"uuid"][@"text"];
    }
}

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"questions"]) {
        for (NSDictionary *dict in value[@"type"]) {
            PaperItem *item = [[PaperItem alloc]initWithDict:dict];
            [_items addObject:item];
        }
    }
    [super setValue:value forKey:key];
}

-(NSUInteger )totalQuestionsCount{
    NSUInteger i = 0;
    for (PaperItem *item in _items) {
        i += item.questions.count;
    }
    return i;
}

@end
