#!/bin/bash
# make-booklet.sh
# Usage: make-booklet.sh input.pdf [preset]

INPUT="$1"
PRESET="${2:-org}"
BASENAME=$(basename "$INPUT" .pdf)
# DIR=$(dirname "$(realpath "$INPUT")")
DIR=$(dirname "$INPUT")

# Crop whitespace
#################
CROPPED="${DIR}/${BASENAME}-cropped.pdf"
echo "Cropping whitespace..."
pdfcrop "$INPUT" "$CROPPED" --resolution 72

# Step 1: Apply margin and set page size
########################################
FIXED="${DIR}/${BASENAME}-fixed.pdf"
SCALED="${DIR}/${BASENAME}-scaled.pdf"

echo "Formatting to fixed size (preset: $PRESET)..."

case "$PRESET" in
  org)
    PAGE_WIDTH="95"
    PAGE_HEIGHT="148"
    INSET="2.5"
    BINDING_EDGE="5"
    ;;
  a5)
    PAGE_WIDTH="148mm"
    PAGE_HEIGHT="210mm"
    OFFSET="10mm 10mm"
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

BOOKLET="${DIR}/${BASENAME}-book.pdf"
  
pdfbook --short-edge --scale 1 --noautoscale true --delta "${BINDING_EDGE}mm 0mm" "$FIXED" --outfile "$BOOKLET"
    
echo "✅ Created booklet → $BOOKLET"

echo "🖨️ Creating files for manual duplex printing..."

EVEN="${DIR}/${BASENAME}-duplex1.pdf"
ODD="${DIR}/${BASENAME}-duplex2.pdf"

EVEN_TMP="${DIR}/${BASENAME}-even-tmp.pdf"

gs -sDEVICE=pdfwrite -sPageList=odd -sOutputFile="$ODD" -dBATCH -dNOPAUSE -dAutoRotatePages=/None "$BOOKLET"

gs -sDEVICE=pdfwrite -sPageList=even -sOutputFile="$EVEN_TMP" -dBATCH -dNOPAUSE -dAutoRotatePages=/None "$BOOKLET"

pdfjam "$EVEN_TMP" 'last-1' --outfile "$EVEN" --landscape --scale 1 --noautoscale true 

echo "✅ Manual duplex files:"
echo "→ Front side: $ODD"
echo "→ Back side:  $EVEN"
