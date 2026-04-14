#!/usr/bin/env bash

set -euo pipefail

BUCKET_NAME=$1

echo "Emptying bucket: $BUCKET_NAME"

echo "Deleting ALL object versions..."
aws s3api list-object-versions \
  --bucket "$BUCKET_NAME" \
  --output json \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
| jq -c '.Objects // [] | {Objects: .}' \
| while read -r batch; do
    if [[ "$batch" != '{"Objects":[]}' ]]; then
        aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$batch"
    fi
done

echo "Deleting ALL delete markers..."
aws s3api list-object-versions \
  --bucket "$BUCKET_NAME" \
  --output json \
  --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
| jq -c '.Objects // [] | {Objects: .}' \
| while read -r batch; do
    if [[ "$batch" != '{"Objects":[]}' ]]; then
        aws s3api delete-objects --bucket "$BUCKET_NAME" --delete "$batch"
    fi
done

echo "Removing any remaining current objects..."
aws s3 rm "s3://$BUCKET_NAME" --recursive || true

echo "Bucket is now empty ✅"
