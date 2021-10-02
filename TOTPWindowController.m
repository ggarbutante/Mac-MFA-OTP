//
//  TOTPWindowController.m
//  MacOS-MFA
//
//  Created by garbutante on 2/28/21.
//

#import "TOTPWindowController.h"
#import "OnlyIntegerValueFormatter.h"
#import "MacOSMFA-Swift.h"

//MechanismRecord *   mechanism;
static void *lastMechanismRef;

// Track authentication attemps...
int authAttempt = 5;

OSStatus initializeTOTPWindowController(AuthorizationMechanismRef inMechanism, BOOL isWarning)
{
    // Set the subclass to none. New instance every time.
    // Allows the window to be laucnhed over and over while
    // at the same LoginWindow
    // Launch Warning App
    TOTPWindowController *totpWindowController = nil;

    if (!totpWindowController)
    {
        totpWindowController = [[TOTPWindowController alloc] init];
        [totpWindowController setRef:inMechanism];
        [totpWindowController setIsWarned:isWarning];
        [NSApp runModalForWindow:[totpWindowController window]];
    }
    
    return 0;
}

@interface TOTPWindowController ()

@end

@implementation TOTPWindowController

- (void)setRef:(void *)ref {
    mMechanismRef = ref;
    lastMechanismRef = ref;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (id)init
{
    if ([super init])
        self = [super initWithWindowNibName:@"TOTPWindowController"];
        //[[self window] setCanBecomeVisibleWithoutLogin:TRUE];
    return self;
}

- (void) awakeFromNib {
    NSLog(@"VerifyAuth:MechanismInvoke:TOTPWindowController [+] awakeFromNib.");
    [[self window] setCanBecomeVisibleWithoutLogin:TRUE];
    [[[self window] standardWindowButton:NSWindowCloseButton] setHidden:TRUE];
    [[[self window] standardWindowButton:NSWindowMiniaturizeButton] setHidden:TRUE];
    [[[self window] standardWindowButton:NSWindowZoomButton] setHidden:TRUE];
    [[self window] center];
    [[self window] setMovable:FALSE];
}


- (void)controlTextDidChange:(NSNotification *)notification {
    OnlyIntegerValueFormatter *formatter = [[OnlyIntegerValueFormatter alloc] init];
    NSTextField *textField = [notification object];
    [textField setFormatter:formatter];
    NSLog(@"controlTextDidChange: intValue == %i", [textField intValue]);
    
    
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _totpAC01 && [textField intValue] >= 0) {
        NSLog(@"Yup. it is AC01");
        //int val01 = [textField intValue] % 10;
        //[_ac01 setIntValue:val01];
        //[_ac02 setStringValue:@""];
        [_totpAC02 becomeFirstResponder];
    }
    else if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _totpAC02 && [textField intValue] >= 0) {
        NSLog(@"Yup. it is AC02");
        //[_ac03 setStringValue:@""];
        [_totpAC03 becomeFirstResponder];
    }
    else if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _totpAC03 && [textField intValue] >= 0) {
        NSLog(@"Yup. it is AC03");
        //[_ac04 setStringValue:@""];
        [_totpAC04 becomeFirstResponder];
    }
    else if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _totpAC04 && [textField intValue] >= 0) {
        NSLog(@"Yup. it is AC04");
        //[_ac05 setStringValue:@""];
        [_totpAC05 becomeFirstResponder];
    }
    else if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _totpAC05 && [textField intValue] >= 0) {
        NSLog(@"Yup. it is AC05");
        //[_ac06 setStringValue:@""];
        [_totpAC06 becomeFirstResponder];
    }
    else if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _totpAC06 && [textField intValue] >= 0) {
        NSLog(@"Yup. it is AC06");
        //[_ac06 setStringValue:@""];
        [_totpAC06 becomeFirstResponder];
    }
    
}

- (void)controlTextDidBeginEditing:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    [textField setStringValue:@""];
}

