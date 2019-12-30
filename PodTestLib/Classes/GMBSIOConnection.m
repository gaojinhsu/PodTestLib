//
//  GMBSIOConnection.m
//  GameMatrixBase
//
//  Created by changzeng(曾尚文) on 2019/10/21.
//  Copyright © 2019 changzeng(曾尚文). All rights reserved.
//

#import <SocketIO/SocketIO.h>
#import "GMBSIOConnection.h"
#import "GMBSIOEvent.h"

@interface GMBSIOConnection()
@property (nonatomic) NSURL *apiSvr;
@property (nonatomic) SocketIOClient *socketCli;
@property (nonatomic) BOOL isConnected;
@end

@implementation GMBSIOConnection
- (instancetype)initWithURL:(NSURL *) URL deviceID:(NSString *)deviceID enableLog: (BOOL) log{
    if (nil == URL) {
        return nil;
    }
    self = [super init];
    self.apiSvr = URL;
    // TODO: no log and use compress
    //thiz.socketMgr = [[SocketManager alloc] initWithSocketURL:URL config:@{@"log":@YES} ];
    //thiz.socketMgr = [[SocketManager alloc] initWithSocketURL:URL config:@{@"log":@YES, @"forceWebsockets":@YES, @"forcePolling":@NO} ];
   
    //thiz.socketCli = thiz.socketMgr.defaultSocket;
    self.isConnected = false;
    self.deviceID = deviceID;
    NSNumber *logable = [NSNumber numberWithBool: log];
    self.socketCli = [[SocketIOClient alloc] initWithSocketURL:URL config:@{@"log":logable , @"forceWebsockets": @YES, @"connectParams":@{@"device_id":self.deviceID}}];
    return self;
}

- (void) connect {
    [self setSocketEvent];
    [self.socketCli connect];
}

- (void) sendKickMyself {
    [self.socketCli emit:GMB_SIO_EVENT_CLIENT_KICK with:@[]];
}

- (void) sendOffer: (NSString *) sdp {
    NSError *err = nil;
    NSDictionary *req = @{@"type":@"offer", @"sdp":sdp};
    NSData * _Nullable reqData = [NSJSONSerialization dataWithJSONObject:req options:kNilOptions error:&err];
    if (nil != err){
        NSLog(@"[sendOffer]:reqJSON Serialization error");
        return ;
    }
    NSString *reqJSON = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    //NSLog(@"offer:%@ lenth:%lu", reqJSON, (unsigned long)[reqJSON length]);
    
    [self.socketCli emit:GMB_SIO_EVENT_WEBRTC_OFFER with:@[reqJSON]];
}

- (void) sendCandidate: (NSString *_Nonnull) sdp mid:(NSString *_Nonnull) mid index:(int) index {
    NSError *err = nil;
    NSDictionary *req = @{@"candidate":sdp, @"sdpMid":mid, @"sdpMLineIndex":[NSNumber numberWithInt:index]};
    NSData * _Nullable reqData = [NSJSONSerialization dataWithJSONObject:req options:kNilOptions error:&err];
    if (nil != err){
        NSLog(@"[sendCandidate]:reqJSON Serialization error");
        return ;
    }
    NSString *reqJSON = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    //NSLog(@"candidate:%@ lenth:%lu", reqJSON, (unsigned long)[reqJSON length]);
    
    [self.socketCli emit:GMB_SIO_EVENT_WEBRTC_ICE with:@[reqJSON]];

}

- (void) setSocketEvent {
    // connected
    [self.socketCli on:GMB_SIO_EVENT_CONNECTED  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {

        [self onConnect:data ack:ack];

    }];
    
     //notconnected
    [self.socketCli on:GMB_SIO_EVENT_NOTCONNECTED  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onNotConnect:data ack:ack];
    }];
    
    // disconnected
    [self.socketCli on:GMB_SIO_EVENT_DISCONNECTED  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onDisconnect:data ack:ack];
    }];
    
    // clientConfig
    [self.socketCli on:GMB_SIO_EVENT_CLIENT_CONFIG  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onClientConfig:data ack:ack];
    }];
    
    // clientCount
    [self.socketCli on:GMB_SIO_EVENT_CLIENT_COUNT  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onClientCount:data ack:ack];
    }];
    
    // webrtc-answer
    [self.socketCli on:GMB_SIO_EVENT_WEBRTC_ANSWER  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onWebRTCAnswer:data ack:ack];
    }];
    
    // webrtc-ice
    [self.socketCli on:GMB_SIO_EVENT_WEBRTC_ICE  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onWebRTCIceCandidate:data ack:ack];
    }];
    
    // session_id
    [self.socketCli on:GMB_SIO_EVENT_SESSION_ID  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onSessionId:data ack:ack];
    }];
    
    // error
    [self.socketCli on:GMB_SIO_EVENT_ERROR  callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [self onError:data ack:ack];
    }];
}

