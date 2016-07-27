//
//  DoingPaperMainController.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoingPaperMainController : UIViewController

@property(nonatomic,strong)NSIndexPath *currentIndexPath;
// functions
-(instancetype)initWithParams: (NSDictionary*)dict;
-(void)scrollToNextQuestionPage;
-(BOOL)isTeacher;

@end
