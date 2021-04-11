#!/usr/bin/env bash

cat > /dev/null <<\EOF

MIT License

Copyright (c) 2021 Natanael Barbosa Santos

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

EOF


[ ! -f "${1}" ] && {
  echo "You must pass an image file as an argument: "
  echo
  echo "  ${0} image.ext"
  echo
  exit 1
}

identify "${1}" 2>&1 > /dev/null

[ ! -f "${1}" ] && {
  echo "This file is not a valid image"
  exit 1
}

ImageColors=$(convert "${1}" -scale "50x50!" -depth 8 +dither \
                       -colors 8 -format "%c" histogram:info: | 
                                     sed 's|^[[:space:]]*||g' )

[ ! -f "${1}" ] && {
  echo "An error has occurred when processing the image"
  exit 1
}                 
                                     
ImageColors=$(echo -e "0: (127, 127, 127) #7F7F7F srgb(127,127,127)\n${ImageColors}")
ImageColors=$(echo "${ImageColors}" | sed 's| srgb.*||g;s|: (|(|g;s| ||g;s|,|+|g')
ImageColors=$(echo "${ImageColors}" | sed 's|^|echo "|g;s|(| $((|g;s|#|) |g;s|$|"|g' | sh)
ImageColors=$(echo "${ImageColors}" | awk '{print $2,$1,$3}' | sort -V)

ReferenceLine=$(echo "${ImageColors}" | grep -m1 -n ^"381 " | cut -d: -f1)

ImageColors=$(echo "${ImageColors}" | cut -d' ' -f3 | sed 's|^|#|g')

DarkerColors=$(echo "${ImageColors}" | sed -n "1,$(( ${ReferenceLine}-1 ))p")
EnlightenedColors=$(echo "${ImageColors}" | sed -n "$(( ${ReferenceLine} +1)),\$p")

echo "darker:"
echo "${DarkerColors}" | sed 's|^|  - |g'
echo "enlightened:"
echo "${EnlightenedColors}" | sed 's|^|  - |g'
