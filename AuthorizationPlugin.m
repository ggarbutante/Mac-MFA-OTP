//
//  AuthorizationPlugin.m
//  OptumLabsOfflineMFA
//
//  Created by garbutante on 2/25/21.
//
#import "TOTPWindowController.h"

#pragma mark
#pragma mark Entry Point Wrappers

AuthorizationPlugin *authorizationPlugin = nil;
BOOL jamfConnecLoginAZURE = NO;

static OSStatus PluginDestroy(AuthorizationPluginRef inPlugin) {
    return [authorizationPlugin PluginDestroy:inPlugin];
}

static OSStatus MechanismCreate(AuthorizationPluginRef inPlugin, AuthorizationEngineRef inEngine, AuthorizationMechanismId mechanismId, AuthorizationMechanismRef *outMechanism) {
    return [authorizationPlugin MechanismCreate:inPlugin EngineRef:inEngine MechanismId:mechanismId MechanismRef:outMechanism];
}

static OSStatus MechanismInvoke(AuthorizationMechanismRef inMechanism) {
    return [authorizationPlugin MechanismInvoke:inMechanism];
}

static OSStatus MechanismDeactivate(AuthorizationMechanismRef inMechanism) {
    return [authorizationPlugin MechanismDeactivate:inMechanism];
}

static OSStatus MechanismDestroy(AuthorizationMechanismRef inMechanism) {
    return [authorizationPlugin MechanismDestroy:inMechanism];
}

static AuthorizationPluginInterface gPluginInterface = {
    kAuthorizationPluginInterfaceVersion,
    &PluginDestroy,
    &MechanismCreate,
    &MechanismInvoke,
    &MechanismDeactivate,
    &MechanismDestroy
};

extern OSStatus AuthorizationPluginCreate(const AuthorizationCallbacks *callbacks,
                                          AuthorizationPluginRef *outPlugin,
                                          const AuthorizationPluginInterface ** outPluginInterface) {
    if (authorizationPlugin == nil) {
        authorizationPlugin = [[AuthorizationPlugin alloc] init];
    }
    return [authorizationPlugin AuthorizationPluginCreate:callbacks PluginRef:outPlugin PluginInterface:outPluginInterface];
}


@implementation AuthorizationPlugin

#pragma mark
#pragma mark AuthorizationPlugin Implementation

- (OSStatus) AuthorizationPluginCreate:(const AuthorizationCallbacks *)callbacks
                             PluginRef:(AuthorizationPluginRef *)outPlugin
                       PluginInterface:(const AuthorizationPluginInterface **)outPluginInterface {
    
    OSStatus        err;
    PluginRecord *  plugin;
    
    assert(callbacks != NULL);
    assert(callbacks->version >= kAuthorizationCallbacksVersion);
    assert(outPlugin != NULL);
    assert(outPluginInterface != NULL);
    
    //Create the plugin.
    err = noErr;
    plugin = (PluginRecord *) malloc(sizeof(*plugin));
    if (plugin == NULL) {
        err = memFullErr;
    }
    // Fill it in.
    if (err == noErr) {
        plugin->fMagic      =       kPluginMagic;
        plugin->fCallbacks  =       callbacks;
    }
    
    *outPlugin = plugin;
    *outPluginInterface = &gPluginInterface;
    
    assert( (err == noErr) == (*outPlugin != NULL));
    
    return err;
}

- (OSStatus) MechanismCreate:(AuthorizationPluginRef)inPlugin
                  EngineRef:(AuthorizationEngineRef)inEngine
                MechanismId:(AuthorizationMechanismId)mechanismId
               MechanismRef:(AuthorizationMechanismRef *)outMechanism {
    OSStatus            err;
    PluginRecord *      plugin;
    MechanismRecord *   mechanism;
    
    plugin = (PluginRecord *) inPlugin;
    assert([self PluginValid:plugin]);
    assert(inEngine != NULL);
    assert(mechanismId != NULL);
    assert(outMechanism != NULL);
    
    err = noErr;
    mechanism = (MechanismRecord *) malloc(sizeof(*mechanism));
    if (mechanism == NULL) {
        err = memFullErr;
    }
    
    if (err == noErr) {
        mechanism->fMagic = kMechanismMagic;
        mechanism->fEngine = inEngine;
        mechanism->fPlugin = plugin;
        mechanism->fTOTPAuthenticate = (strcmp(mechanismId, "TOTPAuthenticate") == 0);
        mechanism->fLogHappenings = (strcmp(mechanismId, "LogHappenings") == 0);
    }
    
    *outMechanism = mechanism;
    
    assert( (err == noErr) ==  (*outMechanism != NULL) );
    
    return err;
}

