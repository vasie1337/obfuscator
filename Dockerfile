FROM ubuntu:22.04 AS builder

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    clang-15 \
    libstdc++-12-dev \
    libc++-15-dev \
    libc++abi-15-dev \
    libfmt-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Clang as the default compiler
ENV CC=clang-15
ENV CXX=clang++-15

# Set working directory
WORKDIR /src

# Copy source code
COPY . .

# Build the project
RUN cmake -B build -GNinja -DCMAKE_BUILD_TYPE=Release -DOBFUSCATOR_BUILD_TESTS=0 \
    -DCMAKE_CXX_FLAGS="-DFMT_HEADER_ONLY -I/usr/include/fmt -include fmt/format.h -D'std::format=fmt::format' -D'std::vformat=fmt::vformat' -D'std::make_format_args=fmt::make_format_args' -D'std::make_wformat_args=fmt::make_format_args'"

RUN cmake --build build --config Release

# Create a smaller runtime image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    libfmt8 \
    && rm -rf /var/lib/apt/lists/*

# Copy the built executable from the builder stage
COPY --from=builder /src/build/src/bin/obfuscator /usr/local/bin/

WORKDIR /app

ENTRYPOINT ["obfuscator"]
CMD ["--help"] 