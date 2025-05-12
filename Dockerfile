FROM ubuntu:22.04 AS builder

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    clang-15 \
    libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Clang as the default compiler
ENV CC=clang-15
ENV CXX=clang++-15

# Set working directory
WORKDIR /src

# Copy source code
COPY . .

# Build the project
RUN cmake -B build -GNinja -DCMAKE_BUILD_TYPE=Release -DOBFUSCATOR_BUILD_TESTS=0
RUN cmake --build build --config Release

# Create a smaller runtime image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Copy the built executable from the builder stage
COPY --from=builder /src/build/src/bin/obfuscator /usr/local/bin/

WORKDIR /app

ENTRYPOINT ["obfuscator"]
CMD ["--help"] 