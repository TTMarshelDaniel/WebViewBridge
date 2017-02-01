//
//  BridgeClass.m
//  Bridge
//
//  Created by Vinod Kumar Kunhikrishnan on 2/3/15.
//  Copyright (c) 2015 melioring. All rights reserved.
//

#import "WebViewBridge.h" 


@interface WebViewBridge(WebViewDelegate)<UIWebViewDelegate> { } @end

@implementation WebViewBridge

- (instancetype)initWithWebViewController:(UIViewController *)vc andWebView:(UIWebView *)wbView;
{
    self = [super init];
    if (self) {
        self.webViewController = vc;
       // self.webViewController.popoverPresentationController.sourceView = wbView;
        self->webView = wbView;
        self->webView.delegate = self;
    }
    return self;
}

-(void)requestFromWebView:(NSString *)jsonStr {
    //
    if (jsonStr != nil) {
        //
        NSString *jsonStr_ = jsonStr;
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //
            @autoreleasepool {
                //
                NSDictionary *jsonObject = [self getDictionary:jsonStr_];
                //
                if (jsonObject != nil) {
                    //
                    if ([self validateProtocol:jsonObject] == YES) {
                        //
                        NSString      *className     = [self getClassName:jsonObject];
                        NSString      *callBackJS    = [self getCallBack:jsonObject];
                        NSDictionary  *params        = [self getParams:jsonObject];
                        WebViewBridgePlugin  *plugIn = [self getPluginClassFromString:className];
                        //
                        if (plugIn != nil) {
                            //
                            [self invokePluginMethode:plugIn withParams:params andCallBack:callBackJS];
                        } else {
                            //
                            NSMutableDictionary *obj = [self getFailoureCallBackResponseObject:callBackJS reason:@"BridgePlugin not found"];
                            [self sendCallBackToWebView:obj];
                        }
                        
                    } else { // validateProtocol(jsonObject) == false
                        //
                        NSMutableDictionary *obj = [self getFailoureCallBackResponseObject:[self getCallBack:jsonObject] reason:@"Invalid protocol"];
                        [self sendCallBackToWebView:obj];
                    }
                } else { // jsonStr == null
                    
                }
            }
        });
    }
}

// Invoke By WebView
-(void)responseFromWebView:(NSString *)jsonStr {
    //
    if (jsonStr != nil) {
        //
        NSString *jsonStr_ = jsonStr;
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @autoreleasepool {
                //
                NSDictionary *jsonObject = [self getDictionary:jsonStr_];
                //
                if (jsonObject != nil) {
                    //
                    NSString *className = [self getClassName:jsonObject];
                    WebViewBridgePlugin *plugIn = [self getPluginClassFromString:className];
                    //
                    if (plugIn) {
                        //
                        NSMutableDictionary *obj = [[NSMutableDictionary alloc]init];
                        //
                        [obj setObject:[jsonObject objectForKey:@"status"] forKey:@"status"];
                        [obj setObject:[jsonObject objectForKey:@"response"] forKey:@"response"];
                        //
                        [self invokePluginMethode:plugIn params:obj];
                    } else {
                        [NSException raise:@"" format:@""];
                    }
                }
            }
        });
    }
}

////

-(BOOL)invokePluginMethode:(WebViewBridgePlugin *)plugIn withParams:(NSDictionary *)params andCallBack:(NSString *)callBack {
    //
    if (plugIn != nil) {
        //
        WebViewBridgeCallBack bridgeCallBack = ^(NSDictionary *jsonCallBackObj) {
            //
            NSMutableDictionary *responseObj = [self getSuccessCallBackResponseObject:callBack response:[jsonCallBackObj mutableCopy]];
            [self sendCallBackToWebView:responseObj];
        };
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                //
                [plugIn invokFromBridge:params withCallBack:bridgeCallBack];
            }
        });
        return true;
    } else { // plugIn == null
        //
        NSMutableDictionary *responseObj = [self getFailoureCallBackResponseObject:callBack reason:@"PlugIn Class not Found"];
        //
        [self sendCallBackToWebView:responseObj];
        //
        return false;
    }
}

