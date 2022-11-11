# CodeSpaces Weirdness

Super weird:
Open this repo in GitHub Codespaces, open the terminal, and then:
```
./test.sh
# you will see HOST=oc1
touch servers/oc2/Dockerfile
./test.sh
# you will see HOST=oc2
```

So even though I'm building both the oc1 and the oc2 image with --no-cache,
in the output from the Docker build process for oc2 you can already see:
```
=> [2/3] RUN ln -s /tls/oc1.crt /tls/server.cert
=> [3/3] RUN ln -s /tls/oc1.key /tls/server.key
```
Instead of the expected:
```
=> [2/3] RUN ln -s /tls/oc2.crt /tls/server.cert
=> [3/3] RUN ln -s /tls/oc2.key /tls/server.key
```

It seems that contents of the first Dockerfile the Docker engine reads is contaminating the Dockerfile contents for the second build.

It also works the other way around, if you build the oc2 image first and then the oc1 image, then the oc1 build will use build steps from the oc2 Dockerfile. Whichever one you build first contaminates the one you build second.

Another way to stop the contamination: `touch servers/oc1/Dockerfile` instead of `touch servers/oc2/Dockerfile` also works. But only if you build it after touching. So:
* build oc1
* touch the oc1 Dockerfile
* build oc2
  -> result will be contaminated

But:
* build oc1
* touch the oc1 Dockerfile
* build oc1 again
* build oc2
  -> result will be correct

So touching one of the two and then building the touched Dockerfile
apparently breaks the illusion of similarity.

Didn't believe what you saw? Want to see it again? You can replay this over and over again:
```
rm -r servers
git checkout -- servers
test.sh
```
And it will display the broken behaviour again ("HOST=oc1").

Apparently the two Dockerfiles look alike to Docker, and it makes Docker not read the second one if it has already seen the other one.
Touching one of the two Dockerfiles apparently helps, but then resetting the git repository brings the problem back.

I would like to see what happens if you restart the Docker service in the workspace, but I don't know how to do that (it's not `service docker restart`, apparently).