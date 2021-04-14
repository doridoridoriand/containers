#!/bin/bash

# このシェルはMacOSでしか動きません;-p

# 仮想マシン名
vmName=ubuntu-basemachine

# CPUはホストの全コア割り当て
numOfCPU=`system_profiler SPHardwareDataType | grep "Total Number of Cores" | grep -o '[0-9]' | tr -d '\n'`;

# メモリはホストの25%割り当て
totalMachineMemory=`system_profiler SPHardwareDataType | grep "Memory" | grep -o '[0-9]' | tr -d '\n'`;
numOfMem=`echo $(($totalMachineMemory/4))`;

# ディスク決め打ちで64GB
numOfDisk=64;

# e.g. https://cloudinit.readthedocs.io/en/latest/topics/modules.html
multipass launch --cpus $numOfCPU --disk "${numOfDisk}GB" --mem "${numOfMem}GB" --name $vmName --cloud-init cloud-config.yml;
