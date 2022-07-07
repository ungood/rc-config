#!/bin/bash

INPUT_FILE=sounds.csv
OUTPUT_DIR=tx16s/SOUNDS/en
mkdir -p "$OUTPUT_DIR/SYSTEM"

generate_lang () {
  while read line; do
      [[ "$line" =~ ^#.*$ ]] && continue

      destination=`echo -n $line | awk -F ';' '{print $1}'`
      filename=`echo -n $line | awk -F ';' '{print $2}'`
      dest_file=$OUTPUT_DIR/$destination/$filename
      text=`echo -n $line | awk -F ';' '{print $3}'`
      if test -f $dest_file; then
          echo "File $dest_file already exists. Skipping."
      else
          echo "File $dest_file does not exists. Creating."
          spx synthesize --text \""$text"\" --voice $2 --audio output $dest_file --log /tmp/spx.log || break
          sleep 3
      fi
  done < $1
}

generate_lang $INPUT_FILE en-US-JennyNeural en

# make normalized folders
find $OUTPUT_DIR -type d | xargs -I % mkdir -p normalized/%

# normalize each file and replace source
for file in $(find $OUTPUT_DIR -type f)
do
    ffmpeg/bin/ffmpeg -i $file -af "volume=6.0dB,silenceremove=start_periods=1:start_silence=0.1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:start_silence=0.1:start_threshold=-50dB,areverse" normalized/$file && \
    mv -f normalized/$file $file
done