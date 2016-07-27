//
//  PaperItemCellWebView.m
//  DoingPaper
//
//  Created by zhuxuhong on 16/7/25.
//  Copyright © 2016年 zhuxuhong. All rights reserved.
//

#import "PaperQuestionWebCell.h"

@interface PaperQuestionWebCell() <UIWebViewDelegate>

@property(nonatomic,strong)UIWebView *webView;

@end

@implementation PaperQuestionWebCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.webView];
    }
    return self;
}

// getter
-(UIWebView *)webView{
    if (!_webView) {
        UIWebView *web = [[UIWebView alloc]initWithFrame: CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 80)];
        web.scrollView.scrollEnabled = false;
        web.delegate = self;
        _webView = web;
    }
    return _webView;
}

// setter
-(void)setUrl:(NSString *)url{
    if (!_url && url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: url]];
        [_webView loadRequest: request];
        
        _url = url;
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    // 发送通知，更新cell 高度
    CGFloat h = webView.scrollView.contentSize.height;
    NSLog(@"webViewDidFinishLoad: H -- %lf", h);
    if (h > 0) {
        // change frame
        CGRect frame = _webView.frame;
        frame.size.height = h;
//        _webView.frame = frame;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PaperWebDidLoadNotification" object:nil userInfo:@{@"PaperWebDidLoadHeightKey": @(h)}];
    }
    
}

@end
