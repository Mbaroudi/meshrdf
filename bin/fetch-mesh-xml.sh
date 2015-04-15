#!/bin/sh


# Validate UNIX like environment

which sed >& /dev/null
if [ $? -ne 0 ]; then
    echo "error: this script requires the UNIX sed utility" 1>&2
    exit 1
fi

which grep >& /dev/null
if [ $? -ne 0 ]; then
    echo "error: this script requires the UNIX grep utility" 1>&2
    exit 1
fi

which wget >& /dev/null
if [ $? -ne 0 ]; then
    echo "error: this script requires the UNIX wget utility" 1>&2
    exit 1
fi

# Determine year and directory for MESH data

if [ -z "$MESHRDF_HOME" ]; then
    MESHRDF_HOME=.
fi
if [ -z "$MESHRDF_YEAR" ]; then
    MESHRDF_YEAR=2014
fi

# Create directory 

mkdir -p "$MESHRDF_HOME/data"

# Get the list of files to download

wget "ftp://ftp.nlm.nih.gov/online/mesh/$MESHRDF_YEAR/" -O "$MESHRDF_HOME/data/index.html"

sed -f - "$MESHRDF_HOME/data/index.html" > "$MESHRDF_HOME/data/filelist" <<SCRIPT
1,/<pre>/ d
/<\/pre>/,$ d
s,^.*<a href=",,
s,".*$,,
s,ftp://ftp.nlm.nih.gov:21/online/mesh/$MESHRDF_YEAR/,,
SCRIPT
FILES=`grep -E '\.(xml|dtd)$' "$MESHRDF_HOME/data/filelist"`
rm -f "$MESHRDF_HOME/data/index.html" "$MESHRDF_HOME/data/filelist" >& /dev/null


# Download each of these files

for file in $FILES; do 
    wget "ftp://ftp.nlm.nih.gov/online/mesh/$MESHRDF_YEAR/$file" -O "$MESHRDF_HOME/data/$file"
done

