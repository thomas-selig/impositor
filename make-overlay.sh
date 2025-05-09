#!/bin/bash
# make-overlay.sh --spread=297x210 --page=95x148 --input=booklet.pdf

# Default values
SPREAD_W=297
SPREAD_H=210
PAGE_W=95
PAGE_H=148
INPUT=""
OVERLAY_PDF="overlay.pdf"
OUTPUT="booklet-marked.pdf"

# Parse arguments
for arg in "$@"; do
  case $arg in
    --spread=*)
      SPREAD=$(echo "${arg#*=}")
      SPREAD_W=${SPREAD%x*}
      SPREAD_H=${SPREAD#*x}
      ;;
    --page=*)
      PAGE=$(echo "${arg#*=}")
      PAGE_W=${PAGE%x*}
      PAGE_H=${PAGE#*x}
      ;;
    --input=*)
      INPUT="${arg#*=}"
      ;;
    --output=*)
      OUTPUT="${arg#*=}"
      ;;
  esac
done

TEXFILE="overlay.tex"

# Generate overlay LaTeX file with correct mark alignment
cat <<EOF > "$TEXFILE"
\documentclass{article}
\usepackage[paperwidth=${SPREAD_W}mm,paperheight=${SPREAD_H}mm,margin=0mm]{geometry}
\usepackage{tikz}
\pagestyle{empty}

\newcommand{\pagewidth}{${PAGE_W}}
\newcommand{\pageheight}{${PAGE_H}}
\newcommand{\spreadwidth}{${SPREAD_W}}
\newcommand{\spreadheight}{${SPREAD_H}}

\begin{document}
\begin{tikzpicture}[remember picture, overlay, line width=0.3pt]

% Calculated positions
\pgfmathsetmacro{\topY}{(\spreadheight - \pageheight) / 2}
\pgfmathsetmacro{\bottomY}{\topY + \pageheight}
\pgfmathsetmacro{\centerX}{\spreadwidth / 2}
\pgfmathsetmacro{\leftX}{\spreadwidth / 2 - \pagewidth}
\pgfmathsetmacro{\rightX}{\spreadwidth / 2 + \pagewidth}

% Draw top cut marks
\foreach \x in {\leftX, \centerX, \rightX} {
  \draw (\x,\topY) -- (\x,{\topY + 5});
}

% Draw bottom cut marks
\foreach \x in {\leftX, \centerX, \rightX} {
  \draw (\x,\bottomY) -- (\x,{\bottomY - 5});
}

% Draw side marks (horizontal, near page corners)
\foreach \y in {\topY, \bottomY} {
  % left page outer edge
  \draw ({\leftX},\y) -- ({\leftX + 5},\y);
  % left page inner edge
  \draw ({\centerX},\y) -- ({\centerX - 5},\y);
  % right page inner edge
  \draw ({\centerX},\y) -- ({\centerX + 5},\y);
  % right page outer edge
  \draw ({\rightX},\y) -- ({\rightX - 5},\y);
}

\end{tikzpicture}
\null
\end{document}
EOF

# Compile LaTeX and show any errors
pdflatex -interaction=nonstopmode "$TEXFILE" || {
  echo "❌ pdflatex failed. Check overlay.tex for errors."
  exit 1
}

# Overlay if input PDF provided
if [[ -n "$INPUT" ]]; then
  echo "📄 Overlaying marks onto $INPUT → $OUTPUT"
  pdfjam "$INPUT" "$OVERLAY_PDF" --outfile "$OUTPUT" --pages 1- || {
    echo "❌ pdfjam overlay failed."
    exit 1
  }
  echo "✅ Done: $OUTPUT"
fi

# Clean up
#rm -f overlay.aux overlay.log overlay.tex
