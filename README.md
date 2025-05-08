# impositor
Scripts to help with imposition of pdf-documents (for users of ring binders)

## Current functionality
Currently, the scripts takes a pdf-document and performs the following steps:
- cropping of whitespace (using `pdfcrop`)
- resizing to a paper size (defaulting to Junior of the Org-Verlag)
- imposition of the pages
- splitting the booklet into two different documents for manual duplex printing

## Wishlist
The following aspects are planned (or at least theorized about):
- [ ] cut marks for easier handling
- [ ] web interface for remote access