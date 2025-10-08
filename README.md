# 🔥 Flamegraph Profiling Tutorial

A comprehensive guide to performance profiling using Flamegraphs with Docker and Linux `perf` tools.

## 📋 Table of Contents

- [Overview](#overview)
- [What is a Flamegraph?](#what-is-a-flamegraph)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Understanding the Components](#understanding-the-components)
- [Profiling Basics](#profiling-basics)
- [Step-by-Step Tutorial](#step-by-step-tutorial)
- [Reading Flamegraphs](#reading-flamegraphs)
- [Advanced Profiling](#advanced-profiling)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🎯 Overview

This project provides a complete environment for learning performance profiling with flamegraphs. It includes:

- **Sample Application**: A Python app with various performance characteristics
- **Docker Environment**: Pre-configured with all profiling tools
- **Profiling Scripts**: Automated scripts for different profiling scenarios
- **Documentation**: Comprehensive guide on profiling techniques

## 🔥 What is a Flamegraph?

A **Flamegraph** is a visualization of profiled software, allowing you to quickly identify the most frequent code paths. It was invented by Brendan Gregg and has become an industry-standard tool for performance analysis.

### Key Features:

- **X-axis**: Alphabetically sorted stack frames (NOT time!)
- **Y-axis**: Stack depth (call stack hierarchy)
- **Width**: Proportional to CPU time spent in that function
- **Color**: Typically just for visual distinction (warm colors often used)

### What Flamegraphs Show:

- ✅ Which functions consume the most CPU time
- ✅ Call stack relationships
- ✅ Hot paths in your code
- ❌ NOT the passage of time (left-to-right)
- ❌ NOT the frequency of calls (only cumulative time)

## 🛠 Prerequisites

- **Docker** and **Docker Compose** installed
- **macOS, Linux, or Windows** with WSL2
- **8GB RAM** recommended
- **Basic understanding** of command line

### Installation Check:

```bash
# Check Docker
docker --version

# Check Docker Compose
docker-compose --version

# Check Make (optional but recommended)
make --version
```

## 🚀 Quick Start

### 1. Build the Docker Image

```bash
make build
# OR
docker-compose build
```

### 2. Run Default Profiling

```bash
make profile-default
# OR
docker-compose run --rm flamegraph-profiler ./profile.sh default
```

### 3. View the Flamegraph

```bash
# The flamegraph will be saved in ./output/default-flamegraph.svg
open output/default-flamegraph.svg  # macOS
xdg-open output/default-flamegraph.svg  # Linux
start output/default-flamegraph.svg  # Windows
```

## 📦 Understanding the Components

### 1. **app.py** - Sample Application

A Python application demonstrating various performance patterns:

- **Recursive Functions**: Fibonacci calculations (inefficient by design)
- **CPU-Intensive Operations**: Matrix multiplication, prime number calculation
- **String Processing**: Heavy string manipulations
- **I/O Simulation**: Simulated I/O wait times
- **JSON Processing**: Serialization/deserialization overhead

### 2. **Dockerfile** - Environment Setup

Sets up a container with:
- Python 3.11
- Linux `perf` tools
- FlameGraph scripts (Brendan Gregg's toolkit)
- All necessary dependencies

### 3. **profile.sh** - Profiling Script

Automated profiling with multiple modes:
- `default`: Standard profiling (10s, 99Hz)
- `quick`: Fast profiling (5s, 99Hz)
- `detailed`: High-resolution profiling (20s, 997Hz)
- `system`: System-wide profiling

### 4. **docker-compose.yml** - Container Configuration

Configures the container with:
- `privileged: true` - Required for perf access
- Volume mounts for output files
- Security options for profiling

## 📚 Profiling Basics

### How Profiling Works

**Profiling** is the process of measuring where your program spends time. There are two main approaches:

#### 1. **Sampling Profiling** (What we use)

- Periodically interrupts the program (e.g., 99 times per second)
- Records the call stack at each interrupt
- Statistical approach: more samples = more accurate
- **Low overhead** (~1-5%)

#### 2. **Instrumentation Profiling**

- Adds code to measure every function call
- Exact measurements but **high overhead**
- Not covered in this tutorial

### Key Concepts

#### **Sampling Frequency**

- Measured in Hertz (Hz) = samples per second
- **99 Hz**: Good balance (default in perf)
- **997 Hz**: More detailed but higher overhead
- **4999 Hz**: Very detailed (use sparingly)

#### **Call Stack**

The hierarchy of function calls:
```
main()
  └─ mixed_workload()
      └─ fibonacci_recursive(20)
          └─ fibonacci_recursive(19)
              └─ fibonacci_recursive(18)
                  └─ ...
```

#### **CPU Time vs Wall Time**

- **CPU Time**: Actual time CPU spent executing code
- **Wall Time**: Real-world elapsed time (includes I/O waits)
- Flamegraphs show **CPU Time**

## 📖 Step-by-Step Tutorial

### Tutorial 1: Basic Profiling

#### Step 1: Run the Application First (No Profiling)

```bash
# See what the application does
make run-app
# OR
docker-compose run --rm flamegraph-profiler python3 /app/app.py
```

**Observe**: The application runs different workloads and reports execution time.

#### Step 2: Profile with Default Settings

```bash
make profile-default
```

**What happens**:
1. Application starts running
2. `perf record` starts sampling at 99 Hz
3. After 10 seconds, profiling stops
4. Data is converted to folded format
5. Flamegraph SVG is generated

#### Step 3: Examine the Output

```bash
# List output files
make view-output
# OR
ls -lh output/

# Open the flamegraph
open output/default-flamegraph.svg
```

#### Step 4: Read the Flamegraph

Look for:
- **Widest boxes**: Functions consuming most CPU time
- **Tall stacks**: Deep call chains (potential recursion)
- **Plateaus**: Functions with many children (orchestration)

### Tutorial 2: Comparing Different Workloads

#### Run Quick Profiling

```bash
make profile-quick
```

This runs for only 5 seconds - faster but less accurate.

#### Run Detailed Profiling

```bash
make profile-detailed
```

This runs for 20 seconds at 997 Hz - more accurate, more data.

#### Compare the Flamegraphs

```bash
open output/quick-flamegraph.svg
open output/detailed-flamegraph.svg
open output/default-flamegraph.svg
```

**Question to explore**: Are the hot spots consistent across all three?

### Tutorial 3: Interactive Profiling

#### Step 1: Open a Shell in the Container

```bash
make shell
# OR
docker-compose run --rm flamegraph-profiler /bin/bash
```

#### Step 2: Run Application Manually

```bash
# Inside container
python3 /app/app.py
```

#### Step 3: Profile a Running Process

```bash
# In another terminal, get container ID
docker ps

# Exec into container
docker exec -it <container-id> /bin/bash

# Find the Python process
ps aux | grep python

# Profile it
perf record -F 99 -p <PID> -g -- sleep 10

# Generate flamegraph
perf script | /opt/FlameGraph/stackcollapse-perf.pl > /app/output/custom.folded
/opt/FlameGraph/flamegraph.pl /app/output/custom.folded > /app/output/custom-flamegraph.svg
```

### Tutorial 4: Understanding perf Commands

#### Basic perf record

```bash
# Profile a specific process for 10 seconds
perf record -F 99 -p <PID> -g -- sleep 10
```

**Options explained**:
- `-F 99`: Sample at 99 Hz
- `-p <PID>`: Profile specific process ID
- `-g`: Record call graphs (stack traces)
- `-- sleep 10`: Profile for 10 seconds

#### View perf report

```bash
# Generate a text report
perf report --stdio

# Interactive TUI report
perf report
```

#### System-wide profiling

```bash
# Profile ALL processes
perf record -F 99 -a -g -- sleep 10
```

**Options**:
- `-a`: All CPUs, all processes

### Tutorial 5: Analyzing Specific Functions

Let's focus on the Fibonacci function which is intentionally inefficient.

#### Step 1: Run and Profile

```bash
make profile-detailed
```

#### Step 2: Find Fibonacci in Flamegraph

Open the flamegraph and search for `fibonacci_recursive` (most flamegraph viewers have a search feature).

#### Step 3: Observe the Pattern

- **Notice**: Very wide box for `fibonacci_recursive`
- **Notice**: Very tall stack (deep recursion)
- **Insight**: This function is a performance bottleneck!

#### Step 4: Compare with Cached Version

Modify `app.py` to use `fibonacci_cached` instead and re-profile:

```bash
# Edit app.py (change fibonacci_recursive to fibonacci_cached)
# Then profile again
make profile-default
```

**Result**: The cached version should show much less CPU time!

## 🎨 Reading Flamegraphs

### Visual Guide

```
┌─────────────────────────────────────────────┐
│  main()  [100% of CPU time]                 │  ← Root (100%)
├─────────────────────────────────────────────┤
│  mixed_workload()  [95%]  │  Other [5%]     │  ← Level 1
├──────────────┬──────────────┬───────────────┤
│ fibonacci[60%]│ primes[20%] │ matrix [15%]  │  ← Level 2
└──────────────┴──────────────┴───────────────┘
```

### Reading Tips

1. **Start from the bottom**: Root of the call stack
2. **Look for wide boxes**: These consume the most CPU
3. **Hover/Click**: Most viewers show details on interaction
4. **Search**: Use search to find specific functions
5. **Zoom**: Click a box to zoom into that subtree

### Common Patterns

#### 🔴 **Tower Pattern** (Very Tall, Narrow)
```
│ █ │  Deep recursion or long call chain
│ █ │  May indicate inefficient recursion
│ █ │
│ █ │
```

#### 🟡 **Plateau Pattern** (Wide, Short)
```
├────────────────────────┤
│     function()         │  Orchestration function
├───┬───┬───┬───┬───┬───┤  Many diverse children
│ A │ B │ C │ D │ E │ F │
```

#### 🔵 **Volcano Pattern** (Wide base, narrow top)
```
      │ █ │         Bottleneck at the top
   ├──┴─┴──┤
   │   ▒   │        Intermediate functions
├──┴───┴───┴──┤
│             │     Wide base
```

## 🔬 Advanced Profiling

### 1. Off-CPU Analysis

Profile when threads are **blocked** (I/O, locks, etc.):

```bash
# Inside container
perf record -e sched:sched_switch -g -- python3 /app/app.py

# Generate off-CPU flamegraph
perf script | /opt/FlameGraph/stackcollapse-perf.pl | \
  /opt/FlameGraph/flamegraph.pl --color=io --title="Off-CPU Time" \
  > /app/output/offcpu-flamegraph.svg
```

### 2. Differential Flamegraphs

Compare two profiles to see what changed:

```bash
# Profile before optimization
perf record -F 99 -g -- python3 /app/app.py
mv perf.data perf.data.old

# Make changes to app.py

# Profile after optimization
perf record -F 99 -g -- python3 /app/app.py
mv perf.data perf.data.new

# Generate differential flamegraph
perf script -i perf.data.old | /opt/FlameGraph/stackcollapse-perf.pl > old.folded
perf script -i perf.data.new | /opt/FlameGraph/stackcollapse-perf.pl > new.folded
/opt/FlameGraph/difffolded.pl old.folded new.folded | \
  /opt/FlameGraph/flamegraph.pl > /app/output/diff-flamegraph.svg
```

### 3. Memory Profiling

While not a flamegraph, you can profile memory allocations:

```bash
# Inside container
python3 -m pip install memory_profiler
python3 -m memory_profiler /app/app.py
```

### 4. Custom Sampling Rates

For **very** detailed profiling:

```bash
# 4999 Hz sampling (very high resolution)
perf record -F 4999 -g -- python3 /app/app.py

# Warning: Higher overhead!
```

### 5. Filter by CPU

Profile specific CPUs:

```bash
# Profile only CPU 0 and 1
perf record -C 0,1 -F 99 -g -- sleep 10
```

## 🐛 Troubleshooting

### Problem: "perf: Operation not permitted"

**Solution 1**: Make sure container is privileged
```bash
# Check docker-compose.yml has:
privileged: true
security_opt:
  - seccomp:unconfined
```

**Solution 2**: Adjust perf_event_paranoid
```bash
# Inside container
echo -1 > /proc/sys/kernel/perf_event_paranoid
```

### Problem: "No data available"

**Possible causes**:
1. Application finished before profiling started
2. No CPU activity during profiling
3. Insufficient privileges

**Solution**: Use longer profiling duration or profile system-wide.

### Problem: Flamegraph is empty or shows only kernel functions

**Cause**: Missing symbols or application too short

**Solution**:
```bash
# Install debug symbols (for C/C++ apps)
apt-get install python3-dbg

# Run application longer
# Modify app.py to run more iterations
```

### Problem: "Cannot open /proc/kcore"

**Solution**: This is just a warning, safe to ignore. To suppress:
```bash
perf record --no-kallsyms -F 99 -g -- python3 /app/app.py
```

### Problem: SVG file won't open

**Solution**: Flamegraph SVG files are interactive and best viewed in a web browser:
```bash
# Open in default browser
open output/default-flamegraph.svg  # macOS
xdg-open output/default-flamegraph.svg  # Linux
```

## ✨ Best Practices

### 1. **Choose the Right Sampling Rate**

- **99 Hz**: Default, good for most cases
- **997 Hz**: More accurate, acceptable overhead
- **4999 Hz**: Very detailed, use carefully
- **49 Hz**: Low overhead for production

### 2. **Profile Representative Workloads**

- Run typical operations
- Include realistic data volumes
- Profile under similar load conditions

### 3. **Profile Long Enough**

- **Minimum**: 5 seconds
- **Recommended**: 10-30 seconds
- **Production**: 60+ seconds for statistical significance

### 4. **Focus on the Biggest Issues First**

- Look for the widest boxes
- Optimize the top 3 bottlenecks
- Re-profile after each optimization

### 5. **Compare Before and After**

- Always profile before optimizing (establish baseline)
- Profile after each change
- Use differential flamegraphs to validate improvements

### 6. **Consider Both CPU and Off-CPU**

- CPU flamegraphs show computation time
- Off-CPU shows blocking (I/O, locks)
- Both perspectives needed for complete picture

### 7. **Use Version Control**

```bash
# Save flamegraphs with git
git add output/*.svg
git commit -m "Profiling results before optimization"
```

### 8. **Document Findings**

Keep a profiling log:
```markdown
## Profiling Session: 2025-10-08

### Findings:
- fibonacci_recursive: 60% CPU time
- Excessive recursion (stack depth: 20+)

### Actions:
- Implement memoization
- Expected improvement: 50%+

### Results:
- CPU time reduced to 5%
- 12x performance improvement
```

## 📊 Real-World Use Cases

### 1. Web Application Performance

```bash
# Profile your Flask/Django app
perf record -F 99 -g -p <web_server_pid> -- sleep 30

# Look for:
# - Slow database queries
# - Template rendering overhead
# - JSON serialization bottlenecks
```

### 2. API Endpoint Optimization

```bash
# Profile during load test
# Terminal 1: Start load test
ab -n 1000 -c 10 http://localhost:5000/api/slow-endpoint

# Terminal 2: Profile the server
perf record -F 99 -g -p <server_pid> -- sleep 20
```

### 3. Data Processing Pipeline

```bash
# Profile ETL job
perf record -F 99 -g -- python3 process_data.py large_dataset.csv

# Identify:
# - I/O vs CPU bottlenecks
# - Inefficient data transformations
# - Serialization overhead
```

### 4. Microservice Debugging

```bash
# Profile containerized service
docker exec -it <container> perf record -F 99 -g -p 1 -- sleep 30

# Export and analyze
docker cp <container>:/perf.data .
```

## 🎓 Learning Path

### Beginner (Day 1)

1. ✅ Run the sample application
2. ✅ Create your first flamegraph
3. ✅ Identify the biggest CPU consumer
4. ✅ Understand X-axis vs Y-axis

### Intermediate (Week 1)

1. ✅ Try different sampling rates
2. ✅ Profile your own application
3. ✅ Compare before/after optimization
4. ✅ Interpret different flame patterns

### Advanced (Month 1)

1. ✅ Off-CPU profiling
2. ✅ Differential flamegraphs
3. ✅ System-wide profiling
4. ✅ Production profiling strategies

## 🔗 Additional Resources

### Documentation

- [Brendan Gregg's Flamegraph Repository](https://github.com/brendangregg/FlameGraph)
- [Linux Perf Wiki](https://perf.wiki.kernel.org/)
- [Brendan Gregg's Blog](https://www.brendangregg.com/flamegraphs.html)

### Books

- **"Systems Performance"** by Brendan Gregg
- **"BPF Performance Tools"** by Brendan Gregg

### Videos

- [Blazing Performance with Flame Graphs](https://www.youtube.com/watch?v=6uKZXIwd6M0) - USENIX ATC 2017

### Tools

- [FlameGraph](https://github.com/brendangregg/FlameGraph) - Original implementation
- [Speedscope](https://www.speedscope.app/) - Interactive viewer
- [Firefox Profiler](https://profiler.firefox.com/) - Alternative viewer

## 🤝 Contributing

Found an issue or want to improve this tutorial? Contributions welcome!

## 📝 License

This project is open source and available under the MIT License.

## 🎯 Quick Command Reference

```bash
# Build
make build

# Profile
make profile-default    # Standard profiling
make profile-quick      # Quick 5s profile
make profile-detailed   # Detailed 20s profile

# Run
make run-app           # Run without profiling
make shell             # Interactive shell

# View
make view-output       # List output files

# Clean
make clean             # Clean output files
make clean-all         # Clean everything
```

---

**Happy Profiling! 🔥**

Remember: *"You can't optimize what you don't measure."* - Brendan Gregg