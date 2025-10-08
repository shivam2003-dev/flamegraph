# 📊 Project Structure

```
flamegraph/
├── README.md                   # Comprehensive profiling tutorial
├── QUICKSTART.md              # 5-minute getting started guide
├── Makefile                   # Convenient make commands
├── docker-compose.yml         # Docker orchestration
├── Dockerfile                 # Container setup with perf tools
├── .dockerignore             # Docker build exclusions
├── .gitignore                # Git exclusions
│
├── app.py                    # Sample Python application for profiling
│                            # (CPU-intensive operations, recursion, I/O)
│
├── profile.sh                # Automated profiling scripts
│                            # (default, quick, detailed, system modes)
│
└── output/                   # Generated flamegraphs and perf data
    └── .gitkeep             # (SVG files will be created here)
```

## File Descriptions

### Documentation

- **README.md**: Complete tutorial covering profiling theory, practice, and advanced techniques
- **QUICKSTART.md**: Get started in under 5 minutes
- **PROJECT_STRUCTURE.md**: This file - overview of the project

### Application Files

- **app.py**: Python application with intentional performance bottlenecks for learning:
  - Recursive Fibonacci (inefficient)
  - Cached Fibonacci (efficient)
  - Prime number calculation
  - Matrix multiplication
  - String processing
  - JSON serialization
  - I/O simulation

### Docker Configuration

- **Dockerfile**: Creates container with:
  - Python 3.11
  - Linux perf tools
  - FlameGraph scripts from Brendan Gregg's repo
  - Profiling environment setup

- **docker-compose.yml**: Container orchestration with:
  - Privileged mode (required for perf)
  - Volume mounts for output
  - Security options for profiling

### Profiling Scripts

- **profile.sh**: Automated profiling with modes:
  - `default`: 10s @ 99 Hz
  - `quick`: 5s @ 99 Hz
  - `detailed`: 20s @ 997 Hz
  - `system`: System-wide profiling
  - `report`: Show perf report
  - `flamegraph`: Generate from existing data

### Build Tools

- **Makefile**: Convenient commands:
  - `make build`: Build Docker image
  - `make profile-*`: Run various profiling modes
  - `make run-app`: Run without profiling
  - `make shell`: Interactive container shell
  - `make clean`: Clean output files

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. Build Container                                     │
│     $ make build                                        │
│     → Dockerfile creates environment with perf tools    │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  2. Run Profiling                                       │
│     $ make profile-default                              │
│     → Docker runs app.py                                │
│     → profile.sh launches perf record                   │
│     → Samples collected at 99 Hz for 10s                │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  3. Generate Flamegraph                                 │
│     → perf script extracts stack traces                 │
│     → stackcollapse-perf.pl folds stacks                │
│     → flamegraph.pl creates SVG visualization           │
│     → Saved to output/default-flamegraph.svg            │
│                                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  4. Analyze Results                                     │
│     $ open output/default-flamegraph.svg                │
│     → Interactive SVG in browser                        │
│     → Search, zoom, explore hot paths                   │
│     → Identify performance bottlenecks                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Key Technologies

| Technology | Purpose |
|------------|---------|
| **Linux perf** | Sampling profiler using performance counters |
| **FlameGraph** | Visualization toolkit by Brendan Gregg |
| **Docker** | Isolated environment with profiling tools |
| **Python** | Sample application language |
| **Bash** | Profiling automation scripts |
| **SVG** | Interactive flamegraph output format |

## Prerequisites

- Docker Desktop installed
- 8GB RAM (recommended)
- macOS, Linux, or Windows with WSL2
- Basic command line knowledge

## Getting Started

**Option 1: Quick Start (5 minutes)**
```bash
make build
make profile-default
open output/default-flamegraph.svg
```

**Option 2: Step by Step**
```bash
# 1. Build the environment
docker-compose build

# 2. Run the application (no profiling)
docker-compose run --rm flamegraph-profiler python3 /app/app.py

# 3. Profile the application
docker-compose run --rm flamegraph-profiler ./profile.sh default

# 4. View the result
open output/default-flamegraph.svg
```

**Option 3: Interactive Exploration**
```bash
make shell  # Opens bash in container
# Now you can run commands manually
```

## Output Files

After profiling, you'll find in `output/`:

| File | Description | Size |
|------|-------------|------|
| `*-flamegraph.svg` | Interactive visualization | 500KB - 5MB |
| `out.folded` | Collapsed stack traces | 100KB - 1MB |
| `perf.data` | Raw perf profiling data | 1MB - 50MB |

## Learning Path

1. **Day 1**: Read QUICKSTART.md, run first profile
2. **Week 1**: Read README.md tutorials, try different modes
3. **Week 2**: Modify app.py, profile your changes
4. **Week 3**: Profile your own applications
5. **Month 1**: Advanced techniques, production profiling

## Customization

### Profile Your Own Application

1. **Copy your app** into the container:
   ```yaml
   # In docker-compose.yml, add:
   volumes:
     - ./your-app:/app/your-app
   ```

2. **Profile it**:
   ```bash
   docker-compose run --rm flamegraph-profiler bash
   perf record -F 99 -g -- python3 /app/your-app/main.py
   perf script | /opt/FlameGraph/stackcollapse-perf.pl > out.folded
   /opt/FlameGraph/flamegraph.pl out.folded > /app/output/your-flamegraph.svg
   ```

### Change Sampling Rate

Edit `profile.sh` and modify the `-F` parameter:
- `-F 49`: Lower overhead (production)
- `-F 99`: Balanced (default)
- `-F 997`: High detail
- `-F 4999`: Maximum detail (high overhead)

### Add New Profiling Modes

Edit `profile.sh` and add a new case:
```bash
"yourmode")
    echo "Running your custom profiling..."
    profile_with_perf 15 499
    generate_flamegraph "your-flamegraph"
    ;;
```

Then run: `./profile.sh yourmode`

## Common Use Cases

1. **Learning**: Understand how profiling works
2. **Optimization**: Find performance bottlenecks
3. **Comparison**: Before/after optimization analysis
4. **Education**: Teach profiling to teams
5. **Debugging**: Identify unexpected CPU usage

## Resources

- **Brendan Gregg's FlameGraph**: https://github.com/brendangregg/FlameGraph
- **Linux Perf Wiki**: https://perf.wiki.kernel.org/
- **Blog**: https://www.brendangregg.com/flamegraphs.html
- **Video**: https://www.youtube.com/watch?v=6uKZXIwd6M0

## Support

For issues or questions:
1. Check README.md troubleshooting section
2. Review QUICKSTART.md for common problems
3. Ensure Docker has sufficient resources (8GB RAM recommended)
4. Verify privileged mode is enabled in docker-compose.yml

---

**Last Updated**: October 8, 2025
**Version**: 1.0
**License**: MIT
