//
//  DCServerCommunicator.m
//  Discord Classic
//
//  Created by Julian Triveri on 3/4/18.
//  Copyright (c) 2018 Julian Triveri. All rights reserved.
//

#import "DCServerCommunicator.h"
#import "DCGuild.h"
#import "DCChannel.h"
#import "DCTools.h"

@interface DCServerCommunicator()
@property bool didRecieveHeartbeatResponse;
@property bool shouldResume;
@property bool heartbeatDefined;

@property bool identifyCooldown;

@property int sequenceNumber;
@property NSString* sessionId;

@property NSTimer* cooldownTimer;
@property UIAlertView* alertView;
@end


@implementation DCServerCommunicator

+ (DCServerCommunicator *)sharedInstance {
	static DCServerCommunicator *sharedInstance = nil;
	
	if (sharedInstance == nil) {
		//Initialize if a sharedInstance does not yet exist
		sharedInstance = DCServerCommunicator.new;
		sharedInstance.gatewayURL = @"wss://gateway.discord.gg/?encoding=json&v=6";
		sharedInstance.token = [NSUserDefaults.standardUserDefaults stringForKey:@"token"];
		
		
		
		sharedInstance.alertView = [UIAlertView.alloc initWithTitle:@"Connecting" message:@"\n" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		
		UIActivityIndicatorView *spinner = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[spinner setCenter:CGPointMake(139.5, 75.5)];
		
		[sharedInstance.alertView addSubview:spinner];
		[spinner startAnimating];
	}
	
	return sharedInstance;
}


- (void)startCommunicator{
	
	[self.alertView show];
	
	self.didAuthenticate = false;
	
	if(self.token!=nil){
		
		//Establish websocket connection with Discord
		NSURL *websocketUrl = [NSURL URLWithString:self.gatewayURL];
		NSLog(@"websocket url = %@", websocketUrl);
		self.websocket = [WSWebSocket.alloc initWithURL:websocketUrl protocols:nil];
		
		//To prevent retain cycle
		__weak typeof(self) weakSelf = self;
		
		[self.websocket setTextCallback:^(NSString *responseString) {
			
			//Parse JSON to a dictionary
			NSDictionary *parsedJsonResponse = [DCTools parseJSON:responseString];
			if (!parsedJsonResponse)
				return;

			//Data values for easy access
			int op = [[parsedJsonResponse valueForKey:@"op"] integerValue];
			NSDictionary* d = [parsedJsonResponse valueForKey:@"d"];
			
			NSLog(@"Got op code %i", op);
			
			//revcieved HELLO event
			switch(op){
					
				case 10: {
					
					if(weakSelf.shouldResume){
						NSLog(@"Sending Resume with sequence number %i, session ID %@", weakSelf.sequenceNumber, weakSelf.sessionId);
						
						//RESUME
						[weakSelf sendJSON:@{
						 @"op":@6,
						 @"d":@{
						 @"token":weakSelf.token,
						 @"session_id":weakSelf.sessionId,
						 @"seq":@(weakSelf.sequenceNumber),
						 }
						 }];
						
						weakSelf.shouldResume = false;
						
					}else{
						
						NSLog(@"Sending Identify");
						
						//IDENTIFY
						[weakSelf sendJSON:@{
						 @"op":@2,
						 @"d":@{
						 @"token":weakSelf.token,
						 @"properties":@{ @"$browser" : @"peble" },
						 @"large_threshold":@"50",
						 }
						 }];
						
						//Disable ability to identify until reenabled 5 seconds later.
						//API only allows once identify every 5 seconds
						weakSelf.identifyCooldown = false;
						
						weakSelf.guilds = NSMutableArray.new;
						weakSelf.channels = NSMutableDictionary.new;
						weakSelf.loadedUsers = NSMutableDictionary.new;
						weakSelf.didRecieveHeartbeatResponse = true;
						
						int heartbeatInterval = [[d valueForKey:@"heartbeat_interval"] intValue];
						
						dispatch_async(dispatch_get_main_queue(), ^{
							
							static dispatch_once_t once;
							dispatch_once(&once, ^ {
								
								NSLog(@"Heartbeat is %d seconds", heartbeatInterval/1000);
								
								//Begin heartbeat cycle if not already begun
								[NSTimer scheduledTimerWithTimeInterval:heartbeatInterval/1000 target:weakSelf selector:@selector(sendHeartbeat:) userInfo:nil repeats:YES];
							});
							
							//Reenable ability to identify in 5 seconds
							weakSelf.cooldownTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:weakSelf selector:@selector(refreshIdentifyCooldown:) userInfo:nil repeats:NO];
						});
						
					}
					
				}
					break;
					
					
					//Misc Event
				case 0: {
					
					//Get event type and sequence number
					NSString* t = [parsedJsonResponse valueForKey:@"t"];
					weakSelf.sequenceNumber = [[parsedJsonResponse valueForKey:@"s"] integerValue];
					
					NSLog(@"Got event %@ with sequence number %i", t, weakSelf.sequenceNumber);
					
					//recieved READY
					if([t isEqualToString:@"READY"]){
						weakSelf.didAuthenticate = true;
						NSLog(@"Did authenticate!");
						
						//Grab session id (used for RESUME) and user id
						weakSelf.sessionId = [d valueForKey:@"session_id"];
						weakSelf.snowflake = [d valueForKeyPath:@"user.id"];
						
						weakSelf.userChannelSettings = NSMutableDictionary.new;
						for(NSDictionary* guildSettings in [d valueForKey:@"user_guild_settings"])
							for(NSDictionary* channelSetting in [guildSettings objectForKey:@"channel_overrides"])
								[weakSelf.userChannelSettings setValue:@((bool)[channelSetting valueForKey:@"muted"]) forKey:[channelSetting valueForKey:@"channel_id"]];
						
						//Get user DMs and DM groups
						//The user's DMs are treated like a guild, where the channels are different DM/groups
						DCGuild* privateGuild = DCGuild.new;
						privateGuild.name = @"Direct Messages";
						privateGuild.channels = NSMutableArray.new;
						for(NSDictionary* privateChannel in [d valueForKey:@"private_channels"]){
							// Initialize users array for the member list
							NSMutableArray *users = NSMutableArray.new;
							NSMutableDictionary *usersDict;
							for (NSDictionary* user in [privateChannel objectForKey:@"recipients"]) {
								usersDict = NSMutableDictionary.new;
								[usersDict setObject:[user valueForKey:@"username"] forKey:@"username"];
								[usersDict setObject:[user valueForKey:@"avatar"] forKey:@"avatar"];
								[users addObject:usersDict];
							}
							// Add self to users list
							usersDict = NSMutableDictionary.new;
							[usersDict setObject:@"You" forKey:@"username"];
							[usersDict setObject:@"TEMP" forKey:@"avatar"];
							[users addObject:usersDict];
							
							DCChannel* newChannel = DCChannel.new;
							newChannel.snowflake = [privateChannel valueForKey:@"id"];
							newChannel.lastMessageId = [privateChannel valueForKey:@"last_message_id"];
							newChannel.parentGuild = privateGuild;
							newChannel.type = 1;
							newChannel.users = users;

							NSString* privateChannelName = [privateChannel valueForKey:@"name"];
							
							//Some private channels dont have names, check if nil
							if(privateChannelName && privateChannelName != (id)NSNull.null){
								newChannel.name = privateChannelName;
							}else{
								//If no name, create a name from channel members
								NSMutableString* fullChannelName = [@"@" mutableCopy];
								
								NSArray* privateChannelMembers = [privateChannel valueForKey:@"recipients"];
                                // We should check for cases where a group dm has dissolved and only contains the user
                                // in these cases recipients will be empty, the official discord client treats these
                                // groups as Unnamed
                                if ([privateChannelMembers count] != 0) {
                                    for(NSDictionary* privateChannelMember in privateChannelMembers){
                                        //add comma between member names
                                        if([privateChannelMembers indexOfObject:privateChannelMember] != 0)
										[fullChannelName appendString:@", @"];
									
                                        NSString* memberName = [privateChannelMember valueForKey:@"username"];
                                        [fullChannelName appendString:memberName];
                                        newChannel.name = fullChannelName;
                                    }
                                } else {
                                    newChannel.name = @"Unnamed";
                                }
							}
							[privateGuild.channels addObject:newChannel];
						}
						// Sort the DMs list by most recent...
						NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastMessageId" ascending:NO selector:@selector(localizedStandardCompare:)];
						[privateGuild.channels sortUsingDescriptors:@[sortDescriptor]];
						for (DCChannel *channel in privateGuild.channels) {
							[weakSelf.channels setObject:channel forKey:channel.snowflake];
						}
						[weakSelf.guilds addObject:privateGuild];
						
						//Get servers (guilds) the user is a member of
						for(NSDictionary* jsonGuild in [d valueForKey:@"guilds"])
							[weakSelf.guilds addObject:[DCTools convertJsonGuild:jsonGuild]];
						
						
						//Read states are recieved in READY payload
						//they give a channel ID and the ID of the last read message in that channel
						NSArray* readstatesArray = [d valueForKey:@"read_state"];
						
						for(NSDictionary* readstate in readstatesArray){
							
							NSString* readstateChannelId = [readstate valueForKey:@"id"];
							NSString* readstateMessageId = [readstate valueForKey:@"last_message_id"];
							
							//Get the channel with the ID of readStateChannelId
							DCChannel* channelOfReadstate = [weakSelf.channels objectForKey:readstateChannelId];
							
							channelOfReadstate.lastReadMessageId = readstateMessageId;
							[channelOfReadstate checkIfRead];
						}
						
						dispatch_async(dispatch_get_main_queue(), ^{
							[NSNotificationCenter.defaultCenter postNotificationName:@"READY" object:weakSelf];
							
							//Dismiss the 'reconnecting' dialogue box
							[weakSelf.alertView dismissWithClickedButtonIndex:0 animated:YES];
						});
					}
					
					if([t isEqualToString:@"RESUMED"]){
						weakSelf.didAuthenticate = true;
						dispatch_async(dispatch_get_main_queue(), ^{
							[weakSelf.alertView dismissWithClickedButtonIndex:0 animated:YES];
						});
					}
					
					if([t isEqualToString:@"MESSAGE_CREATE"]){
						
						NSString* channelIdOfMessage = [d objectForKey:@"channel_id"];
						NSString* messageId = [d objectForKey:@"id"];
						
						//Check if a channel is currently being viewed
						//and if so, if that channel is the same the message was sent in
						if(weakSelf.selectedChannel != nil && [channelIdOfMessage isEqualToString:weakSelf.selectedChannel.snowflake]){
							
							dispatch_async(dispatch_get_main_queue(), ^{
								//Send notification with the new message
								//will be recieved by DCChatViewController
								[NSNotificationCenter.defaultCenter postNotificationName:@"MESSAGE CREATE" object:weakSelf userInfo:d];
							});
							
							//Update current channel & read state last message
							[weakSelf.selectedChannel setLastMessageId:messageId];
							
							//Ack message since we are currently viewing this channel
							[weakSelf.selectedChannel ackMessage:messageId];
						}else{
							DCChannel* channelOfMessage = [weakSelf.channels objectForKey:channelIdOfMessage];
							channelOfMessage.lastMessageId = messageId;
							
							[channelOfMessage checkIfRead];
							
							dispatch_async(dispatch_get_main_queue(), ^{
								[NSNotificationCenter.defaultCenter postNotificationName:@"MESSAGE ACK" object:weakSelf];	
							});
						}
					}
					
					if([t isEqualToString:@"MESSAGE_ACK"])
						[NSNotificationCenter.defaultCenter postNotificationName:@"MESSAGE ACK" object:weakSelf];
					
					if([t isEqualToString:@"MESSAGE_DELETE"])
						dispatch_async(dispatch_get_main_queue(), ^{
							//Send notification with the new message
							//will be recieved by DCChatViewController
							[NSNotificationCenter.defaultCenter postNotificationName:@"MESSAGE DELETE" object:weakSelf userInfo:d];
						});
						
					
					if([t isEqualToString:@"GUILD_CREATE"])
						[weakSelf.guilds addObject:[DCTools convertJsonGuild:d]];
                    
                    if ([t isEqualToString:@"NOTIFICATION_CREATE"]) {
                        NSLog(@"d = %@", d);
                    }

					if ([t isEqualToString:@"VOICE_STATE_UPDATE"]) {
						NSLog(@"d = %@", d);
					}

					if ([t isEqualToString:@"VOICE_SERVER_UPDATE"]) {
						NSLog(@"d = %@", d);
					}
				}
					break;
					
					
				case 11: {
					NSLog(@"Got heartbeat response");
					weakSelf.didRecieveHeartbeatResponse = true;
				}
					break;
					
				case 9:
					dispatch_async(dispatch_get_main_queue(), ^{
						[weakSelf reconnect];
					});
					break;
			}
		}];
		
		[weakSelf.websocket open];
	}
}

