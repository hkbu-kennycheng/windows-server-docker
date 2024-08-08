#!/bin/sh


RSIZE='16G'
[ -n "${RAM_SIZE}" ] && RSIZE=${RAM_SIZE}

NIC='e1000'
[ -n "${NIC_TYPE}" ] && NIC=${NIC_TYPE}

KVM=""
[ -f /dev/kvm ] && KVM=-enable-kvm

startvm() {
#	echo "start vm..."
	qemu-system-x86_64 \
	    -m ${RSIZE} -smp 16 \
	    -machine q35 ${KVM} -cpu Penryn,vendor=GenuineIntel,vmware-cpuid-freq=on \
	    -usb -device usb-tablet -vga none -device qxl-vga,vgamem_mb=2048 \
	    -netdev user,id=n0,hostfwd=tcp::22-:22,smb=/images/iso -device ${NIC},netdev=n0 \
	    -drive file=/images/disk1.qcow2,if=ide,index=0,media=disk \
	    -vnc :0 -nographic -serial none -monitor unix:/tmp/qemu,server,nowait
}

startvm &

#while true; do
#	sleep 10
#	echo "screendump /tmp/screen.ppm" | socat - UNIX-CONNECT:/tmp/qemu
#	sleep 1
#	tesseract /tmp/screen.ppm - -l eng
#done

echo "wait for vm to start..."
while ! nc -z localhost 22; do
	sleep 10
done

#sleep 30

sleep 360

sendkeys "<meta_l-d>" | socat - UNIX-CONNECT:/tmp/qemu
sleep 5
sendkeys "<meta_l-r>" | socat - UNIX-CONNECT:/tmp/qemu
sleep 5
sendkeys "cmd<ret>" | socat - UNIX-CONNECT:/tmp/qemu
sleep 30
sendkeys "net use x: \\\\10.0.2.4\\qemu<ret>" | socat - UNIX-CONNECT:/tmp/qemu
sleep 5
sendkeys "start /w X:\\vs_community.exe --norestart -p --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NativeGame --add Microsoft.VisualStudio.Workload.Universal --includeRecommended --includeOptional<ret>" | socat - UNIX-CONNECT:/tmp/qemu


sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -t admin@localhost $@
