//
//  PaperParam.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaperParam : NSObject

/*
 int status,
 String uuid,
 String userId,
 String usedTime,
 String authToken,
 String quiz_id ，
 resultContent 文件名，
 parent_id，
 projeck_host
 */

/*
dic:
{
"parent_id" = "568D0276-799B-96E5-7F78-7B41C668DBFE";
"projeck_host" = "http://172.19.42.53:8509";
quizid = "9303620D-0287-243B-28A1-300FB890A541";
role = student;
"simulate_exam_result_id" = 112002;
status = 0;
"user_id" = "FAB464C8-5256-6122-BA85-C4E19612CFC5";
}
*/

@property(nonatomic,strong)NSString *user_id;
@property(nonatomic,strong)NSString *parent_id;
@property(nonatomic,strong)NSString *projeck_host;
@property(nonatomic,strong)NSString *quizid;
@property(nonatomic,strong)NSString *simulate_exam_result_id;
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *uuid; //学生，教师查看试卷时用

@property(nonatomic,assign)BOOL submited;
@property(nonatomic,assign)BOOL isTeacher;
@end
