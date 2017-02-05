/*
 Copyright (C) 2017 Denovation, Inc. All rights reserved.
 
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

// Debug Log
#ifdef DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#  define LOG(...) ;
#  define LOG_CURRENT_METHOD ;
#endif

extern UIViewController *UnityGetGLViewController();
extern "C" void UnitySendMessage(const char *, const char *, const char *);

@interface WebViewPlugin : NSObject<WKNavigationDelegate, WKUIDelegate>
{
    WKWebView   *webView;
    NSString    *gameObject;
}

@end

@implementation WebViewPlugin

-(id)_init:(const char *)_gameObject
{
    LOG_CURRENT_METHOD;
    self = [super init];
    
    UIView *view = UnityGetGLViewController().view;
    
    webView = [[WKWebView alloc] init];
    webView.frame = view.frame;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    //webView.scalesPageToFit = YES;
    webView.opaque = NO;
    //webView.backgroundColor = [UIColor clearColor];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.hidden = YES;
    
    [view addSubview:webView];
    
    gameObject = [NSString stringWithUTF8String:_gameObject];
    
    return self;
}

-(void)_setFrame:(CGRect)rect
{
    LOG_CURRENT_METHOD;
    
    webView.frame = rect;
}

-(void)_loadRequest:(const char *)url
{
    LOG_CURRENT_METHOD;
    
    NSLog(@"webviewLoadRequest url=%s", url);
    //url = "http://yahoo.co.jp";
    
    NSString *urlStr = [NSString stringWithUTF8String:url];
    NSURL *nsurl = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:request];
}

- (void)_setHidden:(BOOL)hidden
{
    LOG_CURRENT_METHOD;
    
    if (webView == nil)
        return;
    webView.hidden = hidden ? YES : NO;
}

- (void)dealloc
{
    [webView removeFromSuperview];
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    LOG_CURRENT_METHOD;
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    LOG_CURRENT_METHOD;
    
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    LOG_CURRENT_METHOD;
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    LOG_CURRENT_METHOD;
}

- (void)webView:(WKWebView *)wkWebView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (webView == nil) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    NSURL *url = [navigationAction.request URL];
    if ([url.absoluteString rangeOfString:@"//itunes.apple.com/"].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([url.absoluteString hasPrefix:@"unity:"]) {
        UnitySendMessage([gameObject UTF8String], "CallFromJS", [[url.absoluteString substringFromIndex:6] UTF8String]);
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if (navigationAction.navigationType == WKNavigationTypeLinkActivated
               && (!navigationAction.targetFrame || !navigationAction.targetFrame.isMainFrame)) {
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
@end


extern "C" {
    void *_init(const char *gameObject);
    void _loadRequest(void *instance, const char *url);
    void _setHidden(void *instance, BOOL hidden);
}

void *_init(const char *gameObject)
{
    id instance = [[WebViewPlugin alloc] _init:gameObject];
    return (__bridge_retained void *)instance;
}

void _loadRequest(void *instance, const char *url)
{
    WebViewPlugin *webViewPlugin = (__bridge WebViewPlugin *)instance;
    [webViewPlugin _loadRequest:url];
}

void _setHidden(void *instance, BOOL hidden)
{
    WebViewPlugin *webViewPlugin = (__bridge WebViewPlugin *)instance;
    [webViewPlugin _setHidden:hidden];
}

