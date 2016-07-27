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

@implementation PaperDataManager
{
    NSString *paperSavePath;
    NSString *paperDownloadPath;
}

-(instancetype)init{
    if (self = [super init]) {
        paperDownloadPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/paperZips"];
        paperSavePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/paperPlists"];
        [self createDirectoryAtPath:paperDownloadPath];
        [self createDirectoryAtPath:paperSavePath];
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

-(PaperModel *)loadPaperWithPaperId:(NSString *)paperId{
    NSFileManager *m = [NSFileManager defaultManager];
    NSString *path = [self paperPlistPathWithId: paperId];
    if ([m fileExistsAtPath: path]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        PaperModel *paper = [[PaperModel alloc]initWithDict: dict[@"root"]];
        return paper;
    }
    return nil;
}

-(NSString*)paperPlistPathWithId: (NSString*)paperId{
    return [NSString stringWithFormat:@"%@/paper_%@.plist",paperSavePath,paperId];
}

-(void)downloadPaperWithParam:(PaperParam *)param
                      succeed:(DownloadPaperSucceedBlock)succeedBlock
                     finished:(PaperRequestFinishedBlock)finishedBlock
                       failed:(PaperRequestFailedBlock)failedBlock{
    
    [self createDirectoryAtPath:paperSavePath];
    
    NSString *paraUrl = [NSString stringWithFormat:@"status=%@&paperId=%@&userId=%@&uuid=&quiz_id=%@",param.status, param.simulate_exam_result_id ,param.user_id, param.quizid];
    NSString *paperUrl = [NSString stringWithFormat:@"http://172.19.43.127:8080/tqmsapp/app/homework/api/getHomeworkResulttwo.do?%@",paraUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString: paperUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"url: %@",URL);
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath: paperDownloadPath];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            failedBlock(error);
        }
        else{
            NSLog(@"File downloaded to: %@", filePath.path);
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


-(void)parsePaperZipWithFilePath:(NSString*)filePath
                           Param:(PaperParam*)param
                         succeed:(DownloadPaperSucceedBlock)succeedBlock
                        finished:(PaperRequestFinishedBlock)finishedBlock
                          failed:(PaperRequestFailedBlock)failedBlock{
    
    __weak __typeof(self) weakSelf = self;
    [SSZipArchive unzipFileAtPath: filePath toDestination: paperDownloadPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nonnull error) {
        if (error) {
            failedBlock(error);
        }
        else{
            NSData *data = [NSData dataWithContentsOfFile: [paperDownloadPath stringByAppendingString:@"/paper.XML"]];
            NSError *error = nil;
            NSDictionary *dict = [XMLReader dictionaryForXMLData:data
                                                         options:XMLReaderOptionsProcessNamespaces
                                                           error:&error];
            NSString *path = [self paperPlistPathWithId: param.simulate_exam_result_id];
            if (dict && [dict writeToFile: path atomically:true]) {
                PaperModel *paper = [self loadPaperWithPaperId: param.simulate_exam_result_id];
                NSLog(@"paper: %@",paper);
                succeedBlock(paper);
                
                // 删除zip
                [weakSelf removeDirectoryAtPath:paperDownloadPath];
            }
        }
        finishedBlock();
    }];
}

-(void)createDirectoryAtPath: (NSString*)path{
    NSError *error;
    BOOL isDirectory;
    NSFileManager *m = [NSFileManager defaultManager];
    [m removeItemAtPath:path error:&error];
    if (![m fileExistsAtPath:path isDirectory:&isDirectory]) {
        [m createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:&error];
        if (error) {
            NSLog(@"createDirectoryAtPath error: %@",error.localizedDescription);
        }
    }
}

-(void)removeDirectoryAtPath: (NSString*)path{
    NSError *error;
    NSFileManager *m = [NSFileManager defaultManager];
    [m removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"removeDirectoryAtPath error: %@",error.localizedDescription);
    }
}

@end
