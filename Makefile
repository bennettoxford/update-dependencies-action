DOCKER_TTY:=$(shell [ -t 0 ] && echo "-t")

lint:
	docker run --rm $(DOCKER_TTY) -v $$(pwd):/repo --workdir /repo rhysd/actionlint:latest

tag-release:
	git tag v1 --force
	git push --tags --force
