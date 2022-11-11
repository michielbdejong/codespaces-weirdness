# CodeSpaces Weirdness

Super weird:
Open this repo in GitHub Codespaces, then:
```
./test.sh
# you will see HOST=oc1
touch servers/oc2/Dockerfile
./test.sh
# you will see HOST=oc2
```

So even though I'm building both the oc1 and the oc2 image with --no-cache,
in the output from the Docker build process you can already see:
```
=> [2/3] RUN ln -s /tls/oc1.crt /tls/server.cert
=> [3/3] RUN ln -s /tls/oc1.key /tls/server.key
```
Instead if the expected:
```
=> [2/3] RUN ln -s /tls/oc1.crt /tls/server.cert
=> [3/3] RUN ln -s /tls/oc1.key /tls/server.key
```

It seems that intermediate build step results from the oc1 build are contaminating the oc2 build.

It also works the other way around, if you build the oc2 image first and then the oc1 image, then whichever one you build second gets contaminated by the one you build first.