//////////////////////////

////////////


-(NSDictionary *)getDictionary:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

-(NSString *)getString:(NSDictionary *)dictionary {
    //
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    //
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    //
    return nil;
}


-(BOOL)validateProtocol:(NSDictionary *)jsonObject {
    //
    if (jsonObject == nil) {
        return NO;
    }
    
    NSArray *keys = [self getProtocolKeys];
    
    for (NSString *key in keys) {
        //
        NSObject *obj = [jsonObject valueForKey:key];
        //
        if (!obj) {
            return NO;
        }
    }
    return YES;
}

-(NSArray *)getProtocolKeys {
    NSArray *array = [NSArray arrayWithObjects:@"className", @"params", @"callBack", nil];
    
    return array;
}


-(NSString *)getClassName:(NSDictionary *)jsonObject {
    //
    NSString *className = [jsonObject objectForKey:@"className"];
    //
    if (className) {
        NSArray *array = [className componentsSeparatedByString:@"."];
        return [array lastObject];
    }
    return nil;
}

-(NSString *)getCallBack:(NSDictionary *)jsonObject {
    return [jsonObject objectForKey:@"callBack"];
}

-(NSDictionary *)getParams:(NSDictionary *)jsonObject {
    return [jsonObject objectForKey:@"params"];
}


-(WebViewBridgePlugin *)getPluginClassFromString:(NSString *)className {
    //
    WebViewBridgePlugin *plugIn = nil;
    //
    Class refClass = NSClassFromString(className);
    if (refClass) {
        plugIn = [[refClass alloc]initWithWebViewBridge:self];
    }
    //
    return plugIn;
}


-(NSMutableDictionary *)getFailoureCallBackResponseObject:(NSString *)callBackJS reason:(NSString *)reason {
    //
    NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
    [response setObject:reason forKey:@"reason"];
    return [self createCallBackResponseObject:NO callBackJS:callBackJS response:response];
}


-(NSMutableDictionary *)createCallBackResponseObject:(BOOL)status callBackJS:(NSString *)callBackJS response:(NSMutableDictionary *)response {
    //
    NSMutableDictionary *retObj = [[NSMutableDictionary alloc]init];
    //
    NSString *status_ = (status)? @"true" : @"false";
    [retObj setObject:status_ forKey:@"status"];
    [retObj setObject:callBackJS forKey:@"callBackJS"];
    [retObj setObject:response forKey:@"response"];
    //
    return retObj;
}


-(void)sendCallBackToWebView:(NSMutableDictionary *)obj {
    //
    NSString *jsonString = [self getString:obj];
    NSString *bridgeJSFunction = [NSString stringWithFormat:@"javascript:Bridge.callbackFromNative(%@);",jsonString];
    //
    if ([NSThread isMainThread]) {
        //
        [webView stringByEvaluatingJavaScriptFromString:bridgeJSFunction];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                //
                [webView stringByEvaluatingJavaScriptFromString:bridgeJSFunction];
            }
        });
    }
}

-(NSMutableDictionary *)getSuccessCallBackResponseObject:(NSString *)callBackJS response:(NSMutableDictionary *)response {
    //
    return [self createCallBackResponseObject:YES callBackJS:callBackJS response:response];
}


/////////////////////////////////////////////////////////////////////////

-(void)invokeJavaScript:(NSString *)functionName params:(NSMutableDictionary *)params callBackClass:(NSString *)callBackClass {
    //
    NSObject *plugIn = [self getPluginClassFromString:callBackClass];
    //
    if ([plugIn isKindOfClass:[WebViewBridgePlugin class]]) {
        //
        NSMutableDictionary *obj = [[NSMutableDictionary alloc]init];
        //
        [obj setObject:functionName forKey:@"functionName"];
        [obj setObject:params forKey:@"params"];
        [obj setObject:callBackClass forKey:@"callBackClass"];
        //
        if ([NSThread isMainThread]) {
            //
            [self invokeJavaScript:obj];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    //
                    [self invokeJavaScript:obj];
                }
            });
        }
    }
}

