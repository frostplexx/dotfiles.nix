#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "SystemEvents.h"

int main() {
  @autoreleasepool {
    SystemEventsApplication *systemEventsApp =
        (SystemEventsApplication *)[[SBApplication alloc]
            initWithBundleIdentifier:@"com.apple.systemevents"];
    SystemEventsApplicationProcess *controlCenter =
        [systemEventsApp.applicationProcesses objectWithName:@"ControlCenter"];

    SystemEventsMenuBar *menuBar = [[controlCenter.menuBars objectAtIndex:0] get];
    SystemEventsMenuBarItem *item = [[menuBar.menuBarItems objectAtIndex:1] get];

    [item clickAt:nil];
  }
  return 0;
}
