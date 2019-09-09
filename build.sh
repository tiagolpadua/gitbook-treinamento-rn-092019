docker run --rm -v "$PWD:/gitbook" -p 4000:4000 billryan/gitbook gitbook install && gitbook pdf
filename=apostila-comaer-mongo-$(date -d "today" +"%Y%m%d%H%M").pdf
mv book.pdf build/$filename
xdg-open build/$filename &
