FROM dlang2/dmd-ubuntu:latest as builder

RUN apt-get install libssl-dev libevent-dev -y

COPY . /app
WORKDIR /app
RUN dub build --build=release

FROM dlang2/dmd-ubuntu:latest 

WORKDIR /app
COPY --from=builder /app/projekt /app/projekt

EXPOSE 8080

CMD ["/app/projekt"] 