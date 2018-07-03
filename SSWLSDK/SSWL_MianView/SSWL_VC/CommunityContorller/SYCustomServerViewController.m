//
//  SYCustomServerViewController.m
//  AYSDK
//
//  Created by SDK on 2017/12/22.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SYCustomServerViewController.h"

#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SYCustomServerViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) UIImageView *buildImgView;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, strong) UIView *statusView;

@property (nonatomic, strong)dispatch_source_t time;

@property (nonatomic, assign) int secNum;

@property (nonatomic, assign) int i;


@property (nonatomic, assign) BOOL isShare;
@end

@implementation SYCustomServerViewController

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    
    

    self.isShare = NO;
    
     [self setUpWebView];
     [self initProgressView];
     [self loadDateToWebView];

     [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    
    _i = 0;
}




-(BOOL)shouldAutorotate
{
    if([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1){
        return NO;
    }
    if([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0){
        return YES;
    }
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 1)    //竖屏有游戏
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].directionNumber == 0)    //横屏游戏
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"toGame"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getInfo"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"getImg"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"statistics"];
    
}




- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"toGame"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getInfo"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"getImg"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"statistics"];
    
    //    [self clearData];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏前调入");
         //         [self.view updateConstraints];
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏后调入");
         self.view.frame = [[UIScreen mainScreen] bounds];
         //         self.webView.frame = CGRectMake(0, 20, self.view.width, self.view.height - 20 - self.tabBarHight);
         [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.equalTo(self.view).offset(20);
             make.left.and.right.and.bottom.equalTo(self.view).offset(0);
         }];
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


/**
 * 系统方法
 * 是否隐藏
 */
- (BOOL)prefersStatusBarHidden {
    return [self isBarHidden];
}

- (BOOL)isBarHidden{
    /*返回 self.barHidden*/
    return self.barHidden;
}


//自己看.h文件
- (void)setUpWebView{
    if (!_webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.height - 20 - self.tabBarHight)];
        
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        _webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.view addSubview:self.webView];

    }
    [self showHUDForViewIsLoading];
    [self judgeNet];
}

//自己看.h文件
- (void)initProgressView
{
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 2)];
    progressView.tintColor = [UIColor colorWithRed:0 green:0.58 blue:1 alpha:1];
    progressView.trackTintColor = [UIColor whiteColor];
    self.progressView = progressView;
    [self.view addSubview:self.progressView];
    [self.progressView setHidden:NO];
}

- (void)showHUDForViewIsLoading{
    
    self.webHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.webHUD.mode = MBProgressHUDModeIndeterminate;
    self.webHUD.label.text = @"正在加载";
    
}


- (void)createBuildView{
    self.buildImgView.frame = CGRectMake(0, self.statusView.y + self.statusView.height, Screen_Width, Screen_Height- (self.statusView.y + self.statusView.height + self.tabBarHight+0.5f));
    [self.view addSubview:self.buildImgView];
    
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

// 判断网络
- (void)judgeNet
{
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getNetWorkStateBlock:^(NSInteger netStatus) {
        switch (netStatus) {
            case 0:{
                [weakSelf webViewDidLoadFail];
                
            }
                break;
                
            case 1:{
                
                [weakSelf isNetWorking:YES];
                
            }
                break;
                
            case 2:{
                [weakSelf isNetWorking:YES];
                
            }
                break;
                
            case 3:{
                [weakSelf webViewDidLoadFail];
                
            }
                break;
                
            default:
                break;
        }
    }];
}


/*
 - (void)keepNetWoking{
 _secNum = 0;
 dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
 //创建一个定时器
 self.time = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
 //设置开始时间
 dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
 //设置时间间隔
 uint64_t interval = (uint64_t)(1.0* NSEC_PER_SEC);
 //设置定时器
 dispatch_source_set_timer(self.time, start, interval, 0);
 //设置回调
 SYLog(@"再次刷新网络");
 
 dispatch_source_set_event_handler(self.time, ^{
 if ([SSWL_BasiceInfo sharedSSWL_BasiceInfo].isNetWorking) {
 //            _time = nil; // 将 dispatch_source_t 置为nil
 dispatch_source_cancel(_time);
 _secNum = 0;
 }else{
 _secNum++;
 if (_secNum == 5) {
 dispatch_async(dispatch_get_main_queue(), ^{
 
 [self judgeNet];
 dispatch_source_cancel(_time);
 _secNum = 0;
 
 });
 }
 SYLog(@"重读网络%d", _secNum);
 
 }
 });
 
 
 
 //由于定时器默认是暂停的所以我们启动一下
 //启动定时器
 dispatch_resume(self.time);
 
 
 }
 
 */




