//
//  LoginWithApple.m
//  ReactNativeLoginWithApple
//
//  Created by PRAMOD_PUNCHH on 06/06/19.
//  Copyright © 2019 PRAMOD. All rights reserved.
//

#import "LoginWithApple.h"

@implementation LoginWithApple

+ (instancetype)sharedInstance
{
    static LoginWithApple *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginWithApple alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)initiateLoginProcess:(void (^)(NSDictionary *result))completionHandler errorHandler:(void (^)(NSError *error))errorHandler {
    
    self.successBlock = completionHandler;
    self.errorBlock = errorHandler;
    
        if (@available(iOS 13.0, *)) {
            ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc]init];
            ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
            request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
            
        
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc]initWithAuthorizationRequests:@[request]];
        
        authorizationController.delegate = self;
        authorizationController.presentationContextProvider = self;
        [authorizationController performRequests];
    
    }
    
}

#pragma Authorization Delegates

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
        NSLog(@"%@",authorization);
        
        ASAuthorizationAppleIDCredential *appleIDCredential = [authorization credential];
        if(appleIDCredential) {
             NSString *identityToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
             
            NSDictionary *userDetails = @{@"token": identityToken, @"userIdentifier": [appleIDCredential user], @"name" : [appleIDCredential fullName], @"email" : [appleIDCredential email ]};
            self.successBlock(userDetails);
        }
    }

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    NSLog(@"%@",error);
    self.errorBlock(error);
}

#pragma PresentationAnchorForAuthorizationController Delegate

-(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    return  [[UIApplication sharedApplication]delegate].window;
}

@end
