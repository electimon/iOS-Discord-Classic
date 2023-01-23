IPHONE_IP:=192.168.0.143
PROJECTNAME:=Discord
APPFOLDER:=xcbuild/$(PROJECTNAME).app
VERSION := $(shell xmlstarlet sel --net -t -m "/plist/dict/key[.='CFBundleVersion']" -v "following-sibling::string[1]"  "DiscordClassic/Discord Classic-Info.plist")
INSTALLFOLDER:=$(PROJECTNAME).app
PASSWORD := $(shell cat servpassword)

CC:=ios-clang
CPP:=ios-clang++

CFLAGS += -fobjc-arc -include "DiscordClassic/Discord Classic-Prefix.pch" -I./BButton -I./DiscordClassic -I./Websocket -I.

CPPFLAGS += -include "DiscordClassic/Discord Classic-Prefix.pch" -I./BButton -I./DiscordClassic -I./Websocket -I.

LDFLAGS += -framework Security
LDFLAGS += -framework CFNetwork
LDFLAGS += -framework UIKit
LDFLAGS += -framework Foundation
LDFLAGS += -framework CoreGraphics


all: $(PROJECTNAME)

OBJS+=  \
	./DiscordClassic/main.o \
	./DiscordClassic/DCAppDelegate.o \
	./Websocket/WSWebSocket.o \
	./Websocket/NSString+Base64.o \
	./Websocket/WSFrame.o \
	./Websocket/WSMessage.o \
	./Websocket/WSMessageProcessor.o \
	./DiscordClassic/DCServerCommunicator.o \
	./DiscordClassic/DCChannelListViewController.o \
	./DiscordClassic/DCChatViewController.o \
	./DiscordClassic/TRMalleableFrameView.o \
	./DiscordClassic/DCGuild.o \
	./DiscordClassic/DCChannel.o \
	./DiscordClassic/DCGuildListViewController.o \
	./DiscordClassic/DCViewController.o \
	./DiscordClassic/DCSettingsViewController.o \
	./DiscordClassic/DCTools.o \
	./DiscordClassic/DCChatTableCell.o \
	./DiscordClassic/DCMessage.o \
	./DiscordClassic/DCUser.o \
	./DiscordClassic/DCImageViewController.o \
	./DiscordClassic/DCWelcomeViewController.o \
	./BButton/BButton.o \
	./BButton/NSString+FontAwesome.o \
	./BButton/UIColor+BButton.o \
	./DiscordClassic/DCInfoPageViewController.o

$(PROJECTNAME): \
	./DiscordClassic/main.o \
	./DiscordClassic/DCAppDelegate.o \
	./Websocket/WSWebSocket.o \
	./Websocket/NSString+Base64.o \
	./Websocket/WSFrame.o \
	./Websocket/WSMessage.o \
	./Websocket/WSMessageProcessor.o \
	./DiscordClassic/DCServerCommunicator.o \
	./DiscordClassic/DCChannelListViewController.o \
	./DiscordClassic/DCChatViewController.o \
	./DiscordClassic/TRMalleableFrameView.o \
	./DiscordClassic/DCGuild.o \
	./DiscordClassic/DCChannel.o \
	./DiscordClassic/DCGuildListViewController.o \
	./DiscordClassic/DCViewController.o \
	./DiscordClassic/DCSettingsViewController.o \
	./DiscordClassic/DCTools.o \
	./DiscordClassic/DCChatTableCell.o \
	./DiscordClassic/DCMessage.o \
	./DiscordClassic/DCUser.o \
	./DiscordClassic/DCImageViewController.o \
	./DiscordClassic/DCWelcomeViewController.o \
	./BButton/BButton.o \
	./BButton/NSString+FontAwesome.o \
	./BButton/UIColor+BButton.o \
	./DiscordClassic/DCInfoPageViewController.o
	mkdir -p xcbuild
	$(CC) $(CFLAGS) $(LDFLAGS) $(filter %.o,$^) -o xcbuild/$@

