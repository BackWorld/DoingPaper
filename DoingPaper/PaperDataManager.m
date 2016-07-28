//
//  PaperDataManager.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/26.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperDataManager.h"
#import "PaperModel.h"
#import <AFNetworking/AFNetworking.h>
#import <ZipArchive/ZipArchive.h>
#import "XMLReader.h"
#import "PaperItem.h"
#import "PaperQuestion.h"

@interface PaperDataManager()

@property(nonatomic,strong)NSString *paperDownloadPath;

@end

@implementation PaperDataManager
{
    NSString *paperSavePath;
    NSString *userAnswerPath;
}

-(instancetype)init{
    if (self = [super init]) {
        _paperDownloadPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/paperZips"];
        paperSavePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/paperPlists"];
        userAnswerPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/userAnswers"];
        [self createDirectoryAtPath:paperSavePath];
        [self createDirectoryAtPath:userAnswerPath];
    }
    return self;
}

+(PaperDataManager*)sharedManager{
    static PaperDataManager* manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [PaperDataManager new];
    });
    return manager;
}

// getters
-(NSString *)paperDownloadPath{
    [self createDirectoryAtPath:_paperDownloadPath];
    return _paperDownloadPath;
}

// 加载试卷
-(PaperModel *)loadPaperWithPaperId:(NSString *)paperId{
    NSString *path = [self paperPlistPathWithId: paperId];
    if ([self fileExists:path]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        PaperModel *paper = [[PaperModel alloc]initWithDict: dict[@"root"]];
        return paper;
    }
    return nil;
}

// 外部接口，实现用户已提交试题和答案的绑定
-(void)scanPaperWithSubmitedPaper:(PaperModel*)paper
                             Param:(PaperParam *)param
                           succeed:(PaperRequestSucceedBlock)succeedBlock
                          finished:(PaperRequestFinishedBlock)finishedBlock
                            failed:(PaperRequestFailedBlock)failedBlock{
    NSString *path = [self userAnswerJsonPathWithId: paper.paperId];
    if ([self fileExists:path]) {
        [self parseUserAnswerAndScoreRateFromPath:path paper:paper succeed:succeedBlock finished:finishedBlock];
    }
    else{
        [self getUserAnswerWithPaper:paper Param:param succeed:succeedBlock finished:finishedBlock failed:failedBlock];
    }
}

// 试卷plist
-(NSString*)paperPlistPathWithId: (NSString*)paperId{
    return [NSString stringWithFormat:@"%@/paper_%@.plist",paperSavePath,paperId];
}
// 用户答案json
-(NSString*)userAnswerJsonPathWithId: (NSString*)paperId{
    return [NSString stringWithFormat:@"%@/answer_%@.json",userAnswerPath,paperId];
}
// 用户答案zip
-(NSString*)userAnswerZipPathWithId: (NSString*)paperId{
    return [NSString stringWithFormat:@"%@/answer_%@.zip",userAnswerPath,paperId];
}

// 或得用户答案
-(void)getUserAnswerWithPaper:(PaperModel*)paper
                          Param:(PaperParam *)param
                        succeed:(PaperRequestSucceedBlock)succeedBlock
                       finished:(PaperRequestFinishedBlock)finishedBlock
                         failed:(PaperRequestFailedBlock)failedBlock{

    NSString *url = [NSString stringWithFormat:@"http://172.19.42.53:7777/tqmsapp/app/homework/api/getUserExamResultNew.do?userId=%@&uuid=%@",param.user_id,param.uuid];
    NSLog(@"answer url: %@",url);
    
    NSURL *URL = [NSURL URLWithString: url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *path = [NSURL fileURLWithPath: weakSelf.paperDownloadPath];
        return [path URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failedBlock(error);
        }
        else{
            [weakSelf parseAnswerZipWithFilePath:filePath.path
                                           paper:paper Param:param
                                         succeed:succeedBlock
                                        finished:finishedBlock
                                          failed:failedBlock];
        }
    }];
    [task resume];
}

// 解压答案
-(void)parseAnswerZipWithFilePath:(NSString*)filePath
                          paper:(PaperModel*)paper
                            Param:(PaperParam*)param
                         succeed:(PaperRequestSucceedBlock)succeedBlock
                        finished:(PaperRequestFinishedBlock)finishedBlock
                          failed:(PaperRequestFailedBlock)failedBlock{
    __weak __typeof(self) weakSelf = self;
    [SSZipArchive unzipFileAtPath:filePath toDestination: userAnswerPath overwrite:true password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
        if (error) {
            failedBlock(error);
        }
        else{
            path = [userAnswerPath stringByAppendingString:@"/answer.json"];
            [weakSelf parseUserAnswerAndScoreRateFromPath:path
                                                   paper:paper
                                                 succeed:succeedBlock
                                                 finished:finishedBlock];
        }
    }];
}

