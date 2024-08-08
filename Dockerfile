FROM alpine

RUN apk update && apk add --no-cache git expect 7zip tesseract-ocr-data-eng py3-pip msitools \
    qemu-img qemu-system-x86_64 qemu-modules samba openssh inetutils-telnet socat sshpass

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


RUN wget https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso -O /images/cdrom.iso && \
    7z x /images/cdrom.iso -o/images/iso && rm /images/cdrom.iso
ADD autounattend.xml /images/iso/autounattend.xml

ADD ipxeboot /ipxeboot
ADD setup.sh /setup.sh
RUN /setup.sh
ADD run.sh /run.sh



ADD https://aka.ms/vs/17/release/vs_community.exe /images/iso/vs_community.exe

RUN echo "net use X: \\\\10.0.2.4\\qemu" >> /images/iso/installvs.bat && \
    echo "X:\\vs_community.exe --norestart -q --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NativeGame --add Microsoft.VisualStudio.Workload.Universal --includeRecommended --includeOptional --lang en-US" >> /images/iso/installvs.bat

ADD https://raw.githubusercontent.com/mvidner/sendkeys/master/sendkeys /bin/sendkeys
RUN chmod +x /bin/sendkeys && apk add ruby

#RUN /run.sh "net use X: \\\\10.0.2.4\\qemu && cmd.exe /c start /w X:\\vs_community.exe --norestart --layout c:\\localVSlayout --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NativeGame --add Microsoft.VisualStudio.Workload.Universal --includeRecommended --includeOptional --lang en-US"

ENTRYPOINT ["/run.sh"]
