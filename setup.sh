#!/bin/sh

SMP=8
[ -n "${CPU_COUNT}" ] && SMP=${CPU_COUNT}

DSIZE='64G'
[ -n "${DISK_SIZE}" ] && DSIZE=${DISK_SIZE}

RSIZE='16G'
[ -n "${RAM_SIZE}" ] && RSIZE=${RAM_SIZE}

NIC='rtl8139'
[ -n "${NIC_MODEL}" ] && NIC=${NIC_MODEL}

CPU="-cpu Penryn,vendor=GenuineIntel,vmware-cpuid-freq=on"
[ -e /dev/kvm ] && CPU="-enable-kvm -cpu Penryn,vendor=GenuineIntel,vmware-cpuid-freq=on,kvm=on"

echo "create disk image..."
qemu-img create -f qcow2 /images/disk1.qcow2 ${DSIZE}

webserver() {
	echo "start webserver..."
	cd /images/iso
	python3 -m http.server 80
}

webserver &

ipxeboot() {
	sleep 3
	exec /ipxeboot
}

setupwindows() {
	echo "setup vm..."
	qemu-system-x86_64 \
	    -m ${RSIZE} -smp ${SMP} \
	    -machine q35 -cpu ${CPU} \
            -chardev socket,host=0.0.0.0,port=4444,server=on,telnet=on,id=charserial0 \
	    -usb -device usb-tablet \
	    -netdev user,id=n0,smb=/images/iso -device ${NIC},netdev=n0 \
	    -drive file=/images/disk1.qcow2,if=ide,index=0,media=disk \
	    -drive file=/images/ipxe.iso,if=ide,index=1,media=cdrom \
	    -spice port=3001,disable-ticketing=on -boot d -nographic -serial chardev:charserial0 -monitor unix:/tmp/qemu,server,nowait
}

interact() {
	# select edition
	while true; do
		sleep 30
		echo "screendump /tmp/screen.ppm" | socat - UNIX-CONNECT:/tmp/qemu
		sleep 1
		tesseract /tmp/screen.ppm - -l eng
		if [ ! -z "$(tesseract /tmp/screen.ppm - -l eng | grep 'Server 2019')" ]; then
			echo "sendkey down" | socat - UNIX-CONNECT:/tmp/qemu
			echo "sendkey ret" | socat - UNIX-CONNECT:/tmp/qemu
			rm /tmp/screen.ppm
			break
		fi
	done

	# for monitor installation progress
	while true; do
		sleep 10
		echo "screendump /tmp/screen.ppm" | socat - UNIX-CONNECT:/tmp/qemu
		sleep 1
		tesseract /tmp/screen.ppm - -l eng
	done
}

ipxeboot &
interact &
setupwindows