- (IBAction)totpACSubmit:(NSButton *)sender {
    
    //OSStatus                    err = 0;
    //MechanismRecord *           mechanism;
    //self.labelMessage.stringValue = @"You pressed the button!   ";
    //self.ac01.intValue = @"firstDigit = %@";
    NSLog(@"First Digit: = %i", [_totpAC01 intValue]);
    NSLog(@"Second Digit: = %i", [_totpAC02 intValue]);
    NSLog(@"Third Digit: = %i", [_totpAC03 intValue]);
    NSLog(@"Fourth Digit: = %i", [_totpAC04 intValue]);
    NSLog(@"Fifth Digit: = %i", [_totpAC05 intValue]);
    NSLog(@"Sixth Digit: = %i", [_totpAC06 intValue]);
    
    int res01 = _totpAC01.intValue * 100000;
    int res02 = _totpAC02.intValue * 10000;
    int res03 = _totpAC03.intValue * 1000;
    int res04 = _totpAC04.intValue * 100;
    int res05 = _totpAC05.intValue * 10;
    int res06 = _totpAC06.intValue * 1;
    
    int acTotal = res01 + res02 + res03 + res04 + res05 + res06;
    
    NSString *acString = [NSString stringWithFormat: @"%d", acTotal];
    
    //Get username and use it as the keychain accountstring
    //NSString *username = [MechanismHelper getUserName:mMechanismRef];
   // NSString *username = @"yubitest1";
   // CFStringRef usernameCFString = (__bridge CFStringRef)username;
   // NSString *service = @"TOTPsecret";
   // CFStringRef serviceCFString = (__bridge CFStringRef)service;

    //Get Keychain item Value (preshared key)
    //KeychainHelper *keychain = [[KeychainHelper alloc] initWithUsername:CFBridgingRelease(usernameCFString) service:CFBridgingRelease(serviceCFString)];
    //NSString *keychainItemValue = [keychain readEntry];
    
    //const char *command = [keychainItemValue UTF8String];
    //self.otpLabel01.stringValue = keychainItemValue;
    
#pragma mark --Get value of TOTP key from the secured location...
  /*  NSString *encTOTPsecret = nil;
    NSString *keychainItemValue = @"MZSTMOBYGY2DIYLD";
    NSString *encFile = @"/Library/Security/SecurityAgentPlugins/wiFiLogin.log";
    FileReader * encFileReader = [[FileReader alloc] initWithFilePath:encFile];
    NSString * logLine = nil;
    while ((logLine = [encFileReader readLine])) {
      //NSLog(@"read line: %@", logLine);
        if ([logLine length] == 0)
        {
           //
            break;
        }
        else{
            //
            encTOTPsecret = logLine;
        }
    }
  */
    
/*    NSString *totpKey = @"S3kritS3krit";
    NSString *iv = NULL;
    //NSString *encFile = @"/Library/Security/SecurityAgentPlugins/wiFiLogin.log";
    NSURL *baseURL = [NSURL fileURLWithPath:@"file:///tmp/wiFiLogin.log" isDirectory:NO];
    //NSURL *encFileURL = [NSURL URLWithString:@"wiFiLogin.log" relativeToURL:baseURL];
    Aes256Helper *decryptor  = [[Aes256Helper alloc] initWithTotpKey:totpKey iv:iv];
    if ([decryptor decryptFile:baseURL] == YES) {
        NSLog(@"Decryption Success!");
    }
    Aes256Helper *encryptor  = [[Aes256Helper alloc] initWithTotpKey:totpKey iv:iv];
    NSURL *encbaseURL = [NSURL fileURLWithPath:@"file:///tmp/testEnc.log" isDirectory:NO];
    if ([encryptor encryptFile:encbaseURL] == YES) {
        NSLog(@"Encryption Success!");
    }
 */
    //
    NSString *decTOTPsecret = nil;
    NSString *encFile = @"/Library/Security/SecurityAgentPlugins/wiFiLogin.log";
    FileReader * encFileReader = [[FileReader alloc] initWithFilePath:encFile];
    NSString * encLine = nil;
    while ((encLine = [encFileReader readLine])) {
      //NSLog(@"read line: %@", logLine);
        if ([encLine length] == 0 || encLine == (id)[NSNull null])
        {
            NSLog(@"read line: %@", encLine);
            //break;
        }
        else if ([encLine length] != 0 || encLine != (id)[NSNull null]) {
            //
            decTOTPsecret = [encLine substringToIndex:60];
            //localLoginDate = [logLine substringToIndex:19];
            break;
        }
    }
    NSString *encKey = @"S3kritS3krit1290";
    //decTOTPsecret = @"6ohhbBqNtPnQ1nQkfwO1TUeqBDFkr+RHRvOrKsfD7kfIqw8UDpNUS15YEPw=";
    TOTPGenerator *totp =  [[TOTPGenerator alloc] initWithKeychainItemValue:decTOTPsecret fromKey:encKey];
    Ivar totpGoogle = (__bridge Ivar)([totp googleTOTP]);
    
    if (acString == (__bridge NSString *)(totpGoogle)) {
        self.otpLabel01.stringValue = @"You are authenticated!";
        self.otpLabel01.alignment = NSTextAlignmentCenter;
        verifyTOTP(mMechanismRef, @"TRUE");
        [self close];
    }
    else {
        authAttempt--;
        //self.otpLabel01.stringValue = @"Invalid accesscode. You have %d attempt remaining.";
        //self.otpLabel01.stringValue = (__bridge NSString * _Nonnull)(totpGoogle);
        self.otpLabel01.alignment = NSTextAlignmentCenter;
        
        if (authAttempt >= 2) {
            self.otpLabel01.stringValue = [NSString stringWithFormat:@"Incorrect access code! You have %d attempts remaining.",authAttempt];
            //verifyTOTP(mMechanismRef, @"FALSE");
            //[self close];
        }
        else if (authAttempt == 1) {
            self.otpLabel01.stringValue = [NSString stringWithFormat:@"Incorrect access code! You have %d attempt remaining.",authAttempt];
            //verifyTOTP(mMechanismRef, @"FALSE");
        }
        else if (authAttempt <= 0) {
            self.otpLabel01.stringValue = @"You are not allowed to log-in! Please contact your IT admin.";
            verifyTOTP(mMechanismRef, @"FALSE");
            [self close];
        }
        //
        //Stop the login
        //verifyTOTP(mMechanismRef, @"FALSE");
    }
    
}

