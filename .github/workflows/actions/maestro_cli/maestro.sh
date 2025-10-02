#!/bin/bash

APK_PATH="$1"
RECORD="$2"
VIDEO_RES="$3"
BIT_RATE="$4"
TEST_PATH="$5"

# Wait for ADB connection and ensure emulator is ready
echo "Waiting for emulator to be ready..."
adb wait-for-device
sleep 10

# Check if device is online and retry if needed
max_retries=10
retry_count=0
while [ $retry_count -lt $max_retries ]; do
    if adb shell echo "ping" > /dev/null 2>&1; then
        echo "ADB connection established successfully"
        break
    else
        echo "ADB connection failed, retrying... ($((retry_count + 1))/$max_retries)"
        sleep 5
        adb kill-server
        adb start-server
        adb wait-for-device
        retry_count=$((retry_count + 1))
    fi
done

if [ $retry_count -eq $max_retries ]; then
    echo "Failed to establish ADB connection after $max_retries attempts"
    exit 1
fi

# Install APK with retries
echo "Installing APK..."
install_retries=3
install_count=0
while [ $install_count -lt $install_retries ]; do
    if adb install "$APK_PATH"; then
        echo "APK installed successfully"
        break
    else
        echo "APK installation failed, retrying... ($((install_count + 1))/$install_retries)"
        sleep 3
        install_count=$((install_count + 1))
    fi
done

if [ $install_count -eq $install_retries ]; then
    echo "Failed to install APK after $install_retries attempts"
    exit 1
fi

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
        
        # Ensure ADB is still connected before running Maestro
        if ! adb shell echo "ping" > /dev/null 2>&1; then
            echo "ADB connection lost, attempting to reconnect..."
            adb kill-server
            adb start-server
            adb wait-for-device
            sleep 5
        fi
        
        echo "Running Maestro test: $test_file"
        export PATH="$PATH:$HOME/.maestro/bin"
        maestro test --format junit --output "$HOME/.maestro/tests/report_${test_name}.xml" "$test_file" || true

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
    
    # Ensure ADB is still connected before running Maestro
    if ! adb shell echo "ping" > /dev/null 2>&1; then
        echo "ADB connection lost, attempting to reconnect..."
        adb kill-server
        adb start-server
        adb wait-for-device
        sleep 5
    fi
    
    echo "Running Maestro test: $TEST_PATH"
    export PATH="$PATH:$HOME/.maestro/bin"
    maestro test --format junit --output "$HOME/.maestro/tests/report.xml" "$TEST_PATH" || true

    if [ "$RECORD" = "true" ]; then
        stop_recording "$test_name"
    fi
fi