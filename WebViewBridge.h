//
//  BridgeClass.h
//  Bridge
//
//  Created by Vinod Kumar Kunhikrishnan on 2/3/15.
//  Copyright (c) 2015 melioring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^WebViewBridgeCallBack)(NSDictionary *jsonCallBackObj);


@protocol WebViewBridgeDeligate;
@interface WebViewBridge : NSObject {
    // 
    UIWebView *webView;
}

@property(nonatomic, strong) UIViewController *webViewController;
@property(nonatomic, assign)id<WebViewBridgeDeligate> deligate;

- (instancetype)initWithWebViewController:(UIViewController *)vc andWebView:(UIWebView *)webView;
-(void)invokeJavaScript:(NSString *)functionName params:(NSMutableDictionary *)params callBackClass:(NSString *)callBackClass;

@end


@interface WebViewBridgePlugin : NSObject { }

@property (nonatomic, strong, readonly) WebViewBridge *bridge;
@property (nonatomic, strong, readonly) UIViewController *webViewController;

- (instancetype)initWithWebViewBridge:(WebViewBridge *)bridge;
-(BOOL)callBackFromBridge:(const NSDictionary *)json;
-(BOOL)invokFromBridge:(const NSDictionary *)json withCallBack:(WebViewBridgeCallBack)callBack;



@end



@protocol WebViewBridgeDeligate <NSObject>

@optional
- (BOOL)webViewbridge:(WebViewBridge *)bridge webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewbridge:(WebViewBridge *)bridge webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewbridge:(WebViewBridge *)bridge webViewDidFinishLoad:(UIWebView *)webView;
- (void)webViewbridge:(WebViewBridge *)bridge webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
- (void)webViewbridge:(WebViewBridge *)bridge webView:(UIWebView *)webView callNative:(NSString *)parm;

@end

