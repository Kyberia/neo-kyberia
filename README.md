# kyberia

## Docker for local kyberia development

This image is based on CentOS 7.x which is compatible with Red Hat 7.x.
Percona Server for MySQL 5.7 is used as the database server.

Building the image requires a database dump, which will be imported while
building. Put `kyberia-db.sql` into the `data` directory and build the
image.

Build the image:
```
docker build --rm -t kyberia/www -f docker/Dockerfile .
```

From a docker image, you can create multiple containers, which are like an
instance of an image. Only one container will be usually needed for
kyberia development.

Run the container:
```
mkdir -p mysqld-socket
docker run \
    --name kyberia \
    -v mysqld-socket:/var/run/mysqld \
    -e TERM=screen-256color -ti kyberia/www
```
