#!/bin/zsh

# Default values
DURATION=300 # 5 minutes in seconds
OUTPUT_FILE="speedtest_results.csv"

# Help function
show_help() {
    echo "Usage: $0 [-t <duration_in_minutes>] [-o <output_file>]"
    echo "Options:"
    echo "  -t: Duration to run tests (in minutes, default: 5)"
    echo "  -o: Output file name (default: speedtest_results.csv)"
    echo "  -h: Show this help message"
}

# Parse command line arguments
while getopts "t:o:h" opt; do
    case $opt in
        t) DURATION=$((OPTARG * 60));;
        o) OUTPUT_FILE=$OPTARG;;
        h) show_help; exit 0;;
        ?) show_help; exit 1;;
    esac
done

# Check if speedtest-cli is installed
if ! command -v speedtest-cli &> /dev/null; then
    echo "speedtest-cli is not installed. Please install it first:"
    echo "brew install speedtest-cli"
    exit 1
fi

# Create CSV header if file doesn't exist
if [[ ! -f $OUTPUT_FILE ]]; then
    echo "Timestamp,Download,Upload" > $OUTPUT_FILE
fi

echo "Starting internet speedtest..."
echo "Duration: $((DURATION/60)) minutes"
echo "Results will be saved to: $OUTPUT_FILE"

# Calculate end time
START_TIME=$(date +%s)
END_TIME=$((START_TIME + DURATION))

while [[ $(date +%s) -lt $END_TIME ]]; do
    # Get current timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "\nTesting at $TIMESTAMP..."
    
    # Calculate remaining time
    REMAINING=$((END_TIME - $(date +%s)))
    echo "Remaining time: $((REMAINING/60)) minutes and $((REMAINING%60)) seconds"

    # Run speedtest and parse results
    RESULTS=$(speedtest)
    DOWNLOAD=$(echo "$RESULTS" | grep "Download" | awk '{print $2}')
    UPLOAD=$(echo "$RESULTS" | grep "Upload" | awk '{print $2}')

    # Show result
    echo "\nDownload: $DOWNLOAD, Upload: $UPLOAD"
    
    # Save results to CSV
    echo "$TIMESTAMP,$DOWNLOAD,$UPLOAD" >> $OUTPUT_FILE
    
    # Wait for the next second
    sleep 1
done

echo "\nCheck complete. Results saved to $OUTPUT_FILE"