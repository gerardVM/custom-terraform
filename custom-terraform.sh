#!bin/bash


##### BUILD CUSTOM IMAGE #####

function build-custom-image() (

  function update-version { rm -f .${1}_* ; echo "Created by cusom-containerized-terraform" > .${1}_${2}-${3} ; }

  function show-tools-version {
    echo -e "Building image from ${1}... your setup is:" && sleep 0.2 && 
    echo "terraform $(find-version tf)" && sleep 0.2; 
  }

  function build-dockerfile() {
    local base_image=${1}
    local manager="apk"
    local install="add"
    local move="mv"
    local ARCH=$(docker inspect --format='{{.Architecture}}' $base_image)

    echo -e "
    FROM --platform=linux/amd64 $base_image \n\nRUN $manager update
    RUN $manager $install make mlocate bash openssh-client git
    
    # Terraform installation

    RUN wget https://releases.hashicorp.com/terraform/$(find-version tf)/terraform_$(find-version tf)_linux_${ARCH}.zip \
    && unzip terraform_$(find-version tf)_linux_${ARCH}.zip && rm terraform_$(find-version tf)_linux_${ARCH}.zip \
    && $move terraform /usr/bin/terraform" > /tmp/Dockerfile ;
  }

  local base_image=${1}
  local base_alias=${2}

  # Show info message including Terraform version
  show-tools-version $base_image

  # Build the Dockerfile
  docker pull $base_image && build-dockerfile $base_image && docker rmi $base_image
  
  # Delete previous image if exists
  no-image "custom-terraform" || docker rmi $(docker images -q custom-terraform)

  # Build the new image
  docker build --no-cache -q -t custom-terraform:$(find-version tf)-$base_alias /tmp && rm /tmp/Dockerfile ;

  # Update version tracker
  update-version tf $(find-version tf) $base_alias
)


##### EXECUTE CONTAINER #####

function execute-custom-image() (

  function no-image() { [[ "$(docker images -q ${1} 2> /dev/null)" == "" ]] ; }  
  function any-version-available() { find . -name .tf_* -print -quit | grep -q . || [ -v TF_VERSION ] ; }
  function find-version() { [ -v TF_VERSION ] && echo $TF_VERSION || ls .${1}_* | cut -d "_" -f 2 | cut -d "-" -f 1 ; }
  function get-distro() { docker run --rm --entrypoint cat -it ${1} /etc/os-release | grep ^ID= | cut -d "=" -f 2; }

  local base_image=${1}
  local image_name=${2}
  local entrypoint=${3}

  if any-version-available tf ; then

    local base_alias=$(echo $base_image | cut -d ":" -f 1)
    local image_id=$image_name:$(find-version tf)-$base_alias

    # Build image if not exists
    no-image $image_id && build-custom-image $base_image $base_alias

    # Inform the user about the usage of the container
    echo "You got into a container based in $(get-distro $image_id)"

    # Execute the container
    docker run --rm -it --entrypoint $entrypoint -v ${HOME}:/root -w /root${PWD#$HOME} -e TF_LOG=$TF_LOG $image_id ${@:4} ; 

  else
      echo "Error! You need to set a TF_VERSION variable" && return 1
  fi

)


##### MAIN FUNCTIONS #####

function make() { execute-custom-image alpine:latest custom-terraform make ${@} ; }
function terraform() { execute-custom-image alpine:latest custom-terraform terraform ${@} ; }