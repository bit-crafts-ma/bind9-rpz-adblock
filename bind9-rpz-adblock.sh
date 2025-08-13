#!/bin/bash
set -euo pipefail

URL_FILE="/opt/bind9-rpz-adblock/blocklist-urls.txt"
OUT_FILE="/opt/bind9-rpz-adblock/db.rpz"
TMP_FILE="$(mktemp /tmp/rpz.XXXXXX)"
SERIAL="$(date +%s)"

# Header RPZ
cat > "$OUT_FILE" <<EOF
\$TTL 1H
@ IN SOA localhost. root.localhost. (
  $SERIAL ; serial
  1H       ; refresh
  15M      ; retry
  30D      ; expire
  1H )     ; minimum
  IN NS localhost.
EOF

# Process each URL
while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  echo "Downloading : $url"
  if curl -sfL "$url" -o "$TMP_FILE"; then
    grep -E '^\s*(0\.0\.0\.0|127\.0\.0\.1)\s+' "$TMP_FILE" | \
    sed -E 's/^\s*(0\.0\.0\.0|127\.0\.0\.1)\s+([^ ]+).*/\2/' | \
    sort -u | while IFS= read -r domain; do
  [[ -z "$domain" ]] && continue
  if (( ${#domain} > 250 )); then
    echo "Ignored (too long): $domain" >&2
    continue
  fi
      echo "$domain CNAME ."
    done >> "$OUT_FILE"
  else
    echo "  Error downloading : $url" >&2
  fi
done < "$URL_FILE"

rm "$TMP_FILE"
echo "RPZ generated in $OUT_FILE"
cp "$OUT_FILE" /etc/bind/zones/
echo "RPZ copied to /etc/bind/zones"
sudo /usr/bin/systemctl restart named