- (OSStatus) MechanismInvoke:(AuthorizationMechanismRef)inMechanism {
    OSStatus            err;
    MechanismRecord *   mechanism;
    
    mechanism = (MechanismRecord *) inMechanism;
    assert([self MechanismValid:mechanism]);

#pragma mark --Check if JamfConnectLogin Local Login Button pressed...
    
    NSString *jamfLoginLog = @"/tmp/jamf_login.log";
    
    FileReader * reader = [[FileReader alloc] initWithFilePath:jamfLoginLog];
    NSString * logLine = nil;
    while ((logLine = [reader readLine])) {
      //NSLog(@"read line: %@", logLine);
        if ([logLine rangeOfString:@"LoginUI: Local auth continue pressed"].location != NSNotFound)
        {
            NSString *localLoginDate = nil;
            localLoginDate = [logLine substringToIndex:19];
            //NSLog(@"%@",localLoginDate);
            NSDate *nowDateFormatted = [NSDate date];
            //NSLog(@"now date = %@",nowDateFormatted);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            NSString *year = [formatter stringFromDate:nowDateFormatted];
            NSLog(@"now year = %@",year);
            
            NSString *logDateWithYear = [NSString stringWithFormat:@"%@ %@", localLoginDate,year];
            NSLog(@"new local = %@",logDateWithYear);
           // NSString *dateString =  localLoginDate;
            NSDateFormatter *localLogindateFormatter = [[NSDateFormatter alloc] init];
            [localLogindateFormatter setDateFormat:@"E MMM d HH:mm:ss yyyy"];
            NSDate *localLoginDateFormatted = [localLogindateFormatter dateFromString:logDateWithYear];
            //NSLog(@"local date formatted = %@",localLoginDateFormatted);
            //NSDate *date1 = [NSDate dateWithString:@"2010-01-01 00:00:00 +0000"];
            //NSDate *date2 = [NSDate dateWithString:@"2010-02-03 00:00:00 +0000"];
            NSTimeInterval secondsBetween = [nowDateFormatted timeIntervalSinceDate:localLoginDateFormatted];
            //int numberOfDays = secondsBetween / 86400;
            //int numberOfMinutes = secondsBetween / 60;
            //NSLog(@"There are %d days in between the two dates.", numberOfDays);
            if (secondsBetween <= 20) {
                jamfConnecLoginAZURE = NO;
                break;
            }
        }
        else
            //jamfConnecLoginAZURE = NO;
            jamfConnecLoginAZURE = YES;
    }
    //
    /*NSFileManager *filemgrTEST;

    filemgrTEST = [NSFileManager defaultManager];

    if ([filemgrTEST copyItemAtPath: @"/tmp/jamf_login.log" toPath: @"/tmp/fileTestOnlyGEROME.txt" error: NULL]  == YES)
            NSLog (@"Copy successful");
    else
            NSLog (@"Copy failed");
    
   
    
            NSFileHandle *file;
            NSMutableData *data;

            const char *bytestring = "black dog";

            data = [NSMutableData dataWithBytes:bytestring length:strlen(bytestring)];


            file = [NSFileHandle fileHandleForUpdatingAtPath: @"/tmp/fileTestOnlyGEROME.txt"];

            if (file == nil)
                    NSLog(@"Failed to open file");


            [file seekToFileOffset: 10];

            [file writeData: data];

            [file closeFile];
   */
    //
/*    FILE* jamfLoginLog = fopen("/tmp/jamf_login.log", "r");
    if(jamfLoginLog == 0) {
        jamfConnecLogin = NO;
        perror("fopen");
        exit(1);
        
    }
    size_t length;
    char *cLine = fgetln(jamfLoginLog,&length);

    while (length>0) {
        char str[length+1];
        strncpy(str, cLine, length);
        str[length] = '\0';

        NSString *line = [NSString stringWithFormat:@"%s",str];
        //% implement login here...
        if ([line rangeOfString:@"CheckOktaMech: Local auth continue pressed"].location != NSNotFound)
        {
            NSString *localLoginDate = nil;
            localLoginDate = [line substringToIndex:19];
            //NSLog(@"%@",localLoginDate);
            NSDate *nowDateFormatted = [NSDate date];
            //NSLog(@"now date = %@",nowDateFormatted);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            NSString *year = [formatter stringFromDate:nowDateFormatted];
            NSLog(@"now year = %@",year);
            
            NSString *logDateWithYear = [NSString stringWithFormat:@"%@ %@", localLoginDate,year];
            NSLog(@"new local = %@",logDateWithYear);
           // NSString *dateString =  localLoginDate;
            NSDateFormatter *localLogindateFormatter = [[NSDateFormatter alloc] init];
            [localLogindateFormatter setDateFormat:@"E MMM d HH:mm:ss yyyy"];
            NSDate *localLoginDateFormatted = [localLogindateFormatter dateFromString:logDateWithYear];
            //NSLog(@"local date formatted = %@",localLoginDateFormatted);
            //NSDate *date1 = [NSDate dateWithString:@"2010-01-01 00:00:00 +0000"];
            //NSDate *date2 = [NSDate dateWithString:@"2010-02-03 00:00:00 +0000"];
            NSTimeInterval secondsBetween = [nowDateFormatted timeIntervalSinceDate:localLoginDateFormatted];
            //int numberOfDays = secondsBetween / 86400;
            int numberOfMinutes = secondsBetween / 60;
            //NSLog(@"There are %d days in between the two dates.", numberOfDays);
            if (numberOfMinutes <= 1) {
                jamfConnecLogin = NO;
            }
            break;
        }
        else
            cLine = fgetln(jamfLoginLog,&length);
            jamfConnecLogin = YES;
    }
*/
#pragma mark --TOTPAuthenticate
    // Placeholder for TOTPAuthenticate Mech
    if (mechanism->fTOTPAuthenticate && jamfConnecLoginAZURE == NO) {
        //[TOTPWindowController initWithMechanism:mechanism];
        //[AccessCodePresenter runMechanism:mechanism];
        initializeTOTPWindowController(inMechanism, FALSE);
    }

#pragma mark --LogHappenings
    // Placeholder for LogHappenings Mech
    
    err = mechanism->fPlugin->fCallbacks->SetResult(mechanism->fEngine, kAuthorizationResultAllow);
    return err;
}

