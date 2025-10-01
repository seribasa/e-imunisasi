#!/bin/bash

APK_PATH="$1"
RECORD="$2"
VIDEO_RES="$3"
BIT_RATE="$4"
TEST_PATH="$5"

adb install "$APK_PATH"

# Function to start recording
start_recording() {
    local test_name=$1
    adb shell "screenrecord --bugreport --size $VIDEO_RES --bit-rate $BIT_RATE /data/local/tmp/maestro_${test_name}.mp4 & echo \$! > /data/local/tmp/screenrecord_pid.txt"
}

# Function to stop recording and pull video
stop_recording() {
    local test_name=$1
    adb shell "kill -2 \$(cat /data/local/tmp/screenrecord_pid.txt)" || true
    sleep 1
    adb pull "/data/local/tmp/maestro_${test_name}.mp4" "$HOME/.maestro/tests/" || true
}

if [ -d "$TEST_PATH" ]; then
    # If TEST_PATH is a directory, run each .yaml file individually
    for test_file in "$TEST_PATH"/*.yaml; do
        test_name=$(basename "$test_file" .yaml)
        
        if [ "$RECORD" = "true" ]; then
            start_recording "$test_name"
        fi

        mkdir -p "$HOME/.maestro/tests"
        "$HOME/.maestro/bin/maestro" test --format junit --output "$HOME/.maestro/tests/report_${test_name}.xml" "$test_file" || true

        if [ "$RECORD" = "true" ]; then
            stop_recording "$test_name"
        fi
    done
else
    # Single test file
    test_name=$(basename "$TEST_PATH" .yaml)
    
    if [ "$RECORD" = "true" ]; then
        start_recording "$test_name"
    fi

    mkdir -p "$HOME/.maestro/tests"
    "$HOME/.maestro/bin/maestro" test --format junit --output "$HOME/.maestro/tests/report.xml" "$TEST_PATH" || true

    if [ "$RECORD" = "true" ]; then
        stop_recording "$test_name"
    fi
fi