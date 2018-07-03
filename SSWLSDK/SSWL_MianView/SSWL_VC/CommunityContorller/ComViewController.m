//
//  ComViewController.m
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "ComViewController.h"

@interface ComViewController ()<WKNavigationDelegate,WKUIDelegate>
{
    UIDeviceOrientation _duration;
}
@property (nonatomic, strong) UIImageView *buildImgView;

@property (nonatomic, strong) SSWL_ErrorView *errorView;

@property (nonatomic, strong) UIView *statusView;

@property (nonatomic, strong)dispatch_source_t time;

@property (nonatomic, assign) int secNum;

@property (nonatomic, assign) int i;


@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) NSString *passJS;


@end

@implementation ComViewController

- (void)dealloc{
//    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isLoading = YES;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self loadFrist];
}

- (void)loadFrist{
    
    [self createStatusBar];

    [self createBuildView];
//    [self setUpWebView];
    
    
//    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    Weak_Self;
  
    /*
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] testInfoToAnyParamCompletion:^(BOOL isSuccess, id  _Nullable respones) {
        if (isSuccess) {
            
            weakSelf.passJS = respones[@"data"];

//            [weakSelf createStatusBar];

//            [weakSelf createBuildView];
            weakSelf.isShare = NO;

         
            _i = 0;
        }
    } failure:^(NSError * _Nullable error) {
        
    }];
   */
    
}



/*
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏前调入");
         //         [self.view updateConstraints];
         _duration = [[UIDevice currentDevice] orientation];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏后调入");
         self.view.frame = [[UIScreen mainScreen] bounds];
         if (_duration == UIDeviceOrientationLandscapeLeft || _duration == UIDeviceOrientationLandscapeRight) {
             _buildImgView.image = [SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"build2" withType:@"jpg"];
             
         }else if (_duration == UIDeviceOrientationPortrait){
             _buildImgView.image = [SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"build1" withType:@"jpg"];
         }
         self.buildImgView.frame = CGRectMake(0, self.statusView.y + self.statusView.height, Screen_Width, Screen_Height- (self.statusView.y + self.statusView.height + self.tabBarHight+0.5f));
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
*/
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
    return UIInterfaceOrientationMaskAllButUpsideDown;;
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
- (void) setUpWebView{
    if (!_webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        _webView = [[WKWebView alloc] init];
        _webView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.height - 60 - self.tabBarHight);
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        _webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.view addSubview:self.webView];
        
    }
    [self showHUDForViewIsLoading];
    self.webView.hidden = NO;
//    [self showThePassCodeJS:self.passJS];
    [self judgeNet];
    [self initProgressView];
    [self loadDateToWebView];

}

- (void)showThePassCodeJS:(NSString *)passCodeJS{
    
    
    
    
    [self.webView evaluateJavaScript:passCodeJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        SYLog(@"result : %@", result);
        SYLog(@"error : %@", error);

        
        if ([self.requestUrl isEqualToString:@""]) {
            [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID = @"2";
            if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID intValue] == 0) {
//                self.requestUrl = @"https://bbs.shangshiwl.com/forum.php?forumlist=1&mobile=2";
                self.requestUrl = [NSString stringWithFormat:@"%@/forum.php?mod=forumdisplay&mobile=2", SSWL_Com_Html];

            }else{
//                weakSelf.requestUrl = [NSString stringWithFormat:@"https://bbs.shangshiwl.com/forum.php?mod=forumdisplay&fid=%@&mobile=2", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID];
                self.requestUrl = [NSString stringWithFormat:@"%@/forum.php?mod=forumdisplay&fid=%@&mobile=2", SSWL_Com_Html, [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID];
            }
            
            [self loadTheBBS];
            //            [weakSelf judgeNet];
            
        }
         
    }];
    
    NSString *doc = @"document.documentElement.innerHTML";
    NSString *body = @"document.body.innerText";
    [self.webView evaluateJavaScript:body
                   completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
                       if (error) {
                           SYLog(@"JSError:%@",error);
                       }
                       SYLog(@"html:%@",htmlStr);
                   }];
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


