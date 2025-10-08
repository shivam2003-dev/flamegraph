# 🚀 Quick Start Guide

Get started with flamegraph profiling in under 5 minutes!

## Step 1: Build the Docker Image

```bash
make build
```

This will:
- Build a Docker image with Python 3.11
- Install Linux perf tools
- Clone the FlameGraph toolkit
- Set up the profiling environment

**Expected time**: 2-3 minutes

## Step 2: Run Your First Profile

```bash
make profile-default
```

This will:
- Start the sample application
- Profile it for 10 seconds at 99 Hz
- Generate a flamegraph
- Save it to `output/default-flamegraph.svg`

**Expected time**: 15-20 seconds

## Step 3: View the Flamegraph

```bash
# On macOS
open output/default-flamegraph.svg

# On Linux
xdg-open output/default-flamegraph.svg

# Or open in your browser
# File -> Open -> navigate to output/default-flamegraph.svg
```

## Step 4: Explore the Flamegraph

**Interactive features**:
- **Search**: Use Ctrl+F (or Cmd+F) to search for function names
- **Click**: Click on any box to zoom into that subtree
- **Hover**: Hover over boxes to see function names and percentages
- **Reset**: Click "Reset Zoom" to return to full view

**What to look for**:
- **Wide boxes** = Functions consuming lots of CPU time
- **Tall stacks** = Deep call chains (often recursion)
- **Patterns** = Repeated structures indicate optimization opportunities

## Next Steps

### Try Different Profiling Modes

```bash
# Quick 5-second profile
make profile-quick

# Detailed 20-second profile with higher sampling rate
make profile-detailed

# System-wide profiling
make profile-system
```

### Run the App Without Profiling

```bash
make run-app
```

See what the application does and how long it takes.

### Open an Interactive Shell

```bash
make shell
```

Now you can run commands manually:

```bash
# Inside the container
python3 /app/app.py                    # Run the app
./profile.sh default                    # Run profiling
perf report --stdio                     # View text report
ls -lh /app/output/                    # See output files
```

### View All Available Commands

```bash
make help
```

## Common Commands Cheat Sheet

```bash
# Building
make build              # Build Docker image

# Profiling
make profile-default    # Standard 10s profile (99 Hz)
make profile-quick      # Quick 5s profile (99 Hz)
make profile-detailed   # Detailed 20s profile (997 Hz)

# Running
make run-app           # Run app without profiling
make shell             # Interactive shell in container

# Viewing
make view-output       # List output files
open output/*.svg      # Open flamegraphs (macOS)

# Cleaning
make clean             # Remove output files
make clean-all         # Remove output + Docker images
```

## Understanding Your First Flamegraph

### The Basics

1. **Bottom = Root**: The bottom is your `main()` function (100% of samples)
2. **Top = Leaf**: The top are the actual functions doing work
3. **Width = Time**: Wider boxes = more CPU time
4. **Height = Stack Depth**: Call stack from bottom to top

### What You'll See in the Sample App

- **`fibonacci_recursive`**: Very wide box, tall stack (inefficient recursion)
- **`compute_primes`**: Medium-wide box (mathematical computation)
- **`matrix_multiplication`**: Wide box with nested loops
- **`string_processing`**: String manipulation overhead
- **`json_processing`**: Serialization/deserialization time

### Your First Optimization

1. **Find the widest box** (likely `fibonacci_recursive`)
2. **Note its percentage** (should be ~60% of CPU time)
3. **Understand why**: It's recursive without memoization
4. **The fix exists**: There's a `fibonacci_cached` version!

Want to try fixing it?

```bash
# Edit app.py and change fibonacci_recursive to fibonacci_cached
# Then profile again
make profile-default
```

You should see a dramatic reduction in CPU time!

## Troubleshooting

### "docker: command not found"

Install Docker Desktop: https://www.docker.com/products/docker-desktop

### "make: command not found"

You can use docker-compose directly:

```bash
docker-compose build
docker-compose run --rm flamegraph-profiler ./profile.sh default
```

### "Permission denied"

On Linux, you may need to add your user to the docker group:

```bash
sudo usermod -aG docker $USER
# Then log out and back in
```

### No output files generated

Make sure the `output/` directory exists:

```bash
mkdir -p output
```

### Flamegraph shows only kernel functions

This is normal! Python (and most interpreted languages) spend time in the interpreter. You'll see both:
- **Your Python functions** (the interesting part)
- **Python interpreter internals** (CPython runtime)

Focus on your function names in the flamegraph.

## Learning Resources

- **Full Documentation**: See `README.md` for comprehensive guide
- **Brendan Gregg's Site**: https://www.brendangregg.com/flamegraphs.html
- **Video Tutorial**: https://www.youtube.com/watch?v=6uKZXIwd6M0

## What's Next?

1. ✅ You've created your first flamegraph
2. ✅ You understand the basics of reading it
3. ⬜ Try profiling with different modes
4. ⬜ Modify the app and see the changes
5. ⬜ Profile your own applications!

---

**Questions? Issues?**

Check the full README.md for detailed tutorials and troubleshooting.

**Happy Profiling! 🔥**
