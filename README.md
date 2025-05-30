# impositor
<img src="./src/logo-impositor.svg" width="25%" style="padding: 0 1ex 0 2em" align="right" />

Impositor consists of scripts to help with imposition of pdf-documents. Imposition is the process of arranging and ordering several pages of one document on one sheet for printing. In my case I mostly use it to create a "booklet" in correct sizes for cutting down in order to fit paper planners. There are plenty solutions out on the market but I needed a solution that met my requirements. The script had to be 
1. *flexible* enough to easily support non-standard page dimensions and
2. *portable* in order to be usable on a mobile device (in my case: on an Android phone, with Termux installed).

Impositor is basically a wrapper that makes heavy use of `pdfjam`, `pdfbook`, $\LaTeX$ and `gs`. All those need to be installed on your system, otherwise impositor will fail.
## Usage

Usage: 
```bash
make-booklet.sh input.pdf [preset]
```

Currently predefined presets:

- `org` – for the *Junior* size of the ring books from [Org-Verlag](https://org-verlag.de/)
- `A5` – for A5-sized ring binders from Filofax and others
## Current functionality
Currently, the scripts takes a pdf-document and performs the following steps:
- cropping of whitespace (using ~~`pdfcrop`~~ `pdfcropmargin`)
- resizing to a paper size using `pdfjam` (defaulting to the *Junior*-paper size of the *Org-Verlag*)
- imposition of the pages (using `pdfbook`)
- splitting and reordering the booklet into two different documents for manual duplex printing (using `gs`, followed by `pdfjam`)

Using all those steps is certainly not the most efficient method if everything works as expected – but significantly less error prone, if things go wrong during any of the steps. Additionally, if errors do occur, identifying the failing step and rectifying the problem is much easier, especially when using the on-screen keyboard of a mobile phone...

## Wishlist
The following aspects are planned (or at least thought about):
- [X] cut marks for easier handling
- [X] clean-up of temporay files (https://github.com/thomas-selig/impositor/commit/b748a8b2abbb53dfcac0a2a18f0ac35cdff124ab)
- [ ] cropping of PDF-files (beyond clipping to bounding box)
  - We are trying with `pdfCropMargins`
- [ ] arranging multiple spreads on a single A4 (when target and source dimensions allow)
- [ ] web interface for remote access