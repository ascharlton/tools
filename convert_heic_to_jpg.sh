
mkdir jpg_output
for f in *.HEIC; do
  sips -s format jpeg "$f" --out "jpg_output/${f%.*}.jpg"
done
