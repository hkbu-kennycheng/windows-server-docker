# Dockerfile to build a Windows Server image with SSH enabled

This Dockerfile will build a Windows Server 2019 Evaluation image with SSH enabled and chocolatey installed.

## Usage

You could build the image with podman>=5.1.1 using the following command:

```bash
podman build -t windows-ssh \
    --build-arg=CPU_COUNT=$(nproc) \
    --build-arg=RAM_SIZE=64G \
    --build-arg=DISK_SIZE=256G \
    --security-opt=seccomp=unconfined \
    --device=/dev/kvm . \
    --network=pasta:-t,auto,-u,auto,-T,auto,-U,auto \
    .
```
