#!/bin/bash

STATUS=$(playerctl status 2>/dev/null)
if [[ "$STATUS" != "Playing" && "$STATUS" != "Paused" ]]; then
    exit 0
fi

if [ "$1" == "--icon-prev" ]; then
    echo "󰒮"
    exit 0
fi

if [ "$1" == "--icon-next" ]; then
    echo "󰒭"
    exit 0
fi

INFO=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)

if [ -z "$INFO" ] || [ "$INFO" = " - " ]; then
    echo "Reproduciendo..."
    exit 0
fi

TEXTO="$INFO   ♫   "
ANCHO_MAX=15
TOTAL_CHARS=$(echo -n "$TEXTO" | wc -m)

if [ "$TOTAL_CHARS" -le "$ANCHO_MAX" ]; then
    IMPRESION="$INFO"
else
    SEGUNDO_ACTUAL=$(date +%s)
    START=$(( SEGUNDO_ACTUAL % TOTAL_CHARS ))
    TEXTO_DOBLE="${TEXTO}${TEXTO}"
    IMPRESION=$(echo "$TEXTO_DOBLE" | cut -c $((START + 1))-$((START + ANCHO_MAX)))
fi

r1=211; g1=211; b1=211
r2=211; g2=211; b2=211

LEN=$(echo -n "$IMPRESION" | wc -m)
OUTPUT=""

for ((i=0; i<LEN; i++)); do
    CHAR="${IMPRESION:$i:1}"
    
    if [ $LEN -gt 1 ]; then
        FACTOR=$(( i * 100 / (LEN - 1) ))
    else
        FACTOR=0
    fi
    
    R=$(( r1 + (r2 - r1) * FACTOR / 100 ))
    G=$(( g1 + (g2 - g1) * FACTOR / 100 ))
    B=$(( b1 + (b2 - b1) * FACTOR / 100 ))
    
    HEX=$(printf "#%02x%02x%02x" $R $G $B)
    
    if [ "$CHAR" = "&" ]; then CHAR="&amp;"
    elif [ "$CHAR" = "<" ]; then CHAR="&lt;"
    elif [ "$CHAR" = ">" ]; then CHAR="&gt;"
    fi
    
    OUTPUT="${OUTPUT}<span foreground='${HEX}'>${CHAR}</span>"
done

echo -e "$OUTPUT"

