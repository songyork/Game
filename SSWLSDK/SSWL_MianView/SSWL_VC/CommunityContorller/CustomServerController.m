//
//  CustomServerController.m
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "CustomServerController.h"


@interface CustomServerController ()


@property (nonatomic, strong) SSWL_ErrorView *errorView;



@end

@implementation CustomServerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadDataToWebView];

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"toGame"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getMsg"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"statistics"];

}




- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"toGame"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getMsg"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"statistics"];

//    [self clearData];
    
}

- (void)loadDataToWebView{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
    
}

- (void)isLoadData:(BOOL)isLoad{
    SYLog(@"子类实现.....");
    SYLog(@"-----isLoad:%d", isLoad);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    SYLog(@"加载完成");
    
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}


// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}




#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return [[WKWebView alloc]init];
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //    SYLog(@"%@", message.body);
    if ([message.name isEqualToString:@"toGame"]) {
        self.barHidden = YES;
        [self isBarHidden];
        if (self.WebBlock) {
            self.WebBlock();
        }
    }
    
    if ([message.name isEqualToString:@"getInfo"]) {
        [self sendDataForPrama:message.body messageName:message.name];
    }
    
    if ([message.name isEqualToString:@"statistics"]){
        [self statisticsAllEventWithMessageName:message.name Param:message.body];
    }

}


/**
 * 事件监听
 */
- (void)statisticsAllEventWithMessageName:(NSString *)messageName Param:(NSString *)param{

    SYLog(@"%@", param);
}


- (void)sendDataForPrama:(NSDictionary *)param messageName:(NSString *)name{
    NSString *jsString = [NSString string];
    //    NSArray *paramArr = [NSArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:param];

    NSString *sign = [SSWL_PublicTool makeSignStringWithParams:dict];
    jsString = [NSString stringWithFormat:@"getiOSSign('%@')", sign];
    
    //    paramArr = [param allValues];
    SYLog(@"-----------------dict:%@------------", dict);
    [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        SYLog(@"----------%@____%@", result, error);
    }];
}

- (void)isNetWorking:(BOOL)isNetWorking{
    if (!isNetWorking) {
        SYLog(@"没网");
        if (self.webView) {
            self.webView.hidden = YES;
            [self.progressView setHidden:YES];
            [self.view addSubview:self.errorView];
        }
    }
}


- (void)touchTap:(UITapGestureRecognizer *)sender{
    SYLog(@"%s",__FUNCTION__);
    [self loadDataToWebView];
    self.webView.hidden = NO;
    self.progressView.hidden = NO;
    if (self.errorView) {
        self.errorView.hidden = YES;
        self.errorView = nil;
    }
    [self judgeNet];
}


- (SSWL_ErrorView *)errorView{
    if (!_errorView) {
        _errorView = [[SSWL_ErrorView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchTap:)];
        [_errorView addGestureRecognizer:tap];
    }
    return _errorView;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
