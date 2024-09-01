#!/bin/sh

/runvm.sh &

until sshpass -p admin ssh -o StrictHostKeyChecking=no -p 2222 -t admin@localhost echo started; do
	echo "wait for vm to start..."
	sleep 5
done

sshpass -p 'admin' ssh -o StrictHostKeyChecking=no -p 2222 -t admin@localhost $@
