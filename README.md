# CUSTOM CONTAINERIZED TERRAFORM

This repository is a workaround to use terraform in Apple Silicon (M1) devices. The problem is that in some cases terraform does not have a native version for this architecture. You may get the following error:

"Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package available for your current platform, darwin_arm64."

You can workaround this issue by executing terraform inside a Docker container. This project provides a simple way to do it by overwriting the terraform and make commands with docker run commands.

## INSTALLATION

You just need to have docker installed. Please, proceed as follows:

1- Execute following command to use the last version of this tool.

```bash
curl https://raw.githubusercontent.com/gerardVM/custom-containerized-terraform/main/custom-terraform.sh > ~/.custom-terraform
```

2- Include an extra line to your ~/.bashrc file to source your new configuration.
```bash
echo "[ \$(echo \$(which docker)) ] && . ~/.custom-terraform" >> ~/.bashrc
```

Once these commands are executed, open a new terminal and then you are good to go.

Be aware that you may have limitations if you are trying to perform complex operations with these tools. Toolset is: make, mlocate, bash, openssh-client, and git

## HOW TO USE IT

Use your tools like you would normally do. You just need to set the version you want by setting the variable TF_VERSION.

In order to track versions, a .tf_<version>-alpine file will be created in each directory you use your tools.

## Contributing

Pull requests are welcome

## License

[MIT](LICENSE)
