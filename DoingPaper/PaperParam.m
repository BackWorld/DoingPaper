//
//  PaperParam.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperParam.h"

@implementation PaperParam

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"status"]) {
        _submited = ([value isEqualToString:@"1"] || [value isEqualToString:@"2"]) ? true : false;
    }
    [super setValue:value forKey:key];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"role"] && [value isEqualToString:@"teacher"]) {
        _isTeacher = true;
    }
}

@end
