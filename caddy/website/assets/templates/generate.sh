#!/bin/sh

if [ ! -f ./generate ]; then
    echo "Please run the script from its own directory.";
    exit 1;
fi

if [ -d ../sources-temp ]; then
    rm -vr ../sources-temp | exit;
fi

mkdir -v ../sources-temp | exit;

for FILE in ../sources/*-wrap.html; do
    echo "Processing $FILE";
    RAWNAME=$(basename "$FILE")
    RAWNAME=${RAWNAME%-wrap.html}
    cat "$FILE" | awk '{
        if (match($0, /<.*>/)) {
            pre  = substr($0, 1, RSTART - 1)
            mid  = substr($0, RSTART, RLENGTH)
            post = substr($0, RSTART + RLENGTH)
            gsub(/ /, "©", mid)
            line = pre mid post
        } else {
            line = $0
        }
		if (NR > 1){
			printf "\n"
		}
        printf "%s", line
    }' | fmt -s -w 54 | awk '{
        gsub(/©/, " ")
        gsub(/  /, "\&nbsp;\&nbsp;")
		if (NR > 1){
			printf "\n"
		}
        printf "%s", $0
    }' > "../sources-temp/${RAWNAME}.html"
done

for FILE in ../sources/*-pure.html; do
    echo "Processing $FILE";
    RAWNAME=$(basename "$FILE")
    RAWNAME=${RAWNAME%-pure.html}
    cat "$FILE" | awk '{
        gsub(/  /, "\&nbsp;\&nbsp;")
		if (NR > 1){
			printf "\n"
		}
        printf "%s", $0
    }' > "../sources-temp/${RAWNAME}.html"
done

rm -v ../*.html

echo "Generating all pages...";
./generate ../sources-temp generic.html ../ | exit;

echo "Generating special pages...";
./generate ../sources-temp/homepage.html index.html ../index.html | exit;

rm -vr ../sources-temp | exit;

echo "Done.";
exit 0;