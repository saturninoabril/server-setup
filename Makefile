.PHONY: setup

TAG?=master

clean-app:
	docker stop app
	docker stop app1
	docker rm app
	docker rm app1

	docker images -a | grep "mattermost-enterprise-edition" | awk '{print $3}' | xargs docker rmi

setup-app:
	docker run -d --link db --link minio -p 8065:8065 -v /tmp/mm/config/config.json:/mattermost/config/config.json -v /tmp/mm/:/tmp/ --name app mattermost/mattermost-enterprise-edition:$(TAG)

	docker run -d --link db --link minio --link app -p 8066:8065 -v /tmp/mm/config/config.json:/mattermost/config/config.json -v /tmp/mm/:/tmp/ --name app1 mattermost/mattermost-enterprise-edition:$(TAG)
