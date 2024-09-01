FROM alpine

RUN apk update && apk add --no-cache git expect 7zip tesseract-ocr-data-eng \
    py3-pip msitools qemu-img qemu-system-x86_64 qemu-modules samba openssh \
    inetutils-telnet ruby socat sshpass

RUN mkdir -p /images/iso && \
    wget http://boot.ipxe.org/ipxe.iso -O /images/ipxe.iso && \
    wget https://github.com/ipxe/wimboot/releases/latest/download/wimboot -O /images/iso/wimboot && \
    echo 'wpeinit' >> /images/iso/install.bat && \
    echo 'net use \\10.0.2.4\qemu' >> /images/iso/install.bat && \
    echo '\\10.0.2.4\qemu\setup.exe /unattend:\\10.0.2.4\qemu\autounattend.xml' >> /images/iso/install.bat && \
    echo '[LaunchApps]' >> /images/iso/winpeshl.ini && \
    echo '"install.bat"' >> /images/iso/winpeshl.ini && \
    echo '#!ipxe' >> /images/iso/boot.ipxe && \
    echo 'kernel wimboot' >> /images/iso/boot.ipxe && \
    echo 'initrd install.bat install.bat' >> /images/iso/boot.ipxe && \
    echo 'initrd winpeshl.ini winpeshl.ini' >> /images/iso/boot.ipxe && \
    echo 'initrd autounattend.xml autounattend.xml' >> /images/iso/boot.ipxe && \
    echo 'initrd boot/bcd BCD' >> /images/iso/boot.ipxe && \
    echo 'initrd boot/boot.sdi boot.sdi' >> /images/iso/boot.ipxe && \
    echo 'initrd sources/boot.wim boot.wim' >> /images/iso/boot.ipxe && \
    echo 'boot' >> /images/iso/boot.ipxe

ARG ISO_URL=https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso
RUN wget "$ISO_URL" -O /images/cdrom.iso && \
    7z x /images/cdrom.iso -o/images/iso && rm /images/cdrom.iso
ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64.zip /images/iso/OpenSSH-Win64.zip
ADD autounattend.xml /images/iso/autounattend.xml
ADD ipxeboot /ipxeboot
ADD setup.sh /setup.sh
ADD runvm.sh /runvm.sh
ADD run.sh /run.sh
ADD https://raw.githubusercontent.com/mvidner/sendkeys/master/sendkeys /bin/sendkeys
RUN chmod +x /bin/sendkeys && apk add ruby

ARG CPU_COUNT
ARG DISK_SIZE
ARG RAM_SIZE
ARG NIC_MODEL

RUN /setup.sh

EXPOSE 2222 3001 3389 8080

RUN /run.sh powershell.exe -Command "\$ProgressPreference = 'SilentlyContinue'; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); shutdown /s /t 0"

ENTRYPOINT ["/run.sh"]
