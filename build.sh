#!/bin/bash
# shellcheck disable=SC2086

# the directory of the current running script, so that file paths are absolute from the script's location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Echo Colors
YLW='\e[1;33m'
RED='\e[0;31m'
PRP='\e[1;35m'
WHT='\e[0;37m'
UND='\e[4;1m'
CLR='\e[0m' # Reset to terminal's default (not just a "black")


# function to display help message and then quit
function show_help() {
    echo
    echo -e "Build script for this ${YLW}PlayDate${CLR} Project."
    echo
    echo -e "Usage:\t${UND}build.sh${WHT} [options]${CLR}"
    echo "Options:"
    echo -e "\t${WHT}-${RED}[n]${WHT}c, --${RED}[no-]${WHT}clean${CLR}             Clean, i.e. delete, the Output.pdx first ${PRP}(default)${CLR}, or don't."
    echo -e "\t${WHT}-${RED}[n]${WHT}b, --${RED}[no-]${WHT}build${CLR}             Build the sources into the Output.pdx ${PRP}(default)${CLR}, or don't."
    echo -e "\t${WHT}-${RED}[n]${WHT}r, --${RED}[no-]${WHT}run${CLR}               Run the output in the PlayDate Simulator, or don't ${PRP}(default)${CLR}."
    echo -e "\t${WHT}--release${CLR}                       Strip Debug Symbols."
    echo -e "\t${WHT}--quiet${CLR}                         Don't use verbose flags."
    echo -e "\t${WHT}--detach${CLR}                        Launch Simulator detached from this script (don't wait for it to exit)."
    echo -e "\t${WHT}-k, --skip-unknown${CLR}              When building, skip unrecognized files instead of copying them to the pdx folder."
    echo -e "\t${WHT}-cb${CLR}                             Clean and Build. Don't run."
    echo -e "\t${WHT}-cbr${CLR}                            Clean, Build, and Run. Due to defaults, same as just ${WHT}-r,--run${CLR}"
    echo -e "\t${WHT}-h, --help${CLR}                      Display this help message."
    echo
    exit 1
}

# Input and Output on filesystem
SOURCE=$SCRIPT_DIR/source
if [[ ! -d "$SOURCE" ]]; then
    SOURCE=$SCRIPT_DIR/Source
fi
OUTPUT=$SCRIPT_DIR/Output.pdx

# Parse Script Arguments, as described in the help message
CLEAN=True
BUILD=True
RUN=False
STRIP_OPT= 
VERBOSE_OPT_RM=-v
VERBOSE_OPT_COMPILER=-v
VERBOSE_SIMULATOR=True
DETACH_SIMULATOR=False
SKIP_UNKNOWN_OPT=

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -nb|--no-build) BUILD=False ;;
        -b|--build) BUILD=True ;;
        -nc|--no-clean) CLEAN=False ;;
        -c|--clean) CLEAN=True ;;
        -nr|--no-run) RUN=False ;;
        -r|--run) RUN=True ;;
        -cb) CLEAN=True ; BUILD=True ; RUN=False  ;;
        -cbr) CLEAN=True ; BUILD=True ; RUN=True ;;
        --release) STRIP_OPT=--strip ;;
        --quiet) VERBOSE_OPT_RM= ; VERBOSE_OPT_COMPILER=-q ; VERBOSE_SIMULATOR=False ;;
        --detach) DETACH_SIMULATOR=True ;;
        -nk|-k|--skip-unknown) SKIP_UNKNOWN_OPT=--skip-unknown ;;
        /?|-nh|-h|--help) show_help ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Sanity Checks
if [[ -z "$PLAYDATE_SDK_PATH" ]]; then
    echo -e "${RED}PLAYDATE_SDK_PATH environment variable is not set!${CLR}"
    exit  1
elif [[ ! -d "$PLAYDATE_SDK_PATH" ]]; then
    echo -e "${RED}PLAYDATE_SDK_PATH could not be found at ${WHT}$PLAYDATE_SDK_PATH${RED}!${CLR}"
    exit  1
elif [[ ! -f "$PLAYDATE_SDK_PATH/bin/pdc" ]] && [ "$BUILD" == "True" ]; then
    echo -e "${RED}PlayDate compiler not found at ${WHT}$PLAYDATE_SDK_PATH/bin/pdc${RED}!${CLR}"
    exit  1
elif [[ ! -f "$PLAYDATE_SDK_PATH/bin/PlaydateSimulator" ]] && [ "$RUN" == "True" ]; then
    echo -e "${RED}PlayDate Simulator not found at ${WHT}$PLAYDATE_SDK_PATH/bin/PlaydateSimulator${RED}!${CLR}"
    exit  1
elif [ "$CLEAN|$BUILD|$RUN" == "True|False|True" ] ; then
    echo -e "${RED}Invalid to clean and run without building!${CLR}"
    exit  1
fi


# Clean, if told to
if [ "$CLEAN" == "True" ]; then
    if [[ -d "$OUTPUT" ]]; then
        echo -e "${YLW}Deleting old Output.pdx${CLR}"
        rm -rd $VERBOSE_OPT_RM -- "$OUTPUT"
    else
        echo -e "${YLW}Nothing to clean, skipping.${CLR}"
    fi
fi

# Build, if told to
if [ "$BUILD" == "True" ]; then
    COMPILER_VERSION=$("$PLAYDATE_SDK_PATH"/bin/pdc --version)
    echo -e "${YLW}PlayDate Compiler (${COMPILER_VERSION}) is building Output.pdx from source.${CLR}"
    "$PLAYDATE_SDK_PATH"/bin/pdc $VERBOSE_OPT_COMPILER $STRIP_OPT $SKIP_UNKNOWN_OPT "$SOURCE" "$OUTPUT"
fi

# Run, if told to
if [ "$RUN" == "True" ]; then
    if [[ -d "$OUTPUT" ]]; then

        echo -e "${YLW}Running simulator.${CLR}"

        #Couldn't find a way to make this small difference in command into a variable, so just if-else with mostly the same command
        if [ "$DETACH_SIMULATOR" == "True" ]; then
            "$PLAYDATE_SDK_PATH"/bin/PlaydateSimulator "$OUTPUT" &>/dev/null & disown
        elif [ "$VERBOSE_SIMULATOR" == "True" ]; then
            "$PLAYDATE_SDK_PATH"/bin/PlaydateSimulator "$OUTPUT"
        else
            "$PLAYDATE_SDK_PATH"/bin/PlaydateSimulator "$OUTPUT" &>/dev/null
        fi
    else
        echo -e "${YLW}Could not find the Output.pdx to run in the simulator!${CLR}"
    fi
fi

# Just in case there's a path that doesn't reset the terminal colors
echo -n -e "${CLR}"