./DiscordClassic/main.o: ./DiscordClassic/main.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCAppDelegate.o: ./DiscordClassic/DCAppDelegate.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Websocket/WSWebSocket.o: ./Websocket/WSWebSocket.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Websocket/NSString+Base64.o: ./Websocket/NSString+Base64.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Websocket/WSFrame.o: ./Websocket/WSFrame.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Websocket/WSMessage.o: ./Websocket/WSMessage.m
	$(CC) -c $(CFLAGS)  $< -o $@

./Websocket/WSMessageProcessor.o: ./Websocket/WSMessageProcessor.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCServerCommunicator.o: ./DiscordClassic/DCServerCommunicator.m
	$(CC) -fobjc-weak -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCChannelListViewController.o: ./DiscordClassic/DCChannelListViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCChatViewController.o: ./DiscordClassic/DCChatViewController.m
	$(CC) -c -fobjc-weak $(CFLAGS)  $< -o $@

./DiscordClassic/TRMalleableFrameView.o: ./DiscordClassic/TRMalleableFrameView.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCGuild.o: ./DiscordClassic/DCGuild.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCChannel.o: ./DiscordClassic/DCChannel.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCGuildListViewController.o: ./DiscordClassic/DCGuildListViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCViewController.o: ./DiscordClassic/DCViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCSettingsViewController.o: ./DiscordClassic/DCSettingsViewController.m
	$(CC) -fobjc-weak -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCTools.o: ./DiscordClassic/DCTools.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCChatTableCell.o: ./DiscordClassic/DCChatTableCell.m
	$(CC) -fobjc-weak -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCMessage.o: ./DiscordClassic/DCMessage.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCUser.o: ./DiscordClassic/DCUser.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCImageViewController.o: ./DiscordClassic/DCImageViewController.m
	$(CC) -fobjc-weak -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCWelcomeViewController.o: ./DiscordClassic/DCWelcomeViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

./BButton/BButton.o: ./BButton/BButton.m
	$(CC) -c $(CFLAGS)  $< -o $@

./BButton/NSString+FontAwesome.o: ./BButton/NSString+FontAwesome.m
	$(CC) -c $(CFLAGS)  $< -o $@

./BButton/UIColor+BButton.o: ./BButton/UIColor+BButton.m
	$(CC) -c $(CFLAGS)  $< -o $@

./DiscordClassic/DCInfoPageViewController.o: ./DiscordClassic/DCInfoPageViewController.m
	$(CC) -c $(CFLAGS)  $< -o $@

INFOPLIST:="DiscordClassic/Discord Classic-Info.plist"

RESOURCES += \
	./BButton/resources/FontAwesome.ttf \
	./Default-568h@2x.png \
	./DiscordClassic/../DCChatTableCell.nib \
        ./DiscordClassic/DCViewController.nib \
	./DiscordClassic/../Storyboard.storyboardc \
	./DiscordClassic/en.lproj \
	./Icon.png \
	./Icon@2x.png \
	./UINavigationBarTexture.png \
	./UINavigationBarTexture@2x.png

