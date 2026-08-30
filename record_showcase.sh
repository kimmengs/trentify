#!/bin/bash
set -e

SIM_ID="321FE4EC-1F50-46F5-BC03-5B9A1C2EDED3"
VIDEO_OUT="/Users/meng/Desktop/CODE/BUZSIC/trentify/webuy_uat_demo_showcase.mp4"
FLUTTER_BIN="/Users/meng/develop/flutter/bin/flutter"

echo "=== [1/4] Setting Clean Status Bar (9:41 AM, 100% Battery, Full Wi-Fi) ==="
xcrun simctl status_bar "$SIM_ID" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3 || true

echo "=== [2/4] Starting 60fps Native Screen Recording ==="
xcrun simctl io "$SIM_ID" recordVideo --codec=h264 -f "$VIDEO_OUT" &
REC_PID=$!
echo "Recorder running with PID: $REC_PID"

echo "=== [3/4] Launching Showcase App on Simulator ==="
$FLUTTER_BIN run -t lib/demo_showcase.dart -d "$SIM_ID" > /tmp/flutter_demo.log 2>&1 &
FLUTTER_PID=$!
echo "Flutter running with PID: $FLUTTER_PID"

echo "Recording showcase timeline in progress (85 seconds)..."
sleep 85

echo "=== [4/4] Finalizing Video Recording ==="
kill -INT $REC_PID 2>/dev/null || true
wait $REC_PID 2>/dev/null || true

echo "Terminating flutter app instance..."
kill -TERM $FLUTTER_PID 2>/dev/null || true

echo "=== Video Showcase Recording Complete! ==="
ls -lh "$VIDEO_OUT"
