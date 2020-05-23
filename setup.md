##### Steps to setup HA cluster
Notes:
- See https://docs.mattermost.com/deployment/cluster.html for more info.
- Same steps can be ported to docker-compose to easily spin up the HA cluster.

1. Start database
```bash
docker run -d --name db -e POSTGRES_USER=mmuser -e POSTGRES_PASSWORD=mmuser_password -e POSTGRES_DB=mattermost mattermost/mattermost-prod-db
```

2. Start Minio as file storage
a. Start its docker image
```bash
docker run -d --name minio -p 9000:9000 -e MINIO_ACCESS_KEY=minioaccesskey -e MINIO_SECRET_KEY=miniosecretkey minio/minio server /data
```
b. Add `mattermost-test` as main folder
```bash
docker exec minio sh -c 'mkdir -p /data/mattermost-test'
```
c. Confirm that it's running by visiting ``localhost:9000`` and enter access/secret keys.

3. Start application servers
a. Save attached ``config.json`` to a folder
```bash
/tmp/mm/config/config.json
```
b. Grant permission to ``/tmp``.  Below is grant to all but correct approach is to grant specific user/group only.
```bash
sudo chmod -R a+rwx /tmp
```
c. Spin up the first application server and visit ``localhost:8065`` if working properly.
```bash
docker run -d --link db --link minio -p 8065:8065 -v /tmp/mm/config/config.json:/mattermost/config/config.json -v /tmp/mm/:/tmp/ --name app mattermost/mattermost-enterprise-edition:aef1d87
```
d. Spin up the first application server and visit ``localhost:8066`` if working properly.
```bash
docker run -d --link db --link minio --link app -p 8066:8065 -v /tmp/mm/config/config.json:/mattermost/config/config.json -v /tmp/mm/:/tmp/ --name app1 mattermost/mattermost-enterprise-edition:aef1d87
```

4. Expose the cluster with Nginx
a. Download and install Nginx
b. Save attached nginx conf as ``/etc/nginx/sites-available/mattermost`` and link to enable.
```bash
sudo ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost
```
c. Start Nginx
```
sudo systemctl start nginx
```
d. Should return without error and ``localhost`` or ``localhost:80`` should be accessible. ``localhost:8065`` and ``localhost:8066`` should still be accessible.

###### That's it! You've successfully setup an HA cluster.

5. Want to see logs, do ``docker logs -f [name]``