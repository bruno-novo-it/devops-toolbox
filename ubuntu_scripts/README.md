# Necessary script for Ubuntu installation

## To a fresh new Ubuntu installation, just use [this](https://gist.github.com/bruno-novo-it/6d074ebbd615ac02f4caa1376c431a42) Gist

### For a Homeserver, install Ubuntu and execute:

```sh
sudo apt-get update && \
    sudo apt-get install openssh-server && \
    sudo systemctl enable ssh --now && \
    sudo systemctl start ssh && \
    sudo systemctl status ssh
```

Your server will be read to receive connections

To copy your ssh key to the server:

```sh
export SERVER_USERNAME=server_user
export SERVER_IP=192.168.0.15
ssh-copy-id ${SERVER_USERNAME}@${SERVER_IP}
```

Enter the password and it's done
