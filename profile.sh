#!/bin/bash

# Flamegraph Profiling Script
# This script demonstrates various profiling techniques with perf and flamegraphs

set -e

FLAMEGRAPH_DIR="/opt/FlameGraph"
OUTPUT_DIR="/app/output"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "======================================"
echo "FLAMEGRAPH PROFILING SCRIPT"
echo "======================================"
echo ""

# Function to profile with perf
profile_with_perf() {
    local duration=${1:-10}
    local frequency=${2:-99}
    
    echo "Starting perf profiling..."
    echo "  Duration: ${duration} seconds"
    echo "  Sampling frequency: ${frequency} Hz"
    echo ""
    
    # Run the application in background
    python3 /app/app.py &
    APP_PID=$!
    
    echo "Application PID: $APP_PID"
    
    # Profile the application
    perf record -F "$frequency" -p "$APP_PID" -g -- sleep "$duration" || true
    
    # Wait for application to finish
    wait "$APP_PID" 2>/dev/null || true
    
    echo "Profiling complete!"
}

# Function to generate flamegraph
generate_flamegraph() {
    local output_name=${1:-"flamegraph"}
    
    echo ""
    echo "Generating flamegraph..."
    
    # Convert perf data to folded format
    perf script | "$FLAMEGRAPH_DIR/stackcollapse-perf.pl" > "$OUTPUT_DIR/out.folded"
    
    # Generate flamegraph
    "$FLAMEGRAPH_DIR/flamegraph.pl" "$OUTPUT_DIR/out.folded" > "$OUTPUT_DIR/${output_name}.svg"
    
    echo "Flamegraph saved to: $OUTPUT_DIR/${output_name}.svg"
}

# Function to show perf report
show_perf_report() {
    echo ""
    echo "======================================"
    echo "PERF REPORT SUMMARY"
    echo "======================================"
    perf report --stdio --sort comm,dso,symbol --no-children | head -n 50
}

# Function to profile entire system (requires --privileged)
profile_system() {
    local duration=${1:-10}
    
    echo "Starting system-wide profiling..."
    echo "  Duration: ${duration} seconds"
    echo ""
    
    # Run the application in background
    python3 /app/app.py &
    APP_PID=$!
    
    # System-wide profiling
    perf record -F 99 -a -g -- sleep "$duration" || true
    
    wait "$APP_PID" 2>/dev/null || true
    
    echo "System-wide profiling complete!"
}

# Main execution
case "${1:-default}" in
    "default")
        echo "Running default profiling (10 seconds, 99 Hz)..."
        profile_with_perf 10 99
        generate_flamegraph "default-flamegraph"
        show_perf_report
        ;;
    
    "quick")
        echo "Running quick profiling (5 seconds, 99 Hz)..."
        profile_with_perf 5 99
        generate_flamegraph "quick-flamegraph"
        ;;
    
    "detailed")
        echo "Running detailed profiling (20 seconds, 997 Hz)..."
        profile_with_perf 20 997
        generate_flamegraph "detailed-flamegraph"
        show_perf_report
        ;;
    
    "system")
        echo "Running system-wide profiling..."
        profile_system 10
        generate_flamegraph "system-flamegraph"
        show_perf_report
        ;;
    
    "report")
        echo "Generating perf report from existing data..."
        show_perf_report
        ;;
    
    "flamegraph")
        echo "Generating flamegraph from existing perf.data..."
        generate_flamegraph "${2:-flamegraph}"
        ;;
    
    *)
        echo "Usage: $0 {default|quick|detailed|system|report|flamegraph [name]}"
        echo ""
        echo "Modes:"
        echo "  default   - Standard profiling (10s, 99 Hz)"
        echo "  quick     - Quick profiling (5s, 99 Hz)"
        echo "  detailed  - Detailed profiling (20s, 997 Hz)"
        echo "  system    - System-wide profiling (requires --privileged)"
        echo "  report    - Show perf report from existing data"
        echo "  flamegraph [name] - Generate flamegraph from existing perf.data"
        exit 1
        ;;
esac

echo ""
echo "======================================"
echo "PROFILING COMPLETE"
echo "======================================"
echo ""
echo "Output files location: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR" 2>/dev/null || echo "No output files generated yet."
