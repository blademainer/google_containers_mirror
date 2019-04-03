#!/bin/sh
# 40 min
time_out_seconds=2400
start_timestamp=`date +%s`

maxCount=400
touch counter.tmp
touch skip.tmp
incr(){
    echo "1" >> counter.tmp
}

count(){
    cat counter.tmp | wc -l
}

clean(){
    rm -fr counter.tmp
}


! which gcloud 2>/dev/null && echo "please install cloud first! see: https://cloud.google.com/sdk/downloads" && exit -1
rm -f gcr-list.tmp
# gcloud container images list --repository gcr.io/google_containers

cat owners | while read owner; do
    echo "processing owner: $owner"
    if [ -z "$owner" ]; then
      continue;
    fi
    index=`gcloud container images list --repository gcr.io/$owner | awk '{for(i=1;i<=NF;i++){if("NAME"==$i){print i}}}'`
    gcloud container images list --repository gcr.io/$owner | awk 'NR>1{print $0}' | awk -v i=${index} '{print $i}' >> gcr-list.tmp

    #index=`docker search gcr.io/google_containers/ | awk '{for(i=1;i<=NF;i++){if("NAME"==$i){print i}}}'`
    #docker search gcr.io/google_containers/ | awk 'NR>2{print p}{p=$0}' | awk -v i=${index} '{print $i}' >> gcr-list.tmp
    docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
    name="googlecontainer"
    #[ ! -d "/etc/gcr" ] && mkdir -p /etc/gcr
    stored_file_list="google_containers_mirror_completed_list/gcr-complete-tasks"
    stored_image_list="google_containers_mirror_completed_list/gcr-complete-images"
    stored_repo="https://github.com/blademainer/google_containers_mirror_completed_list.git"
    
    if [ ! -f "google_containers_mirror_completed_list" ]; then
      git clone --depth 1 "${stored_repo}"
    else 
      echo "completed_list git repo exists! `ls -l google_containers_mirror_completed_list`"
      git --git-dir=google_containers_mirror_completed_list/.git --work-tree=google_containers_mirror_completed_list pull --depth 1 "${stored_repo}"
    fi
    
    [ ! -f "${stored_file_list}" ] && touch ${stored_file_list}
    [ ! -f "${stored_image_list}" ] && touch ${stored_image_list}
    cat  gcr-list.tmp | while read repo; do
      cat ignore_images | while read ignore_image; do
        if [ -n "`echo $repo | grep $ignore_image`" ]; then
          echo "$repo" >> skip.tmp
        fi
      done
      if [ -n "`cat skip.tmp | grep $repo`" ]; then
        echo "skip: $repo"
        continue;
      fi
      mkdir -p ${repo}
      #docker search ${repo} > ${repo}/list.tmp
      repo_name=${repo##*/}
      repo_url="gcr.io/${owner}/${repo_name}"
      #gcloud alpha container images list-tags ${repo_url} | awk 'NR>2{print p}{p=$0}' | awk '{print $1" "$2}' > ${repo}/tag.tmp
      gcloud  container images list-tags ${repo_url} > $repo_name.tmp
      echo "${repo_url} contains tag size: `wc -l $repo_name.tmp`"
      cat $repo_name.tmp | awk '{print $1" "$2}' | awk 'NR>1{print $0}' > ${repo}/tag.tmp
      cat ${repo}/tag.tmp | while read image tag; do
        repo_image="${repo_url}:${tag}"
        ignored="false"
        push_url="${name}/${repo_name}:${tag}"
        if [ -n "`echo "$push_url | grep latest"`" ]; then
          ignored="false"
        elif [ -n "`cat ${stored_file_list} | grep ^${repo_image}$`" ]; then
          echo "ignored push: ${push_url}" >> ignored.tmp
          ignored="true"
        fi
        
        if [ -n "`cat ${stored_image_list} | grep ^${image}$`" ]; then
          echo "ignored push image: ${image}" >> ignored.tmp
          ignored="true"
        fi
        
        if [ -z "`cat ${stored_file_list} | grep ^${repo_image}$`" ]; then
          echo "${repo_image}" >> $stored_file_list
        fi
        
        # echo "$repo_image is ignore: $ignored" 
          
        if [ "s$ignored" = "sfalse" ]; then
            docker pull ${repo_url}:${tag} && docker tag ${repo_url}:${tag} ${name}/${repo_name}:${tag} && docker push ${push_url};
            echo "${image}" >> ${stored_image_list}
            echo "pushed: ${push_url} image: ${image}"
            # time sh git_push.sh # use travis cache
            incr
            [ $(count) -gt $maxCount ] && echo "inner reach max: $maxCount" && break 2
            # timeout ?
            now_timestamp=`date +%s`
            [ $((now_timestamp-start_timestamp)) -gt $time_out_seconds ] && echo "timeout!!" && break 2
        fi
        #docker rmi ${push_url}

      done;

      #[ -n "`docker images -q`" ] && docker rmi -f $(docker images -q)
      #docker images > images.tmp
      #_i=`cat images.tmp |  awk -F "[ ]+" 'NR=1{for(i=1;i<=NF;i++){if($i=="IMAGE"){print i}}}'`
      #cat images.tmp | awk -F "[ ]+" -v i=${_i} 'NR>1{print $i}' | while read image_id; do
      #  echo "removing: ${image_id}"
      #  docker rmi -f $image_id
      #done
      [ $(count) -gt $maxCount ] && echo "out reach max: $maxCount" && break
      # timeout ?
      now_timestamp=`date +%s`
      [ $((now_timestamp-start_timestamp)) -gt $time_out_seconds ] && echo "timeout!!" && break
    done;
done

echo "ignored: `cat ignored.tmp`"
#time sh git_push.sh