dist: $(PROJECTNAME)
	mkdir -p $(APPFOLDER)
	rm -rf DiscordClassic/en.lproj/MainStoryboard.storyboardc
	rm -rf /mnt/Public/Temp/Storyboard.storyboardc
	rm -rf /mnt/Public/Temp/Storyboard.storyboard
	rm -rf /mnt/Public/Temp/DCChatTableCell.nib
	rm -rf /mnt/Public/Temp/DCChatTableCell.xib
	rm -rf /mnt/Public/Temp/DCViewController.nib
	rm -rf /mnt/Public/Temp/DCViewController.xib
	cp -ra Storyboard.storyboard /mnt/Public/Temp/
	cp -ra DCChatTableCell.xib /mnt/Public/Temp/
	cp -ra DiscordClassic/DCViewController.xib /mnt/Public/Temp/
	sshpass -p weed ssh -oHostKeyAlgorithms=ssh-rsa root@192.168.0.232 '/Applications/Xc2ode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --minimum-deployment-target 5.0 --output-format human-readable-text --compile /Volumes/NAS/Temp/Storyboard.storyboardc /Volumes/NAS/Temp/Storyboard.storyboard'
	sshpass -p weed ssh -oHostKeyAlgorithms=ssh-rsa root@192.168.0.232 '/Applications/Xc2ode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --minimum-deployment-target 5.0 --output-format human-readable-text --compile /Volumes/NAS/Temp/DCChatTableCell.nib /Volumes/NAS/Temp/DCChatTableCell.xib'
	sshpass -p weed ssh -oHostKeyAlgorithms=ssh-rsa root@192.168.0.232 '/Applications/Xc2ode.app/Contents/Developer/usr/bin/ibtool --errors --warnings --notices --minimum-deployment-target 5.0 --output-format human-readable-text --compile /Volumes/NAS/Temp/DCViewController.nib /Volumes/NAS/Temp/DCViewController.xib'
	cp -ra /mnt/Public/Temp/Storyboard.storyboardc ./
	cp -ra /mnt/Public/Temp/DCChatTableCell.nib ./
	cp -ra /mnt/Public/Temp/DCViewController.nib ./DiscordClassic/
	cp -r $(RESOURCES) $(APPFOLDER)
	cp $(INFOPLIST) $(APPFOLDER)/Info.plist
	cp xcbuild/$(PROJECTNAME) $(APPFOLDER)
	sed -i 's|$${EXECUTABLE_NAME}|Discord|g' $(APPFOLDER)/Info.plist
	sed -i 's|$${PRODUCT_NAME}|Discord|g' $(APPFOLDER)/Info.plist
	sed -i 's|$${PRODUCT_NAME:identifier}|discord|g' $(APPFOLDER)/Info.plist
	sed -i 's|$${PRODUCT_NAME:rfc1034identifier}|discord|g' $(APPFOLDER)/Info.plist
	find $(APPFOLDER) -name \*.png|xargs ios-pngcrush -c
	find $(APPFOLDER) -name \*.plist|xargs ios-plutil -c
	find $(APPFOLDER) -name \*.strings|xargs ios-plutil -c

langs:
	ios-genLocalization

install: dist
ifeq ($(IPHONE_IP),)
	echo "Please set IPHONE_IP"
else
	sshpass -p alpine ssh root@$(IPHONE_IP) 'rm -fr /Applications/$(INSTALLFOLDER)'
	sshpass -p alpine scp -O -r $(APPFOLDER) root@$(IPHONE_IP):/Applications/$(INSTALLFOLDER)
	echo "Application $(INSTALLFOLDER) installed"
	sshpass -p alpine ssh mobile@$(IPHONE_IP) 'uicache'
endif

ipa: dist
	rm -rf xcbuild/Discord-Classic-$(VERSION).ipa
	rm -rf xcbuild/Payload
	mkdir xcbuild/Payload
	cp -ra $(APPFOLDER) xcbuild/Payload
	cd xcbuild; zip -r Discord-Classic-$(VERSION).ipa Payload

push: ipa
	sshpass -P passphrase -p $(PASSWORD) scp xcbuild/Discord-Classic-$(VERSION).ipa 1pwn:/var/www/html/artifacts/Discord-Classic/
	postDisc Discord-Classic Discord-Classic-$(VERSION).ipa "$(shell cat changelog.txt)" "1066182759887941703/Ol9aMjLwoijagapg1qRKY2gHZWNODKwXLbgoXetTGbXPQVGEYKVrisCAoistSk8MJvxQ"


uninstall:
ifeq ($(IPHONE_IP),)
	echo "Please set IPHONE_IP"
else
	ssh root@$(IPHONE_IP) 'rm -fr /Applications/$(INSTALLFOLDER)'
	echo "Application $(INSTALLFOLDER) uninstalled"
endif

clean:
	find . -name \*.o|xargs rm -rf
	rm -rf xcbuild
