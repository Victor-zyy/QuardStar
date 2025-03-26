SHELL_FOLDER=$(cd "$(dirname "$-1")";pwd)

# compile qemu
cd qemu-6.0.0
if [ ! -d "$SHELL_FOLDER/output/qemu" ]; then
./configure --prefix=$SHELL_FOLDER/output/qemu --target-list=riscv64-softmmu --enable-gtk --enable-virtfs --disable-gio
fi

make -j4
make install

cd ..

