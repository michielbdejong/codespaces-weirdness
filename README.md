# CodeSpaces Weirdness

See https://github.com/community/community/discussions/38878 for discussion.

Super weird:
Open this repo in GitHub Codespaces, open the terminal, and then:
```
cd d1
docker build -t d1 --no-cache .
cd ../d2

docker build -t d2 --no-cache .
docker run d2
# you will see "Hello from d1"

docker build -t d2 --no-cache .
docker run d2
# you will see "Hello from d1"

touch Dockerfile
docker build -t d2 --no-cache .
docker run d2
# you will see "Hello from d1"
```

So even though I'm building both the oc1 and the oc2 image with --no-cache,
in the output from the Docker build process for oc2 you can already see:
```
=> [2/2] RUN echo Hello from d1 > greeting.txt
```
Instead of the expected:
```
=> [2/2] RUN echo Hello from d2 > greeting.txt
```

It seems that contents of the first Dockerfile the Docker engine reads is contaminating the Dockerfile contents for the second build.

It also works the other way around, if you build the oc2 image first and then the oc1 image, then the oc1 build will use build steps from the oc2 Dockerfile. Whichever one you build first contaminates the one you build second.

Another way to stop the contamination: `touch ../d1/Dockerfile` instead of `touch ./Dockerfile` also works. But only if you build it after touching. So:
* build d1
* touch the d1 Dockerfile
* build d2
  -> result will be contaminated

But:
* build d1
* touch the d1 Dockerfile
* build d1 again
* build d2
  -> result will be correct

So touching one of the two and then building the touched Dockerfile
apparently breaks the illusion of similarity.

Didn't believe what you saw? Want to see it again? You can replay this over and over again. From the repo root:
```
rm -r d*
git checkout -- d*
```
Now repeat the test and it will display the broken behaviour again (d2 will output "Hello from d1").

Apparently the two Dockerfiles look alike to Docker, and it makes Docker not read the second one if it has already seen the other one.
Touching one of the two Dockerfiles apparently helps, but then resetting the git repository brings the problem back.

I would like to see what happens if you restart the Docker service in the workspace, but I don't know how to do that (it's not `service docker restart`, apparently).
