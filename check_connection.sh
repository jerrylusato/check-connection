#!/bin/zsh

# Default output file
OUTPUT_FILE="speedtest_results.csv"
DURATION_INFINITE=true  # Default to infinite mode

# Expected CSV header
EXPECTED_HEADER="ISP,Timestamp,Server,Idle_Latency(ms),Latency_Jitter(ms),Latency_Low(ms),Latency_High(ms),Download(Mbps),Upload(Mbps),Packet_Loss(%),Result_URL"

# Help function
show_help() {
    echo "Usage: $0 [-t <duration_in_minutes>] [-o <output_file>]"
    echo "Options:"
    echo "  -t: Duration to run tests (in minutes). Default: Infinite (manual stop with Ctrl+C)"
    echo "  -o: Output file name. Default: speedtest_results.csv"
    echo "  -h: Show this help message"
}

# Parse command line arguments
while getopts "t:o:h" opt; do
    case $opt in
        t)
            DURATION_INFINITE=false
            DURATION=$((OPTARG * 60))  # Convert minutes to seconds
            ;;
        o) OUTPUT_FILE=$OPTARG;;
        h) show_help; exit 0;;
        ?) show_help; exit 1;;
    esac
done

# Check if official Speedtest CLI is installed
if ! command -v speedtest &> /dev/null; then
    echo "Speedtest CLI (official) is not installed. Please install it first:"
    echo "  brew install speedtest"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required for this script but is not installed."
    echo "Please install jq first. For example:"
    echo "  brew install jq"
    exit 1
fi

echo "Starting internet speed tests..."
echo "Results will be saved to: $OUTPUT_FILE"

# Validate or create CSV file
if [[ -f $OUTPUT_FILE ]]; then
    # Check if the header matches
    EXISTING_HEADER=$(head -n 1 "$OUTPUT_FILE")
    if [[ "$EXISTING_HEADER" != "$EXPECTED_HEADER" ]]; then
        echo "Warning: The existing CSV file has incorrect or missing headers. Overwriting the file."
        echo "$EXPECTED_HEADER" > "$OUTPUT_FILE"  # Overwrite with correct header
    fi
else
    # Create file with correct header
    echo "$EXPECTED_HEADER" > "$OUTPUT_FILE"
fi

### TODO: Show time remaining instead after logging / before starting the test
if [[ $DURATION_INFINITE == true ]]; then
    echo "Running indefinitely. Press Ctrl+C to stop."
else
    echo "Running for $((DURATION / 60)) minutes."
fi

# Start time for timed mode
if [[ $DURATION_INFINITE == false ]]; then
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
fi

# Main loop
while true; do
    # Check if timed mode has ended
    if [[ $DURATION_INFINITE == false && $(date +%s) -ge $END_TIME ]]; then
        echo ""
        echo "Time limit reached. Exiting..."
        break
    fi

    # Get current timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo ""
    echo "Testing at $TIMESTAMP..."

    # Run speedtest and parse results
    RESULTS=$(speedtest --format=json)

    # Parse fields using jq (JSON parsing tool, ensure it's installed)
    SERVER=$(echo "$RESULTS" | jq -r '.server.name + " - " + .server.location')
    ISP=$(echo "$RESULTS" | jq -r '.isp')
    IDLE_LATENCY=$(echo "$RESULTS" | jq -r '.ping.latency')
    LATENCY_JITTER=$(echo "$RESULTS" | jq -r '.ping.jitter')
    LATENCY_LOW=$(echo "$RESULTS" | jq -r '.ping.low')
    LATENCY_HIGH=$(echo "$RESULTS" | jq -r '.ping.high')
    DOWNLOAD=$(echo "$RESULTS" | jq -r '.download.bandwidth / 125000' | awk '{printf "%.2f", $1}') # Convert to Mbps
    UPLOAD=$(echo "$RESULTS" | jq -r '.upload.bandwidth / 125000' | awk '{printf "%.2f", $1}')   # Convert to Mbps
    PACKET_LOSS=$(echo "$RESULTS" | jq -r '.packetLoss // 0') # Default to 0 if null
    RESULT_URL=$(echo "$RESULTS" | jq -r '.result.url')

    # Display results
    echo "ISP: $ISP"
    echo "Server: $SERVER"
    echo "Idle Latency: $IDLE_LATENCY ms (Jitter: $LATENCY_JITTER ms, Low: $LATENCY_LOW ms, High: $LATENCY_HIGH ms)"
    echo "Download: $DOWNLOAD Mbps, Upload: $UPLOAD Mbps, Packet Loss: $PACKET_LOSS%"
    echo "Result URL: $RESULT_URL"

    # Append results to CSV
    echo "$ISP,\"$TIMESTAMP\",\"$SERVER\",$IDLE_LATENCY,$LATENCY_JITTER,$LATENCY_LOW,$LATENCY_HIGH,$DOWNLOAD,$UPLOAD,$PACKET_LOSS,$RESULT_URL" >> $OUTPUT_FILE

    # Wait for 5 seconds
    sleep 5
done