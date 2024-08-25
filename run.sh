#!/bin/sh

SMP=8
[ -n "${CPU_COUNT}" ] && SMP=${CPU_COUNT}

RSIZE='16G'
[ -n "${RAM_SIZE}" ] && RSIZE=${RAM_SIZE}

NIC='e1000'
[ -n "${NIC_MODEL}" ] && NIC=${NIC_MODEL}

CPU="-cpu Penryn,vendor=GenuineIntel,vmware-cpuid-freq=on"
[ -e /dev/kvm ] && CPU="-enable-kvm -cpu Penryn,vendor=GenuineIntel,vmware-cpuid-freq=on,kvm=on"

startvm() {
	echo "start vm..."
	qemu-system-x86_64 \
	    -m ${RSIZE} -smp ${SMP} \
	    -machine q35 ${CPU} \
	    -usb -device usb-tablet -vga none -device qxl-vga,vgamem_mb=2048 \
	    -netdev user,id=n0,hostfwd=tcp::22-:22,hostfwd=tcp::3389-:3389,smb=/images/iso -device ${NIC},netdev=n0 \
	    -drive file=/images/disk1.qcow2,if=ide,index=0,media=disk \
	    -spice port=3001,disable-ticketing=on -nographic -serial none -monitor unix:/tmp/qemu,server,nowait
}

startvm &


until sshpass -p admin ssh -o StrictHostKeyChecking=no -t admin@localhost echo started; do
	echo "wait for vm to start..."
	sleep 5
done

sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -t admin@localhost $@
