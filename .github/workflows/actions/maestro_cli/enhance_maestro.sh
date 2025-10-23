#!/bin/bash

APK_PATH="$1"
RECORD="$2"
VIDEO_RES="$3"
BIT_RATE="$4"
TEST_PATH="$5"

# Function to start recording
start_recording() {
    local test_name=$1
    # Clean up any existing recording process
    adb shell "pkill -f screenrecord" 2>/dev/null || true
    sleep 1
    
    # Start recording in background using nohup to ensure it keeps running
    adb shell "nohup screenrecord --bugreport --size $VIDEO_RES --bit-rate $BIT_RATE /data/local/tmp/maestro_${test_name}.mp4 > /dev/null 2>&1 &"
    
    # Give it time to start properly
    sleep 2
    
    # Verify recording started
    if adb shell "pgrep -f screenrecord" > /dev/null; then
        echo "Recording started successfully for $test_name"
    else
        echo "Warning: Recording may not have started properly"
    fi
}

# Function to stop recording and pull video
stop_recording() {
    local test_name=$1
    
    # Send SIGINT (Ctrl+C) to gracefully stop recording
    adb shell "pkill -SIGINT screenrecord" || true
    
    # Wait longer for the recording to finalize and write to disk
    echo "Waiting for recording to finalize..."
    sleep 5
    
    # Verify file exists and has size
    local file_size=$(adb shell "ls -l /data/local/tmp/maestro_${test_name}.mp4 2>/dev/null | awk '{print \$4}'")
    if [ -n "$file_size" ] && [ "$file_size" -gt 0 ]; then
        echo "Recording file size: $file_size bytes"
        adb pull "/data/local/tmp/maestro_${test_name}.mp4" "$HOME/.maestro/tests/" || true
        
        # Clean up the file from device
        adb shell "rm -f /data/local/tmp/maestro_${test_name}.mp4" || true
    else
        echo "Warning: Recording file not found or empty"
    fi
}

adb install "$APK_PATH"

if [ -d "$TEST_PATH" ]; then
    # If TEST_PATH is a directory, run each .yaml file individually
    echo "Running Maestro tests in directory: $TEST_PATH"
    mkdir -p "$HOME/.maestro/tests"
    
    for test_file in "$TEST_PATH"/*.yaml; do
        echo "Processing test file: $test_file"
        test_name=$(basename "$test_file" .yaml)
        
        if [ "$RECORD" = "true" ]; then
            start_recording "$test_name"
        fi

        export PATH="$PATH:$HOME/.maestro/bin"
        maestro test --format junit --output "$HOME/.maestro/tests/report_${test_name}.xml" "$test_file" || true

        if [ "$RECORD" = "true" ]; then
            stop_recording "$test_name"
        fi
    done
    
    # Merge all individual test reports into a single report.xml
    echo "Merging test reports into report.xml..."
    if command -v junit-report-merger &> /dev/null; then
        junit-report-merger "$HOME/.maestro/tests/report.xml" "$HOME/.maestro/tests/report_*.xml"
    else
        echo "junit-report-merger not found, installing..."
        npm install -g junit-report-merger
        junit-report-merger "$HOME/.maestro/tests/report.xml" "$HOME/.maestro/tests/report_*.xml"
    fi
else
    # Single test file
    test_name=$(basename "$TEST_PATH" .yaml)
    echo "Running Maestro test: $TEST_PATH"

    if [ "$RECORD" = "true" ]; then
        start_recording "$test_name"
    fi

    mkdir -p "$HOME/.maestro/tests"
    export PATH="$PATH:$HOME/.maestro/bin"
    maestro test --format junit --output "$HOME/.maestro/tests/report.xml" "$TEST_PATH" || true

    if [ "$RECORD" = "true" ]; then
        stop_recording "$test_name"
    fi
fi