- (void)startVoiceCommunicator {
	NSDictionary *dict = @{
		@"op": @4,
		@"d": @{
			@"guild_id": self.selectedGuild.snowflake,
			@"channel_id": self.selectedChannel.snowflake,
			@"self_mute": @false,
			@"self_deaf": @false
		}
	};
	NSError *error; 
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict 
													options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
														error:&error];
	[self.websocket sendText:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (void)sendResume{
	[self.alertView setTitle:@"Resuming"];
	
	self.shouldResume = true;
	[self startCommunicator];
}



- (void)reconnect{
	
	NSLog(@"Identify cooldown %s", self.identifyCooldown ? "true" : "false");
	
	//Begin new session
	[self.websocket close];
	
	//If an identify cooldown is in effect, wait for the time needed until sending another IDENTIFY
	//if not, send immediately
	if(self.identifyCooldown){
		NSLog(@"No cooldown in effect. Authenticating...");
		[self.alertView setTitle:@"Authenticating"];
		[self startCommunicator];
	}else{
		double timeRemaining = self.cooldownTimer.fireDate.timeIntervalSinceNow;
		NSLog(@"Cooldown in effect. Time left %f", timeRemaining);
		[self.alertView setTitle:@"Waiting for auth cooldown..."];
		[self performSelector:@selector(startCommunicator) withObject:nil afterDelay:timeRemaining + 1];
	}
	
	self.identifyCooldown = false;
}


- (void)sendHeartbeat:(NSTimer *)timer{
	//Check that we've recieved a response since the last heartbeat
	if(self.didRecieveHeartbeatResponse){
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkForRecievedHeartbeat:) userInfo:nil repeats:NO];
		[self sendJSON:@{ @"op": @1, @"d": @(self.sequenceNumber)}];
		NSLog(@"Sent heartbeat");
		[self setDidRecieveHeartbeatResponse:false];
	}else{
		//If we didnt get a response in between heartbeats, we've disconnected from the websocket
		//send a RESUME to reconnect
		NSLog(@"Did not get heartbeat response, sending RESUME with sequence %i %@", self.sequenceNumber, self.sessionId);
		[self sendResume];
	}
}

- (void)checkForRecievedHeartbeat:(NSTimer *)timer{
	if(!self.didRecieveHeartbeatResponse){
		NSLog(@"Did not get heartbeat response, sending RESUME with sequence %i %@", self.sequenceNumber, self.sessionId);
		[self sendResume];
	}
}

//Once the 5 second identify cooldown is over
- (void)refreshIdentifyCooldown:(NSTimer *)timer{
	self.identifyCooldown = true;
	NSLog(@"Authentication cooldown ended");
}

- (void)sendJSON:(NSDictionary*)dictionary{
	NSError *writeError = nil;
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&writeError];
	
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	[self.websocket sendText:jsonString];
}

@end
