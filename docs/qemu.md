sudo apt install qemu-system-x86

-machine help
microvm

-cpu help

-display curses
-display none
-nographic
-vga std|cirrus
-no-acpi  

-bios file 

-singlestep 
-no-reboot 

-m 512m -smp 2 \
   -kernel vmlinux -append "earlyprintk=ttyS0 console=ttyS0 root=/dev/vda" \
   -nodefaults -no-user-config -nographic \
   -serial stdio \
   -drive id=test,file=test.img,format=raw,if=none \
   -device virtio-blk-device,drive=test \
   -netdev tap,id=tap0,script=no,downscript=no \
   -device virtio-net-device,netdev=tap0