# CodeSpaces Weirdness

Super weird:
Open this repo in GitHub Codespaces, then:
```
./build.sh
docker run -it oc2 env | grep HOST=
# you will see HOST=oc1
touch servers/oc2/Dockerfile
docker run -it oc2 env | grep HOST=
# you will see HOST=oc2
```