// 数据深层次解析
-(void)parseUserAnswerAndScoreRateFromPath:(NSString*)path
                                        paper:(PaperModel*)paper
                                   succeed:(PaperRequestSucceedBlock)succeedBlock
                                  finished:(PaperRequestFinishedBlock)finishedBlock
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        NSLog(@"read answer.json to data is failed");
        return;
    }
    NSArray *answers = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers error:nil];
    for (NSDictionary *dict in answers)
    {
        for (PaperItem *item in paper.items) {
            for (PaperQuestion *q in item.questions) {
                NSString *userAnswer = dict[@"userAnswer"];
                if (q.options.count > 0 && ![userAnswer isEqualToString:@""]) { //选择题
                    for (int i=0; i<q.options.count; i++) {
                        if ([q.options[i] isEqualToString:userAnswer]) {
                            q.optionSelectedIndex = i;
                            break;
                        }
                    }
                }
                else{ //输入题
                    q.inputAnswer = dict[@"userAnswer"];
                }
                // 评分
                NSString *score = dict[@"userScoreRate"];
                if (![score isEqualToString:@""]) {
                    for (int i=0; i<q.scores.count; i++) {
                        if ([q.scores[i] isEqualToString:score]) {
                            q.scoreMarkedIndex = i;
                            break;
                        }
                    }
                }
            }
        }
        
    } //outside for loop end
    
    // 删除zips
    [self removeDirectoryAtPath:_paperDownloadPath];

    NSString *toPath = [self userAnswerJsonPathWithId:paper.paperId];
    if (![self fileExists: toPath]) {
        [self moveFileAtFilePath:path toPath:toPath deleteOriginalFile:true];
        NSLog(@"answer saved to: %@", toPath);
    }
    finishedBlock();
    succeedBlock();
}



// 下载试题
-(void)getPaperWithParam:(PaperParam *)param
                      succeed:(DownloadPaperSucceedBlock)succeedBlock
                     finished:(PaperRequestFinishedBlock)finishedBlock
                       failed:(PaperRequestFailedBlock)failedBlock{
    
    [self createDirectoryAtPath:paperSavePath];
    
    NSString *paraUrl = [NSString stringWithFormat:@"status=%@&paperId=%@&userId=%@&uuid=&quiz_id=%@",param.status, param.simulate_exam_result_id ,param.user_id, param.quizid];
    NSString *paperUrl = [NSString stringWithFormat:@"http://172.19.42.53:7777/tqmsapp/app/homework/api/getHomeworkResulttwo.do?%@",paraUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString: paperUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"url: %@",URL);
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *path = [NSURL fileURLWithPath: weakSelf.paperDownloadPath];
        return [path URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            failedBlock(error);
        }
        else{
            // 解析数据
            [weakSelf parsePaperZipWithFilePath:filePath.path
                                          Param:param
                                        succeed:succeedBlock
                                       finished:finishedBlock
                                         failed:failedBlock];
        }
    }];
    [downloadTask resume];
}

// 解压并解析试题
-(void)parsePaperZipWithFilePath:(NSString*)filePath
                           Param:(PaperParam*)param
                         succeed:(DownloadPaperSucceedBlock)succeedBlock
                        finished:(PaperRequestFinishedBlock)finishedBlock
                          failed:(PaperRequestFailedBlock)failedBlock{
    
    __weak __typeof(self) weakSelf = self;
    [SSZipArchive unzipFileAtPath: filePath toDestination: self.paperDownloadPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
        if (error) {
            failedBlock(error);
        }
        else{
            NSData *data = [NSData dataWithContentsOfFile: [weakSelf.paperDownloadPath stringByAppendingString:@"/paper.XML"]];
            NSError *error = nil;
            NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                         options:XMLReaderOptionsProcessNamespaces
                                                           error:&error];
            NSString *path = [self paperPlistPathWithId: param.simulate_exam_result_id];
            if (dict && [dict writeToFile: path atomically:true]) {
                PaperModel *paper = [self loadPaperWithPaperId: param.simulate_exam_result_id];
                NSLog(@"paper: %@",paper);
                succeedBlock(paper);
                
                // 删除zips
                [weakSelf removeDirectoryAtPath:_paperDownloadPath];
                
                NSLog(@"paper saved to: %@", path);
            }
        }
        finishedBlock();
    }];
}

