# impositor
<img src="./logo-impositor.svg" width="25%" align="right" />

Scripts to help with imposition of pdf-documents (for users of ring binders). Makes use of `pdfjam`, \LaTeX and `gs`.

## Current functionality
Currently, the scripts takes a pdf-document and performs the following steps:
- cropping of whitespace (using `pdfcrop`)
- resizing to a paper size (defaulting to Junior of the Org-Verlag)
- imposition of the pages
- splitting the booklet into two different documents for manual duplex printing

## Wishlist
The following aspects are planned (or at least thought about):
- [ ] cut marks for easier handling
- [ ] arranging multiple spreads on a single A4 (when target and source dimensions allow)
- [ ] web interface for remote access