- (OSStatus) MechanismDeactivate:(AuthorizationMechanismRef)inMechanism {
    OSStatus            err;
    MechanismRecord *   mechanism;
    
    mechanism = (MechanismRecord *) inMechanism;
    assert([self MechanismValid:mechanism]);
    
    err = mechanism->fPlugin->fCallbacks->DidDeactivate(mechanism->fEngine);
    return err;
}

- (OSStatus) MechanismDestroy:(AuthorizationMechanismRef)inMechanism{
    MechanismRecord *   mechanism;
    
    mechanism = (MechanismRecord *) inMechanism;
    assert([self MechanismValid:mechanism]);
    
    free(mechanism);
    
    return noErr;
}

- (OSStatus) PluginDestroy:(AuthorizationPluginRef)inPlugin {
    PluginRecord *  plugin;
    
    plugin = (PluginRecord *) inPlugin;
    assert([self PluginValid:plugin]);
    
    free(plugin);
    
    return noErr;
}

- (BOOL) MechanismValid:(const MechanismRecord *)mechanism {
    return (mechanism != NULL)
    && (mechanism->fMagic == kMechanismMagic)
    && (mechanism->fEngine != NULL)
    && (mechanism->fPlugin != NULL);
}

- (BOOL) PluginValid:(const PluginRecord *)plugin {
    return (plugin != NULL)
    && (plugin->fMagic == kPluginMagic)
    && (plugin->fCallbacks != NULL)
    && (plugin->fCallbacks->version >= kAuthorizationCallbacksVersion);
}

@end