// 交卷
-(void)submitPaperAnwserWithPaper:(PaperModel *)paper
                       PaperParam:(PaperParam *)param
                          succeed:(PaperRequestSucceedBlock)succeedBlock
                         finished:(PaperRequestFinishedBlock)finishedBlock
                           failed:(PaperRequestFailedBlock)failedBlock{
    
    NSString *path = [self getUserAnswersZipFilePath: paper];
    if (!path) {
        NSError *error = [NSError errorWithDomain:@"没有找到答题记录" code:404 userInfo:nil];
        failedBlock(error);
        return;
    }
    // 向服务器提交数据
    
    NSDictionary *paramDict = @{
                                 @"status": @"1",
                                 @"uuid": paper.uuid,
                                 @"userId": param.user_id,
                                 @"usedTime": paper.usedTime,
                                 @"authToken": @"",
                                 @"quiz_id": param.quizid,
                                 @"parent_id": param.parent_id,
                                 @"projeck_host": param.projeck_host,
                                 @"resultContent": path
                            };
    NSLog(@"url: http://172.19.42.53:7777/tqmsapp/app/homework/api/submitResult.do\n parameters: %@",paramDict);
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://172.19.42.53:7777/tqmsapp/app/homework/api/submitResult.do" parameters:paramDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath: path] name:@"answer" fileName:@"userAnswer.zip" mimeType:@"application/zip" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
      progress:^(NSProgress * _Nonnull uploadProgress) {
      }
      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
          if (error) {
              failedBlock(error);
          }
          else {
              NSLog(@"%@ %@", response, responseObject);
              // 删除zip
              [self removeDirectoryAtPath:path];
              succeedBlock();
          }
          NSLog(@"%@ %@", response, responseObject);
          finishedBlock();
    }];
    [uploadTask resume];
}

// paper model to json and zip it
-(NSString *)getUserAnswersZipFilePath: (PaperModel*)paper{
    NSMutableArray *answers = [NSMutableArray new];
    for (PaperItem *item in paper.items) {
        for (PaperQuestion *q in item.questions) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict[@"standardAnswer"] = q.answer;
            dict[@"subCount"] = q.has_sub;
            dict[@"qstId"] = q.qstId;
            if (q.optionSelectedIndex != -1) { //说明重写了，有选中
                NSString *userOption = q.options[q.optionSelectedIndex];
                dict[@"userAnswer"] = userOption;
                dict[@"resultFlag"] = ([q.answer isEqualToString: userOption]) ? @"1" : @"0";
            }
            else{
                dict[@"userAnswer"] = (q.inputAnswer) ? q.inputAnswer : @"";
                dict[@"resultFlag"] = @"0";
            }
            dict[@"parentId"] = q.parentid;
            dict[@"viewTypeId"] = q.qtype;
            dict[@"tqId"] = q.tqId;
            dict[@"userScoreRate"] = @"0%";
            [answers addObject:dict];
        }
    }
//    NSLog(@"answers: %@",answers);
    NSString *jsonStr = [self objectToJson: answers];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *path = [self userAnswerJsonPathWithId: paper.paperId];
    NSString *zipPath = [self userAnswerZipPathWithId:paper.paperId];
    BOOL writed = [data writeToFile:path  atomically:true];
    BOOL ziped = [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[path]];
    if (writed && ziped) {
        // 删除json
        [self removeDirectoryAtPath:path];
        // zip
        NSLog(@"answer for submit ziped to: %@",zipPath);
        return zipPath;
    }
    return nil;
}

// 文件是否存在
-(BOOL)fileExists: (NSString*)path{
    BOOL isDirectory;
    NSFileManager *m = [NSFileManager defaultManager];
    return [m fileExistsAtPath:path isDirectory:&isDirectory];
}

// 重命名
-(void)moveFileAtFilePath: (NSString*)path
                   toPath: (NSString*)toPath
       deleteOriginalFile: (BOOL)delete{
    NSError *error;
    NSFileManager *m = [NSFileManager defaultManager];
    if ([self fileExists:path]) {
        [self removeDirectoryAtPath:toPath]; // 移除已有的
        
        [m moveItemAtPath: path toPath:toPath error:&error];
        if (error) {
            NSLog(@"renameFileAtPath error: %@",error.localizedDescription);
            return;
        }
        // delete
        if (delete) {
            [self removeDirectoryAtPath:path];
        }
        return;
    }
    NSLog(@"renameFileAtPath: file is not exists %@",path);
}

-(NSString *)objectToJson:(id)object{
    NSError *error;
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    NSLog(@"error------jsonObject is not  Valid!");
    return nil;
}

-(void)createDirectoryAtPath: (NSString*)path{
    NSError *error;
    NSFileManager *m = [NSFileManager defaultManager];
    if (![self fileExists:path]) {
        [m createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:&error];
        if (error) {
            NSLog(@"createDirectoryAtPath error: %@",error.localizedDescription);
        }
    }
}

-(void)removeDirectoryAtPath: (NSString*)path{
    NSError *error;
    NSFileManager *m = [NSFileManager defaultManager];
    if ([self fileExists:path]) {
        [m removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"removeDirectoryAtPath error: %@",error.localizedDescription);
        }
    }
}

@end
