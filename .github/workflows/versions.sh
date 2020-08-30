#!/bin/bash

OUTPUT=$(mktemp)

echo "{}" > $OUTPUT

add() {
  NAME=$1
  URL=$2
  HASH=`docker manifest inspect --verbose $URL | jq '.Descriptor.digest' -r`
  jq ". += { \"$NAME\": { \"url\": \"$URL\", \"hash\": \"$HASH\" }}" $OUTPUT | sponge $OUTPUT
}

add "quic-network-simulator" "martenseemann/quic-network-simulator"
add "quic-interop-iperf-endpoint" "martenseemann/quic-interop-iperf-endpoint"

for ROW in $(jq -r 'to_entries[] | [.key, .value.url] | @base64' implementations.json); do
  NAME=`echo $ROW | base64 --decode | jq -r '.[0]'`
  URL=`echo $ROW | base64 --decode | jq -r '.[1]'`
  add $NAME $URL
done

cat $OUTPUT | jq '.'