- (void)createStatusBar{
    
    self.statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, Screen_Width, 40)];
    self.statusView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.statusView];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"社区";
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = 1;
    titleLab.font = [UIFont systemFontOfSize:16];
    Weak_Self;
    CGSize titleSize = [titleLab.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLab.font} context:nil].size;
    [self.statusView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.statusView);
        
        make.size.mas_equalTo(CGSizeMake(titleSize.width + 5, 20));
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.statusView.height, Screen_Width, 0.5f)];
    lineView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [self.statusView addSubview:lineView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setBackgroundColor:[UIColor colorWithRed:0.6 green:0.83 blue:0.17 alpha:1]];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [backBtn setTitle:@"回到游戏" forState:UIControlStateNormal];
    [backBtn setTitle:@"回到游戏" forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    backBtn.layer.masksToBounds = YES;
    backBtn.layer.cornerRadius = 3;
    [self.statusView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.statusView);
        make.right.equalTo(weakSelf.statusView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    


   

    
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




- (void)loadTheBBS{
    self.configuration = nil;
    if (self.webView) {
        self.webView = nil;
    }
    [self.view addSubview:self.webView];
//    self.webView.frame = CGRectMake(0, 60, Screen_Width, Screen_Height - 109);
    self.webView.hidden = NO;
}

- (void)loadDateToWebView{

    
    NSMutableArray *nameArr = [NSMutableArray new];
    NSMutableDictionary *passD = [NSMutableDictionary new];
    
    NSArray *arr = [KeyChainWrapper load:SSWLUsernameKey];
    
    for (NSString *key in arr) {
        [nameArr addObject:key];
    }
    
    NSDictionary *dic = [KeyChainWrapper load:SSWLPasswordKey];
    for (NSString *key in dic) {
        [passD setObject:[dic valueForKey:key] forKey:key];
    }
    
    NSString *passString = [NSString new];
    
    if ([nameArr containsObject:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser]) {
        passString = [passD valueForKey:[SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser];
        
    }
    
    
    NSDictionary *param = @{
                            @"username" :  [SSWL_BasiceInfo sharedSSWL_BasiceInfo].loginUser,
                            @"password" :  passString,
                            };
    
    NSURL *url = [NSURL URLWithString: SSWL_COM_Test];
    
    NSString *body = [NSString stringWithFormat: @"username=%@&password=%@&sdk_code=%@",param[@"username"],param[@"password"], [SSWL_PublicTool makeSignStringWithParams:param key:SSWL_BBS_KEY]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    
    [request setHTTPMethod: @"POST"];
    
    [request setHTTPBody: [body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // 实例化网络会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建请求Task
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 将请求到的网页数据用loadHTMLString 的方法加载
        NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.webView loadHTMLString:htmlStr baseURL:nil];
    }];
    // 开启网络任务
    [task resume];
    
    
//    [self.webView loadRequest:request];
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
    
    if (self.isLoading) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.100.100:85/forum.php?mod=forumdisplay&fid=2&mobile=2"]]];
            self.isLoading = NO;
            [self.webHUD hideAnimated:YES afterDelay:0.3f];
        
        });
        

    }
    
    
    
    
    [self.errorView removeFromSuperview];
    self.errorView = nil;
    
    
    
    

    


    
    
    /*document.documentElement.innerHTML document.body.outerHTML
    NSString *doc = @"document.documentElement.innerHTML";
    [self.webView evaluateJavaScript:doc
                     completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
                         if (error) {
                             NSLog(@"JSError:%@",error);
                         }
                         NSLog(@"html:%@",htmlStr);
                     }];
     */
    //javascript:
    //
//    NSString *javascript = [NSString stringWithFormat:@"javascript:document.getElementById('username').value='%@';document.getElementById('password').value='%@';document.getElementById('login_btn').click();", @"king5566", @"qweqwe123"];
    
/*
    Weak_Self;
    [self.webView evaluateJavaScript:javascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        _i ++;
      
        
        
        if (error) {
            if ([weakSelf.requestUrl isEqualToString:@"https://www.shangshiwl.com/wap/user/index"]) {
                [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID = @"47";
                if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID intValue] == 0) {
                    weakSelf.requestUrl = @"https://bbs.shangshiwl.com/forum.php?forumlist=1&mobile=2";
                }else{
                    weakSelf.requestUrl = [NSString stringWithFormat:@"https://bbs.shangshiwl.com/forum.php?mod=forumdisplay&fid=%@&mobile=2", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID];
                    
                }
                
                [weakSelf loadTheBBS];
                [weakSelf judgeNet];
               
            }
        }
        if (result) {
            if ([weakSelf.requestUrl isEqualToString:@"https://www.shangshiwl.com/wap/user/index"]) {
                if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID intValue] == 0) {
                    weakSelf.requestUrl = @"https://bbs.shangshiwl.com/forum.php?forumlist=1&mobile=2";
                }else{
                    weakSelf.requestUrl = [NSString stringWithFormat:@"https://bbs.shangshiwl.com/forum.php?mod=forumdisplay&fid=%@&mobile=2", [SSWL_BasiceInfo sharedSSWL_BasiceInfo].bbsID];
 
                }
                [weakSelf loadTheBBS];
            }
        }
        
        SYLog(@"----------%@____%@____%d", result, error, _i);

    }];
 */
    
//    if (![weakSelf.requestUrl isEqualToString:@"https://bbs.shangshiwl.com/forum.php?mod=forumdisplay&fid=47&mobile=2"]) {
//        weakSelf.requestUrl = @"https://bbs.shangshiwl.com/forum.php?mod=forumdisplay&fid=47&mobile=2";
//        [weakSelf loadDateToWebView];
//    }
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






- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}




// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    //    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //    NSLog(@"%@",navigationAction.request.URL.absoluteString);
   

    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}




/*
- (WKWebView *)webView{
    if (!_webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.height - 20 - self.tabBarHight - 40)];
        
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        _webView.scrollView.bounces = NO;

    }
    return _webView;
}
*/

- (UIImageView *)buildImgView{
    if (!_buildImgView) {
        _buildImgView = [[UIImageView alloc] init];
        if ([[SSWL_BasiceInfo sharedSSWL_BasiceInfo] directionNumber] == 0) {
            _buildImgView.image = [SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"build2" withType:@"jpg"];

        }else{
            _buildImgView.image = [SSWL_PublicTool getImageFromBundle:[SSWL_PublicTool getResourceBundle] withName:@"build1" withType:@"jpg"];

        }
        _buildImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareTap:)];
        [_buildImgView addGestureRecognizer:tap];
        
    }
    return _buildImgView;
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