// / Send success or failoure CallBack To WebView
-(void)invokeJavaScript:(NSMutableDictionary *)jsonCallBackObj {
    //
    NSString *jsonString = [self getString:jsonCallBackObj];
    //
    NSString *bridgeJSFunction = [NSString stringWithFormat:@"javascript:Bridge.fromNative(%@);",jsonString];
    [webView stringByEvaluatingJavaScriptFromString:bridgeJSFunction];
}

-(BOOL)invokePluginMethode:(WebViewBridgePlugin *)plugIn params:(NSMutableDictionary *)params {
    //
    if (plugIn != nil) {
        //
        const NSMutableDictionary *obj = params;
        if ([NSThread isMainThread]) { // Call  Non-UI-Thread
            //
            [plugIn callBackFromBridge:obj];
            //
        } else { // Call Non-UI-Thread
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    //
                    [plugIn callBackFromBridge:obj];
                }
            });
        }
    }
    //
    return YES;
}

@end
//- (void)bridge:(Bridge *)bridge webView:(UIWebView *)webView callNative:(NSString *)parm;
@implementation WebViewBridge(WebViewDelegate)

- (BOOL)webView:(UIWebView *)webView_ shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //
    NSString *requestString = [[request URL] absoluteString];
    //
    if ([requestString hasPrefix:@"js-objective-c-callfromwebview:"]) {
        
        NSString *encodedString = [[requestString stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"js-objective-c-callfromwebview:" withString:@""];
        //
        if ([_deligate respondsToSelector:@selector(webViewbridge:webView:callNative:)]) {
            //
            [_deligate webViewbridge:self webView:webView_ callNative:encodedString];
        }
        //
        [self requestFromWebView:encodedString];
        //
        return NO;
    } else if([requestString hasPrefix:@"js-objective-c-responsefromwebview:"]){
        //
        NSString *encodedString = [[requestString stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"js-objective-c-responsefromwebview:" withString:@""];
        //
        if ([_deligate respondsToSelector:@selector(webViewbridge:webView:callNative:)]) {
            //
            [_deligate webViewbridge:self webView:webView_ callNative:encodedString];
        }
        //
        [self responseFromWebView:encodedString];
        //
        return NO;
    } else {
        if ([_deligate respondsToSelector:@selector(webViewbridge:webView:shouldStartLoadWithRequest:navigationType:)]) {
            return [_deligate webViewbridge:self webView:webView_ shouldStartLoadWithRequest:request navigationType:navigationType];
        }
    }
    //
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView_ {
    //
    if ([_deligate respondsToSelector:@selector(webViewbridge:webViewDidStartLoad:)]) {
        return [_deligate webViewbridge:self webViewDidStartLoad:webView_];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    //
    if ([_deligate respondsToSelector:@selector(webViewbridge:webViewDidFinishLoad:)]) {
        return [_deligate webViewbridge:self webViewDidFinishLoad:webView_];
    }
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error {
    //
    if ([_deligate respondsToSelector:@selector(webViewbridge:webView:didFailLoadWithError:)]) {
        return [_deligate webViewbridge:self webView:webView_ didFailLoadWithError:error];
    }
}

@end




@interface WebViewBridgePlugin()
@property (nonatomic, strong, readwrite) WebViewBridge *bridge;
@end

@implementation WebViewBridgePlugin

- (instancetype)initWithWebViewBridge:(WebViewBridge *)bridge;
{
    self = [super init];
    if (self) {
        //
        self.bridge = bridge;
    }
    //
    return self;
}

-(UIViewController *)webViewController {
    //
    return self.bridge.webViewController;
}

-(BOOL)callBackFromBridge:(const NSDictionary *)json {
    //
    return true;
}

-(BOOL)invokFromBridge:(const NSDictionary *)json withCallBack:(WebViewBridgeCallBack)callBack {
    //
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    callBack(dictionary);
    //
    return true;
}


@end
