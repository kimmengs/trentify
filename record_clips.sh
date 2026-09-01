#!/bin/bash
set -e

SIM_ID="7E7929CC-4FAC-4FB4-B10E-6BF7F233F92C"
FLUTTER_BIN="/Users/meng/develop/flutter/bin/flutter"
BASE_DIR="/Users/meng/Desktop/CODE/BUZSIC/trentify"

echo "======================================================="
echo "🎥 WEBUY UAT • PROFESSIONAL BUYER DEMO RECORDINGS"
echo "======================================================="

# Set clean luxury status bar
echo "Setting 9:41 AM 100% Battery Clean Status Bar..."
xcrun simctl status_bar "$SIM_ID" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 || true
open -a Simulator

record_clip() {
  local CLIP_NUM=$1
  local DART_TARGET=$2
  local OUTPUT_FILE=$3
  local DURATION=$4
  local TITLE=$5

  echo ""
  echo "-------------------------------------------------------"
  echo "🎬 Recording Clip $CLIP_NUM: $TITLE"
  echo "-------------------------------------------------------"
  echo "Output: $OUTPUT_FILE"

  # Remove old file if exists
  rm -f "$OUTPUT_FILE"

  # Start simulator native video recorder
  xcrun simctl io "$SIM_ID" recordVideo --codec=h264 -f "$OUTPUT_FILE" &
  REC_PID=$!
  echo "Native Screen Recorder running (PID: $REC_PID)"

  # Run Flutter Showcase Target
  $FLUTTER_BIN run -t "$DART_TARGET" -d "$SIM_ID" > "/tmp/flutter_clip${CLIP_NUM}.log" 2>&1 &
  FLUTTER_PID=$!
  echo "Flutter Showcase running (PID: $FLUTTER_PID)"

  echo "Capturing timeline ($DURATION seconds)..."
  sleep "$DURATION"

  echo "Stopping screen recorder..."
  kill -INT $REC_PID 2>/dev/null || true
  wait $REC_PID 2>/dev/null || true

  echo "Terminating flutter instance..."
  kill -TERM $FLUTTER_PID 2>/dev/null || true
  pkill -f "showcase_clip${CLIP_NUM}.dart" 2>/dev/null || true

  echo "✅ Clip $CLIP_NUM Complete:"
  ls -lh "$OUTPUT_FILE"
}

# 1. Clip 1: Purchase Journey
record_clip "1" "lib/showcase_clip1.dart" "$BASE_DIR/buyer_clip1_purchase_flow.mp4" 42 "Buyer Login, View Product, Add to Cart, Purchase"

# 2. Clip 2: Wishlist & Payment Flow
record_clip "2" "lib/showcase_clip2.dart" "$BASE_DIR/buyer_clip2_wishlist_payment_flow.mp4" 42 "Buyer Login, Wishlist, Sort/Filter, Bag to Payment"

# 3. Clip 3: My Orders & Tracking Flow
record_clip "3" "lib/showcase_clip3.dart" "$BASE_DIR/buyer_clip3_order_tracking_flow.mp4" 38 "Buyer Login, My Orders, Live Tracking Status"

echo ""
echo "======================================================="
echo "🎉 ALL 3 BUYER DEMO CLIPS RECORDED SUCCESSFULLY!"
echo "======================================================="
ls -lh "$BASE_DIR"/buyer_clip*.mp4