OSStatus verifyTOTP(AuthorizationMechanismRef inMechanism, NSString* authVerified) {
    
    NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: *************************************");
        
    OSStatus                   err;
    MechanismRecord *          mechanism;
        
    NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: inMechanism=%p", inMechanism);
        
    mechanism = (MechanismRecord *) inMechanism;
    assert([MechanismHelper MechanismValid:mechanism]);
    
    if ([authVerified isEqual: @"TRUE"]) {
        NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: user is authenticated.");
        err = mechanism->fPlugin->fCallbacks->SetResult(mechanism->fEngine, kAuthorizationResultAllow);
        NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: err=%ld", (long) err);
        return err;
    }
    else if ([authVerified isEqual: @"FALSE"]) {
        NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: User enter an invalid accesscode!!!");
        err = mechanism->fPlugin->fCallbacks->SetResult(mechanism->fEngine, kAuthorizationResultDeny);
        NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: err=%ld", (long) err);
        return err;
    }
    else
        NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: User cancelled totp authentication!");
        err = mechanism->fPlugin->fCallbacks->SetResult(mechanism->fEngine, kAuthorizationResultUserCanceled);
        NSLog(@"VerifyAuth:TOTPAuthenticate:verifyTOTP: err=%ld", (long) err);
        return err;
}

- (void) windowWillClose:(NSNotification *)notification {
    [NSApp abortModal];
}

- (IBAction)totpCancel:(id)sender {
    verifyTOTP(mMechanismRef, @"CANCEL");
    [self close];
    [NSApp abortModal];
}
@end
