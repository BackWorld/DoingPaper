//
//  PaperItem.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperItem.h"
#import "PaperQuestion.h"

@implementation PaperItem

-(instancetype)initWithDict: (NSDictionary*)dict{
    if (self = [super init]) {
        _questions = [NSMutableArray new];
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"type_name"]) {
        _typeName = value;
    }
    else if([key isEqualToString:@"question"]){
        for (NSDictionary *dict in value) {
            PaperQuestion *q = [[PaperQuestion alloc]initWithDict:dict];
            [_questions addObject:q];
        }
    }
}

@end
