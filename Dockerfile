FROM ubuntu:22.04 as build

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    cmake \
    git \
    cargo \
    rustc \
    clang \
    uuid-dev && \
    apt-get clean

RUN git clone https://github.com/GothenburgBitFactory/taskwarrior.git task-3.0.0
RUN sed -i '/taskchampion\/integration-tests/d' task-3.0.0/Cargo.toml
RUN cd task-3.0.0 && cargo build
RUN cd task-3.0.0 && cmake -DCMAKE_BUILD_TYPE=release .
RUN cd task-3.0.0 && make && make install

FROM ubuntu:22.04 

COPY --from=build /usr/local/bin/task /usr/local/bin/task
COPY --from=build /task-3.0.0/target/debug/taskchampion-sync-server /usr/local/bin/tasksync

CMD ["tasksync"]
