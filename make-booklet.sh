#!/bin/bash
# make-booklet.sh
# Usage: make-booklet.sh input.pdf [preset]

INPUT="$1"
PRESET="${2:-org}"
BASENAME=$(basename "$INPUT" .pdf)
PAPER_WIDTH=297
PAPER_HEIGHT=210
declare -a TO_CLEAN=()

# DIR=$(dirname "$(realpath "$INPUT")")
DIR=$(dirname "$INPUT")

# Crop whitespace
#################
CROPPED="${DIR}/${BASENAME}-cropped.pdf"
echo "Cropping whitespace..."
pdfcrop "$INPUT" "$CROPPED" --resolution 72
TO_CLEAN+=( "$CROPPED" )

# Apply margin and set page size
########################################
FIXED="${DIR}/${BASENAME}-fixed.pdf"
SCALED="${DIR}/${BASENAME}-scaled.pdf"
TO_CLEAN+=( "$FIXED" )
TO_CLEAN+=( "$SCALED" )

echo "Formatting to fixed size (preset: $PRESET)..."

case "$PRESET" in
  org)
    PAGE_WIDTH="95"
    PAGE_HEIGHT="148"
    INSET="2.5"
    BINDING_EDGE="8"
    ;;
  a5)
    PAGE_WIDTH="148"
    PAGE_HEIGHT="210"
    OFFSET="10 10"
    BINDING_EDGE="5"
    ;;
  *)
    echo "Unknown preset: $PRESET"
    exit 1
    ;;
esac

SCALED_WIDTH=$(echo "$PAGE_WIDTH - 2 * $INSET - $BINDING_EDGE" | bc)
SCALED_HEIGHT=$(echo "$PAGE_HEIGHT - 2 * $INSET" | bc)

echo "Target dimensions: ${SCALED_WIDTH} x $SCALED_HEIGHT"

pdfjam "$CROPPED" --papersize "{${SCALED_WIDTH}mm,${SCALED_HEIGHT}mm}" --twoside  --scale 1 --clip true --outfile "$SCALED"

pdfjam "$SCALED" --papersize "{${PAGE_WIDTH}mm,${PAGE_HEIGHT}mm}" --twoside  --scale 1 --clip true --outfile "$FIXED"

# Create booklet
################
BOOKLET="${DIR}/${BASENAME}-book.pdf"
TO_CLEAN+=( "$BOOKLET" )
  
pdfbook --short-edge --scale 1 --noautoscale true --delta "${BINDING_EDGE}mm 0mm" "$FIXED" --outfile "$BOOKLET"
    
echo "✅ Created booklet → $BOOKLET"

# Create PDF with cut marks
###########################
pdflatex -interaction=nonstopmode -output-directory=./src \
  "\
\def\pw{$PAGE_WIDTH}\
\def\ph{$PAGE_HEIGHT}\
\def\m{5}\
\def\sheetW{$PAPER_WIDTH}\
\def\sheetH{$PAPER_HEIGHT}\
\input{src/overlay.tex}"

TO_CLEAN+=( "./src/overlay.aux" )
TO_CLEAN+=( "./src/overlay.log" )
TO_CLEAN+=( "./src/overlay.pdf" )

# Overlay cut marks
###################
BOOKLET_CUTMARKS="${DIR}/${BASENAME}-book-cutmarks.pdf"
echo "### BOOKLET_CUTMARKS=${BOOKLET_CUTMARKS}"
echo "### BOOKLET=${BOOKLET}"
pdftk "${BOOKLET}" stamp "./src/overlay.pdf" output "${BOOKLET_CUTMARKS}" 
TO_CLEAN+=( "$BOOKLET_CUTMARKS" )

# Seperate for duplex printing
##############################
echo "🖨️ Creating files for manual duplex printing..."

EVEN="${DIR}/${BASENAME}-duplex1.pdf"
ODD="${DIR}/${BASENAME}-duplex2.pdf"
EVEN_TMP="${DIR}/${BASENAME}-even-tmp.pdf"

TO_CLEAN+=( "$EVEN_TMP" )

gs -sDEVICE=pdfwrite -sPageList=odd -sOutputFile="$ODD" -dBATCH -dNOPAUSE -dAutoRotatePages=/None "$BOOKLET_CUTMARKS"

gs -sDEVICE=pdfwrite -sPageList=even -sOutputFile="$EVEN_TMP" -dBATCH -dNOPAUSE -dAutoRotatePages=/None "$BOOKLET_CUTMARKS"

pdfjam "$EVEN_TMP" 'last-1' --outfile "$EVEN" --landscape --scale 1 --noautoscale true 

echo "✅ Manual duplex files:"
echo "→ Front side: $ODD"
echo "→ Back side:  $EVEN"

TO_CLEAN+=( "$CROPPED" )

# Clean up
##########
if (( ${#TO_CLEAN[@]} )); then
  echo "Cleaning up ${#TO_CLEAN[@]} temporary files…"
  rm -f "${TO_CLEAN[@]}"
fi