- (void)webViewDidLoadFail{
    [self.webView stopLoading];
    self.webHUD.mode = MBProgressHUDModeText;
    self.webHUD.label.text = @"网速不给力";
    [self.webHUD hideAnimated:YES afterDelay:0.5f];
    //    self.webHUD = nil;
    [self isNetWorking:NO];
    
}



/**
 * 分享-通知
 * 点击发送通知. 通知研发可以进行分享操作
 @param sender 手势事件
 */
- (void)shareTap:(UITapGestureRecognizer *)sender{
    
    self.isShare = !self.isShare;
    if (self.isShare) {
        
        
    }
    
    
}





/**
 * 点击刷新网络
 
 @param sender
 */
- (void)touchTap:(UITapGestureRecognizer *)sender{
    SYLog(@"%s",__FUNCTION__);
    
    
    [self loadDateToWebView];
    self.webView.hidden = NO;
    self.progressView.hidden = NO;
    if (self.errorView) {
        self.errorView.hidden = YES;
        self.errorView = nil;
    }
}






- (void)loadDateToWebView{
//    [self initProgressView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
}


- (void)backClick{
    if (self.WebBlock) {
        self.barHidden = YES;
        self.WebBlock();
    }
}


#pragma mark - KVO
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}




#pragma mark - WKUIDelegate And WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    
    [self.webHUD hideAnimated:YES afterDelay:0.3f];
    
    [self.errorView removeFromSuperview];
    self.errorView = nil;
    
    
    
    
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    [self judgeNet];
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [self judgeNet];
    
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    SYLog(@"%s",__FUNCTION__);
    
    [self webViewDidLoadFail];
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    [self webViewDidLoadFail];
    
}




#pragma mark WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    SYLog(@"%s",__FUNCTION__);
    [self webViewDidLoadFail];
    
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //    SYLog(@"%@", message.body);
    if ([message.name isEqualToString:@"toGame"]) {
        /**
         *       self.barHidden = YES
         *    爸爸会自动识别,并把状态栏给隐藏 (屌不屌)
         */
        self.barHidden = YES;//在这里设置yes
        [self isBarHidden];
        if (self.WebBlock) {
            self.WebBlock();
            
        }
    }
    /*给前端签名(屌不屌)*/
    
    if ([message.name isEqualToString:@"statistics"]){
        [self statisticsAllEventWithMessageName:message.name Param:message.body];
    }
    if ([message.name isEqualToString:@"getInfo"]) {
        [self sendDataForPrama:message.body messageName:message.name];
        
    }
    if ([message.name isEqualToString:@"getImg"]){
        SYLog(@"上传图片了");
       
        [self getImageForUpLoad];
        
    }
    
    
    
}

- (void)getImageForUpLoad{
    self.isShare = YES;
    
    
}


- (void)fetchImages:(NSArray <UIImage *> *)images {
    SYLog(@"------------------images : %@",images);
    NSMutableArray *base64ImageArray = [[NSMutableArray alloc] init];
    for (UIImage *img in images) {
        
        NSData *data = UIImageJPEGRepresentation(img, 0.5f);
        NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
//        NSData * data = [UIImageJPEGRepresentation(img, 0.5) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        NSData *base64EncodedImage = [UIImageJPEGRepresentation(img, 0.8) base64EncodingWithLineLength:0];
//        NSString *base64String = [NSString stringWithUTF8String:[data bytes]];
        [base64ImageArray addObject:encodedImageStr];
        encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        encodedImageStr = [encodedImageStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符使用
        encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@" " withString:@""];
//        SYLog(@"---------------base64ImageArray : %@ -----------", encodedImageStr);
        [self sendImageDataString:encodedImageStr image:img];
        
       
    }
    
    
}

- (void)sendImageDataString:(NSString *)imageDataString image:(id)image{
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
         NSString *jsString = [NSString stringWithFormat:@"postImgUrl('%@', '%@')", imageDataString, image];
         
         [self.webView evaluateJavaScript:jsString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
             SYLog(@"result : %@  -------or----------error : %@", result, error);
         }];
         
     });
   
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


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    if (self.isShare) {
        completionHandler();
        return;
        
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];     [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
        
    }]];
    
    if (self.webView){
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }else{
       completionHandler();
    }
    
 
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }]];
//
//    [self presentViewController:alert animated:YES completion:nil];
}




// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    SYLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    SYLog(@"%@",navigationAction.request.URL.absoluteString);

    /*
    NSString *requestString = navigationAction.request.URL.absoluteString;

    if ([requestString hasPrefix:@"easy-js:"]) {
        [self handleRequestString:requestString webView:(EasyJSWebView *)webView.superview];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else if ([self.realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)])
    {
        [self.realDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    */
  
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}




/*
- (WKWebView *)webView{
   
    return _webView;
}

*/


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
