#!/usr/bin/env python3
"""
Simple CPU-intensive application for flamegraph profiling demonstration.
This app simulates various performance scenarios to help understand profiling.
"""

import time
import math
import random
import json
from functools import lru_cache


def fibonacci_recursive(n):
    """Recursive fibonacci - intentionally inefficient for profiling demo"""
    if n <= 1:
        return n
    return fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)


@lru_cache(maxsize=None)
def fibonacci_cached(n):
    """Cached fibonacci - more efficient version"""
    if n <= 1:
        return n
    return fibonacci_cached(n - 1) + fibonacci_cached(n - 2)


def compute_primes(limit):
    """Calculate prime numbers up to limit using Sieve of Eratosthenes"""
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    
    for i in range(2, int(math.sqrt(limit)) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    
    return [i for i, is_prime in enumerate(sieve) if is_prime]


def matrix_multiplication(size):
    """Perform matrix multiplication - CPU intensive operation"""
    matrix_a = [[random.random() for _ in range(size)] for _ in range(size)]
    matrix_b = [[random.random() for _ in range(size)] for _ in range(size)]
    result = [[0 for _ in range(size)] for _ in range(size)]
    
    for i in range(size):
        for j in range(size):
            for k in range(size):
                result[i][j] += matrix_a[i][k] * matrix_b[k][j]
    
    return result


def string_processing():
    """String manipulation operations"""
    text = "Performance profiling with flamegraphs is awesome! " * 1000
    results = []
    
    # Various string operations
    results.append(text.upper())
    results.append(text.lower())
    results.append(text.replace("flamegraphs", "FLAMEGRAPHS"))
    results.append("".join(reversed(text)))
    
    return len(results)


def json_processing():
    """JSON serialization and deserialization"""
    data = {
        "users": [
            {
                "id": i,
                "name": f"User_{i}",
                "email": f"user{i}@example.com",
                "scores": [random.randint(0, 100) for _ in range(10)]
            }
            for i in range(1000)
        ]
    }
    
    # Serialize and deserialize multiple times
    for _ in range(10):
        json_str = json.dumps(data)
        parsed = json.loads(json_str)
    
    return len(data["users"])


def io_simulation():
    """Simulate I/O operations with sleep"""
    time.sleep(0.1)  # Simulate I/O wait
    return "IO complete"


def mixed_workload():
    """Run a mixed workload combining different operations"""
    print("Starting mixed workload...")
    
    # Fibonacci calculations
    print("  Computing Fibonacci numbers...")
    fib_results = []
    for i in range(5):
        fib_results.append(fibonacci_recursive(20 + i))
    
    # Prime number calculation
    print("  Computing prime numbers...")
    primes = compute_primes(10000)
    
    # Matrix operations
    print("  Performing matrix multiplication...")
    matrix = matrix_multiplication(50)
    
    # String processing
    print("  Processing strings...")
    string_ops = string_processing()
    
    # JSON processing
    print("  Processing JSON data...")
    json_ops = json_processing()
    
    # I/O simulation
    print("  Simulating I/O operations...")
    io_result = io_simulation()
    
    print(f"Workload complete! Processed {len(primes)} primes, "
          f"{len(fib_results)} fibonacci numbers, and more.")


def cpu_intensive_loop():
    """A tight CPU-bound loop for profiling"""
    result = 0
    for i in range(1000000):
        result += math.sqrt(i) * math.sin(i) * math.cos(i)
    return result


def main():
    """Main entry point for the application"""
    print("=" * 60)
    print("FLAMEGRAPH PROFILING DEMO APPLICATION")
    print("=" * 60)
    print()
    
    iterations = 3
    print(f"Running {iterations} iterations of mixed workload...\n")
    
    start_time = time.time()
    
    for i in range(iterations):
        print(f"\n--- Iteration {i + 1}/{iterations} ---")
        mixed_workload()
        
        print("  Running CPU intensive calculations...")
        cpu_result = cpu_intensive_loop()
    
    end_time = time.time()
    
    print("\n" + "=" * 60)
    print(f"Total execution time: {end_time - start_time:.2f} seconds")
    print("=" * 60)


if __name__ == "__main__":
    main()
