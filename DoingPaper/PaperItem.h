//
//  PaperItem.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaperItem : NSObject

@property(nonatomic,strong)NSString *typeName;
@property(nonatomic,strong)NSMutableArray *questions;

-(instancetype)initWithDict: (NSDictionary*)dict;

@end
