#!/bin/bash

APK_PATH="$1"
RECORD="$2"
VIDEO_RES="$3"
BIT_RATE="$4"
TEST_PATH="$5"

adb install "$APK_PATH"

# Start screen recording with inputs for bit-rate and video resolution
if [ "$RECORD" = "true" ]; then \
  adb shell "screenrecord --bugreport --size $VIDEO_RES --bit-rate $BIT_RATE /data/local/tmp/maestro.mp4 & echo \$! > /data/local/tmp/screenrecord_pid.txt" & \
fi

# Run Maestro tests.
"$HOME/.maestro/bin/maestro" test --format junit --output "$HOME/.maestro/tests/report.xml" "$TEST_PATH" || true

# Stop screen recording and pull the video file
if [ "$RECORD" = "true" ]; then \
  adb shell "kill -2 \$(cat /data/local/tmp/screenrecord_pid.txt)" || true ; \
  sleep 1 ; \
  adb pull /data/local/tmp/maestro.mp4 /home/runner/.maestro/tests/ || true ; \
fi

# Check if there are any failed tests in the report
if grep -q 'failures="[^0]"' "$HOME/.maestro/tests/report.xml"; then
  echo "Some tests have failed. Recording the test flow..."
  
  # Extract failed test cases from the report
  failed_tests=$(grep -oP 'status="ERROR"' "$HOME/.maestro/tests/report.xml" | wc -l)
  echo "Number of failed tests: $failed_tests"
  
  # Extract the classname/id of failed tests
  grep 'status="ERROR"' "$HOME/.maestro/tests/report.xml" | grep -oP 'classname="\K[^"]+' | while read -r test_name; do
    echo "Failed test: $test_name"
    
    # Try to find the corresponding YAML file
    yaml_file="$TEST_PATH/${test_name}.yaml"
    if [ -f "$yaml_file" ]; then
      echo "Recording flow for: $yaml_file"
      "$HOME/.maestro/bin/maestro" record --local "$yaml_file" || true
    else
      echo "Warning: YAML file not found for test: $test_name"
    fi
  done
else
  echo "All tests passed successfully!"
fi