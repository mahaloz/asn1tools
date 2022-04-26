FROM ubuntu:18.04 as builder 

USER root 
RUN apt-get update && apt-get install -y sudo sshfs bsdutils python3-dev python-pip \
    automake autoconf coreutils bison libacl1-dev \
    llvm clang \
    build-essential git \
    libffi-dev cmake libreadline-dev libtool netcat net-tools vim 


# ----- target ----- #
# get source and compile
COPY . /asn1tools
RUN cd /asn1tools && \
    clang -fprofile-instr-generate -fcoverage-mapping -Itests/files/c_source -g -fsanitize=address,fuzzer -fsanitize=signed-integer-overflow -fno-sanitize-recover=all tests/main_oer_fuzzer.c tests/files/c_source/oer.c -o main_oer_fuzzer && \
    cp main_oer_fuzzer /fuzz_main_oer_input

FROM ubuntu:18.04
COPY --from=builder /fuzz_main_oer_input /
