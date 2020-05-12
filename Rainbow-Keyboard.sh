#!/bin/sh
#Estym 2020


# GLOBAL VARIABLES
HUE=0
A=255
B=0
C=0
LAST="FF0000"
SLAST="FF0000"
HUE_INCREASE="5"
SPEED="1"
MODE="normal" #normal, gaming


# A fonctionning function for HUE TO RGB
HUE2RGB() {
    C=255
    TMP=$(echo "($HUE%60)" | bc)
    TMP=$(echo "scale=2;255*($TMP/60)" | bc)
    X=${TMP%.*}

    if [ "$HUE" -lt "$((60))" ]; then
        TR=$C
        TG=$X
        TB=0
    elif [ "$HUE" -lt "$((120))" ]; then
        TR=$((255-$X))
        TG=$C
        TB=0
    elif [ "$HUE" -lt "$((180))" ]; then
        TR=0
        TG=$C
        TB=$X
    elif [ "$HUE" -lt "$((240))" ]; then
        TR=0
        TG=$((255-$X))
        TB=$C
    elif [ "$HUE" -lt "$((300))" ]; then
        TR=$X
        TG=0
        TB=$C
    else
        TR=$C
        TG=0
        TB=$((255-$X))
    fi
    A=$(($TR))
    B=$(($TG))
    C=$(($TB))
}

ERROR(){
    echo "Please install msiklm : https://github.com/Gibtnix/MSIKLM"
    exit 1
}

# Main process
MAIN() {
    if sudo msiklm $MODE; then
        while (true) 
        do
            #Setting the Current Color
            CURRENT="$(printf %02X%02X%02X $A $B $C)"
            if [ "$MODE" = "gaming" ]; then
                sudo msiklm 0x$CURRENT $MODE
            elif [ "$MODE" = "normal" ]; then
                sudo msiklm 0x$CURRENT,0x$SLAST,0x$CURRENT
            else
                ERROR
            fi
            #Shift the color to the right
            LAST=$SLAST
            SLAST=$CURRENT
                
            #Some delay
            sleep $(echo "scale=2;$SPEED/1000" | bc)
            #Increasing the hue
            HUE=$(($(($HUE+$HUE_INCREASE))%360))

            #Processing the new color from the hue
            HUE2RGB
        done
    else
        ERROR
    fi
}

# Argument Parsing
while getopts i:s:m:h o
    do	case "$o" in   
	    i)	    HUE_INCREASE=$OPTARG
                if [ $HUE_INCREASE -lt $((0)) -o $HUE_INCREASE -gt $((360)) ]; then
                    printf "\nInvalid value.\nCorrect values : [0-360]\n\n"
                    exit 1
                fi;;
	    s)	    SPEED=$OPTARG
                if [ $SPEED -lt $((0)) ]; then
                    printf "\nInvalid value.\nCorrect Value : Any positive integer\n\n"
                    exit 1
                fi;;
        m)      MODE="$OPTARG"
                if [ "$MODE" != "gaming" -a "$MODE" != "normal" ]; then
                    printf "\nInvalid mode.\nCorrect modes : [normal, gaming]\n\n"
                    exit 1
                fi;;
        h)      printf "\n-s VALUE : Set the delay between Color Change in milliseconds\n-i VALUE : Set the increment of the Hue [0-360]\n-m MODE : Set the mode in which you want your keyboard to be [normal, gaming]\n\n"
                exit 0;;
	    [?])	printf "\nUsage: $0 [-s SPEED] [-i VALUE] [-m MODE] [-h]\n\n"
		        exit 1;;
	    esac
done

MAIN
