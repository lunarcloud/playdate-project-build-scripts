# Playdate Project Build Scripts
Build scripts to be put at the base of a playdate project.

## Requirement
You need to set a *PLAYDATE_SDK_PATH* environment variable. 

## Files
* `build.bat` - For Windows Users
* `build.sh` - For Linux Users

## Usage 
```
Usage:  build.[sh|bat] [options]
Options:
-[n]c, --[no-]clean             Clean, i.e. delete, the Output.pdx first (default), or don't.
-[n]b, --[no-]build             Build the sources into the Output.pdx (default), or don't.
-[n]r, --[no-]run               Run the output in the PlayDate Simulator, or don't (default).
--release                       Strip Debug Symbols.
--quiet                         Don't use verbose flags.
--detach                        Launch Simulator detached from this script (don't wait for it to exit).
-k, --skip-unknown              When building, skip unrecognized files instead of copying them to the pdx folder.
-cb                             Clean and Build. Don't run.
-cbr                            Clean, Build, and Run. Due to defaults, same as just -r,--run
-h, --help                      Display this help message.
```

