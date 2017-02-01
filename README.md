# docker-gc (docker garbage collector)

Docker garbage collector with exclusions

##Usage

You need to share docker.sock with your container's docker process.

Excludes images and containers as grep regex. eg. "mysql" will exclude "mysql" image and "mysql:5.6" image. Use space separated names.

```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
	-e EXCLUDE_IMAGES="mysql:5.6 nginx docker-gc dinghy-http-proxy" \
	-e EXCLUDE_CONTAINERS="dinghy-http-proxy" \
	davidpv/docker-gc
```
You can easily create a shell alias using your .bashrc or .bash_profile:

```
docker-clean(){
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
	-e EXCLUDE_IMAGES="mysql:5.6 nginx docker-gc dinghy-http-proxy" \
	-e EXCLUDE_CONTAINERS="dinghy-http-proxy" \
	davidpv/docker-gc
}
alias docker-clean=docker-clean
```

Or use it with shell parmeters:
```
docker-clean(){
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
	-e EXCLUDE_IMAGES="$1" \
	-e EXCLUDE_CONTAINERS="$2" \
	davidpv/docker-gc
}
alias docker-clean=docker-clean
```
