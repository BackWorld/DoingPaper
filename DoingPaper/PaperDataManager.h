//
//  PaperDataManager.h
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperParam.h"
#import "PaperModel.h"

typedef void(^DownloadPaperSucceedBlock)(PaperModel* paper);
typedef void(^PaperRequestSucceedBlock)(void);
typedef void(^PaperRequestFinishedBlock)(void);
typedef void(^PaperRequestFailedBlock)(NSError* error);

@interface PaperDataManager : NSObject

+(PaperDataManager*)sharedManager;


// http://172.19.43.127:8080/tqmsapp/app/homework/api/getHomeworkResulttwo.do?status=0&paperId=112002&userId=FAB464C8-5256-6122-BA85-C4E19612CFC5&uuid=&quiz_id=9303620D-0287-243B-28A1-300FB890A541
// 加载试卷
-(PaperModel*)loadPaperWithPaperId: (NSString *)paperId; //本地

-(void)getPaperWithParam: (PaperParam *)param
                      succeed: (DownloadPaperSucceedBlock)succeedBlock
                     finished: (PaperRequestFinishedBlock)finishedBlock
                       failed: (PaperRequestFailedBlock) failedBlock;

// 查看答题结果
-(void)scanPaperWithSubmitedPaper:(PaperModel*)paper
                            Param:(PaperParam *)param
                          succeed:(PaperRequestSucceedBlock)succeedBlock
                         finished:(PaperRequestFinishedBlock)finishedBlock
                           failed:(PaperRequestFailedBlock)failedBlock;

// 提交试卷
-(void)submitPaperAnwserWithPaper:(PaperModel *)paper
                       PaperParam:(PaperParam *)param
                          succeed:(PaperRequestSucceedBlock)succeedBlock
                         finished:(PaperRequestFinishedBlock)finishedBlock
                           failed:(PaperRequestFailedBlock)failedBlock;
// 添加评语
-(void)teacherSendCommentWithText: (NSString*)comment
                       PaperParam: (PaperParam*)param
                          succeed:(PaperRequestSucceedBlock)succeedBlock
                         finished:(PaperRequestFinishedBlock)finishedBlock
                           failed:(PaperRequestFailedBlock)failedBlock;

@end