- (void) onConnect:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onConnect");
    NSError *err = nil;
    NSDictionary *req = @{@"emitData": @"ArrayBuffer"};
    NSData * _Nullable reqData = [NSJSONSerialization dataWithJSONObject:req options:kNilOptions error:&err];
    if (nil != err){
        NSLog(@"[onConnect]:reqJSON Serialization error");
        return ;
    }
    NSString *reqJSON = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    [self.socketCli emit:GMB_SIO_EVENT_OPEN with:@[reqJSON]];
}

- (void) onDisconnect:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onDisconnect");
}

- (void) onClientConfig:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onClientConfig");
    NSString *configJSON = [data objectAtIndex:0];
    NSError *err = nil;
    NSDictionary *config = [NSJSONSerialization JSONObjectWithData:[configJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    if (err != nil ) {
        NSLog(@"[onClientConfig]: parse JSON Error");
        return ;
    }
    if (self.delegate == nil || config == nil) {
        NSLog(@"[onClientConfig]:self.delegate == nil || config == nil");
        return ;
    }
    [self.delegate onICEConfig:config];
}

- (void) onClientCount:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onClientCount");
}

- (void) onWebRTCAnswer:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onWebRTCAnswer");
    NSString *answerJSON = [data objectAtIndex:0];
    NSError *err = nil;
    NSDictionary *answer = [NSJSONSerialization JSONObjectWithData:[answerJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    if (err != nil ) {
        NSLog(@"[onClientConfig]: parse JSON Error");
        return ;
    }
    
    if (nil == answer ) {
        NSLog(@"[setRemoteSDP] answer == nil");
        return ;
    }
    
    NSString *sdp = [answer objectForKey:@"sdp"];
    if (nil == sdp || nil == self.delegate) {
        NSLog(@"[setRemoteSDP]: nil == sdp || nil == self.delegate");
        return ;
    }
    [self.delegate onAnswer:sdp];
}


- (void) onWebRTCIceCandidate:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onWebRTCIceCandidate");
    NSString *candidateJSON = [data objectAtIndex:0];
    NSError *err = nil;
    NSDictionary *candidate = [NSJSONSerialization JSONObjectWithData:[candidateJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    if (err != nil ) {
        NSLog(@"[onClientConfig]: parse JSON Error");
        return ;
    }
    
    if (nil == candidate || nil == self.delegate) {
        NSLog(@"nil == candidate || nil == self.delegate");
        return ;
    }
    NSString *sdp = [candidate objectForKey:@"candidate"];
    NSString *mid = [candidate objectForKey:@"sdpMid"];
    NSNumber *index = [candidate objectForKey:@"sdpMLineIndex"];

    [self.delegate onRemoteCandidate:sdp mid:mid index:[index intValue]];
    
}

- (void) onSessionId:(NSArray *)data ack:(SocketAckEmitter *)ack {
    NSLog(@"onSessionId");
    NSString *sessionStr =[data objectAtIndex:0];
    if (nil == sessionStr){
        NSLog(@"[onSessionId]:nil == session");
        return ;
    }
    NSError *err = nil;
    NSDictionary *session  = [NSJSONSerialization JSONObjectWithData:[sessionStr dataUsingEncoding: NSUTF8StringEncoding] options:kNilOptions error:&err];
    if (nil != err){
        NSLog(@"JSONObjectWithData session is null");
        return ;
    }
    NSString *sessionID = [session objectForKey:@"session_id"];
    if (nil == sessionID){
        NSLog(@"[onSessionId]:nil == sessionID");
        return ;
    }
    self.sessionID = [[NSString alloc] initWithString:sessionID];
    
    NSDictionary *req = @{@"session_id":sessionID,
                          @"device_id": self.deviceID,
                          @"key": self.controlKey,
                          @"identity": self.identity,
                          };
    NSData * _Nullable reqData = [NSJSONSerialization dataWithJSONObject:req options:kNilOptions error:&err];
    if (nil != err){
        NSLog(@"reqJSON Serialization error");
        return ;
    }
    NSString *reqJSON = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
    [self.socketCli emit:GMB_SIO_EVENT_START_BOARD with:@[reqJSON]];
}

- (void) onError:(NSArray *)data ack:(SocketAckEmitter *)ack {
    if (nil == self.delegate) {
        return ;
    }
    [self.delegate onSocketIOError];
}


- (void) disconnect {
    [self.socketCli disconnect];
}

- (void) onNotConnect:(NSArray *)data ack:(SocketAckEmitter *)ack {
    if (nil == self.delegate) {
        return ;
    }
    [self.delegate onSockerIONotConnect];
}
@end
