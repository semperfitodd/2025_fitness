#!/bin/bash

TABLE_NAME="todd_2025_fitness_aggregated"
USER_EMAIL="todd@bernsonfamily.com"

correct_name="$1"
shift
incorrect_names=("$@")

total_reps=0
total_volume=0

echo "🔍 Scanning records to merge into '$correct_name'..."

# Fetch and sum incorrect entries
for name in "${incorrect_names[@]}"; do
  echo "Fetching $name..."
  item=$(aws dynamodb get-item \
    --table-name "$TABLE_NAME" \
    --key "{\"user\": {\"S\": \"$USER_EMAIL\"}, \"exercise_name\": {\"S\": \"$name\"}}" \
    --output json)

  reps=$(echo "$item" | jq -r '.Item.total_reps.N // "0"')
  volume=$(echo "$item" | jq -r '.Item.total_volume.N // "0"')

  total_reps=$((total_reps + reps))
  total_volume=$((total_volume + volume))
done

# Get current correct entry if it exists
echo "Fetching existing correct record: $correct_name..."
existing=$(aws dynamodb get-item \
  --table-name "$TABLE_NAME" \
  --key "{\"user\": {\"S\": \"$USER_EMAIL\"}, \"exercise_name\": {\"S\": \"$correct_name\"}}" \
  --output json)

existing_reps=$(echo "$existing" | jq -r '.Item.total_reps.N // "0"')
existing_volume=$(echo "$existing" | jq -r '.Item.total_volume.N // "0"')

# Add existing values
total_reps=$((total_reps + existing_reps))
total_volume=$((total_volume + existing_volume))

# Fetch current total_lifted before update
before_total=$(aws dynamodb get-item \
  --table-name "$TABLE_NAME" \
  --key "{\"user\": {\"S\": \"$USER_EMAIL\"}, \"exercise_name\": {\"S\": \"total_lifted\"}}" \
  --output json | jq -r '.Item.total_volume.N // "0"')

echo "📊 total_lifted BEFORE: $before_total"

# Put updated correct record
echo "💾 Writing updated record for '$correct_name' with $total_reps reps, $total_volume volume..."
aws dynamodb put-item \
  --table-name "$TABLE_NAME" \
  --item "{
    \"user\": {\"S\": \"$USER_EMAIL\"},
    \"exercise_name\": {\"S\": \"$correct_name\"},
    \"total_reps\": {\"N\": \"$total_reps\"},
    \"total_volume\": {\"N\": \"$total_volume\"}
  }"

# Delete the bad records
for name in "${incorrect_names[@]}"; do
  echo "🧹 Deleting $name..."
  aws dynamodb delete-item \
    --table-name "$TABLE_NAME" \
    --key "{\"user\": {\"S\": \"$USER_EMAIL\"}, \"exercise_name\": {\"S\": \"$name\"}}"
done

# Recalculate total_lifted by summing all exercises (excluding 'total_lifted')
echo "🔄 Recalculating total_lifted..."

scan_output=$(aws dynamodb scan \
  --table-name "$TABLE_NAME" \
  --filter-expression "#u = :u AND NOT exercise_name = :t" \
  --expression-attribute-names '{"#u": "user"}' \
  --expression-attribute-values '{
    ":u": {"S": "'"$USER_EMAIL"'"},
    ":t": {"S": "total_lifted"}
  }' \
  --output json)

# Safe default to 0 if there's nothing to sum
new_total=$(echo "$scan_output" | jq '[.Items[].total_volume.N | tonumber] | add // 0')

# Validate numeric
if ! [[ "$new_total" =~ ^[0-9]+$ ]]; then
  echo "❌ ERROR: Failed to calculate total_lifted. Check scan result."
  echo "$scan_output"
  exit 1
fi

# Update total_lifted record
aws dynamodb put-item \
  --table-name "$TABLE_NAME" \
  --item "{
    \"user\": {\"S\": \"$USER_EMAIL\"},
    \"exercise_name\": {\"S\": \"total_lifted\"},
    \"total_volume\": {\"N\": \"$new_total\"}
  }"

echo "📊 total_lifted AFTER: $new_total"

# Validate
if [ "$before_total" == "$new_total" ]; then
  echo "✅ total_lifted is unchanged. All good!"
else
  echo "⚠️ WARNING: total_lifted mismatch! Was $before_total, now $new_total"
fi
