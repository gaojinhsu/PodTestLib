//
//  GMBSIOConnection.h
//  GameMatrixBase
//
//  Created by changzeng(曾尚文) on 2019/10/21.
//  Copyright © 2019 changzeng(曾尚文). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GMBSIOConnectionDelegate <NSObject>
- (void)onICEConfig: (NSDictionary *_Nonnull) config;
- (void)onAnswer:(NSString *_Nonnull) sdp;
- (void)onRemoteCandidate: (NSString *_Nonnull) sdp mid:(NSString *_Nonnull) mid index:(int) index;
- (void)onSocketIOError;
- (void)onSockerIONotConnect;
@end

@interface GMBSIOConnection : NSObject
@property (nonatomic) NSString * _Nonnull controlKey;
@property (nonatomic) NSString * _Nonnull identity;
@property (nonatomic) NSString * _Nonnull sessionID;
@property (nonatomic) NSString * _Nonnull deviceID;
@property (nonatomic, weak, nullable) id <GMBSIOConnectionDelegate> delegate;

- (instancetype _Nonnull )initWithURL:(NSURL *_Nonnull) URL deviceID:(NSString *_Nonnull)deiviceID enableLog: (BOOL) log;
- (void) connect;
- (void) sendOffer: (NSString *_Nonnull) sdp;
- (void) disconnect;
- (void) sendCandidate: (NSString *_Nonnull) sdp mid:(NSString *_Nonnull) mid index:(int) index;
- (void) sendKickMyself;
@end

NS_ASSUME_NONNULL_END
