
#!/bin/bash

image=${1}
[[ -z "$image" ]] && echo "image is null!" && exit 1
docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
newImage=`echo "googlecontainer/${image##*/}"`
docker pull $image
docker tag $image $newImage
docker push $newImage
echo "push to $newImage success!"

