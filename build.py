#!/usr/bin/env python

import os
import subprocess
import time
import datetime

def build(core, LocalVersionArg=None, cleanBuild=True):
    if LocalVersionArg is not None:
        localversion = "QuantumKernel-%s" % LocalVersionArg
        os.environ["LOCALVERSION"] = "-" + str(localversion)
    
    if cleanBuild is True:
        print("Preparing to build...generating configs...")
        time.sleep(1)
        os.system("make cyanogenmod_d802_defconfig && make menuconfig && make kernelrelease")

        cmd = "make -j%s" % core
        print("Building..")
        time.sleep(1)
        os.system(cmd)
       
    else:
        cmd = "make -j%s" % core
        print("Building..")
        time.sleep(1)
        os.system(cmd)
        
        
    
    print("Generating boot.img")
    time.sleep(1)
    if os.path.isfile("arch/arm/boot/zImage"):
         subprocess.call('executables/mkbootimg_dtb --kernel arch/arm/boot/zImage-dtb --ramdisk executables/ramdisk.gz --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=g2 user_debug=31 msm_rtb.filter=0x0 mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_lgd_cmd androidboot.selinux=enforcing" --base 0x00000000 --pagesize 2048 --offset 0x05000000 --tags-addr 0x04800000 --dt executables/dt.img -o boot.img', shell=True)
    else:
         print("Error...zImage doesn't exist, the build probably failed")
         raise SystemExit

    print("Bumping...")
    time.sleep(1)
    subprocess.call("python executables/open_bump.py boot.img", shell=True)
    
    print("Packing into flashable zip...")
    time.sleep(1)
    os.system("rm -f zip/boot.img && rm -f zip/Quantum*")
    os.system("mv boot_bumped.img zip/boot.img")
    try:
        cmd = "cd zip && zip -r -9 " + (str(localversion) + ".zip") + " *"
        os.system(cmd)
    except TypeError:
        cmd = 'cd zip && zip -r -9 "QuantumKernel-undefined-cm12.zip" *'
        os.system(cmd)

    print("Done! Closing processes...")
    subprocess.call("rm include/generated/compile.h", shell=True)
    subprocess.call("rm .build.py.conf", shell=True)
    time.sleep(2)
    raise SystemExit

def genRamdisk():
    print("Please download a boot.img file for your device (maybe in CM zips?)")
    print("If you've already downloaded one, just press Enter at the next prompt.")
    raw_input("Press Enter when you have extracted that boot.img into the executables/stockBoot folder: ")

    if os.path.isfile("executables/stockBoot/boot.img"):
        print("Processing ramdisk...")
        time.sleep(1)
        os.system("executables/split_boot executables/stockBoot/boot.img")
        if os.path.isfile("executables/ramdisk.gz"):
            os.system("rm executables/ramdisk.gz")
        os.system("executables/mkbootfs boot/ramdisk | gzip > executables/ramdisk.gz")
        os.system("rm -r boot")
    else: 
        print("Please download the boot.img file for your device, and make sure it is in the correct folder.")
        raise SystemExit

def genDT():
    print("Generating dt.img from sources...")
    os.system("rm executables/dt.img")
    os.system("executables/dtbTool -s 2048 -o executables/dt.img -p scripts/dtc/ arch/arm/boot/")   

subprocess.call("clear", shell=True)
print("QuantumKernel build script by alexpotter1.")
print("Some questions...")
time.sleep(1)
print("----------------------------------------------------------------------------------------------------------")

if os.path.isfile("include/generated/compile.h"):
    print("An incomplete build was detected.")
    print("You probably didn't run make clean or there was an error last time.")
    print("Note: this will cause a 'dirty' compile, but it can be useful when diagnosing errors.")
    
    try:
        with open(".build.py.conf") as f:
            lines = f.read().splitlines()
        print("Last build date:   %s" % lines[0])
        print("Last build version: %s" % lines[1])

        os.environ["LOCALVERSION"] = lines[1]
        f.close()
    except:
        subprocess.call("touch .build.py.conf", shell=True)
        print("----------------------------------------------------------------------------------------------------------")
        print("IOError occurred. Please run this program again.")
        time.sleep(1.5)

        f = open(".build.py.conf", "w")
        f.write("01-01-1970 00:00\n")
        f.write("vTest-initSetup")
        f.close()

        raise SystemExit

    print("----------------------------------------------------------------------------------------------------------")
    time.sleep(1)
    contChoice = raw_input("Do you wish to continue with this build? (y/n): ").upper()
    if contChoice == "Y":
        try:
            coreChoice = int(raw_input("Number of CPU cores to use: "))
        except TypeError:
            print("You didn't type an integer")
    
        build(coreChoice, cleanBuild=False)     
        
     
ramdiskChoice = raw_input("Do you want to generate a new ramdisk? (y/n): ").upper()

if ramdiskChoice == "Y":
    genRamdisk()

dtChoice = raw_input("Do you want to generate a new dt.img file? (y/n): ").upper()

if dtChoice == "Y":
    genDT()

cleanChoice = raw_input("Do you want to make clean? Beware of build errors if you choose not to. (y/n/exit): ").upper()

if cleanChoice == "Y":
    os.system("make clean && make mrproper")
    subprocess.call("rm .build.py.conf && touch .build.py.conf", shell=True)

elif cleanChoice == "EXIT":
    raise SystemExit

try:
    coreChoice = int(raw_input("Number of CPU cores to use: "))
except TypeError:
    print("You didn't type an integer")

localChoice = raw_input("Do you want to change the version number?: ").upper()

if localChoice == "Y":
    localArg = raw_input("Enter new version number: ")
    subprocess.call("touch .build.py.conf", shell=True)
    f = open(".build.py.conf", "w")

    now = datetime.datetime.now()
    timeDate = now.strftime("%d-%m-%Y %H:%M")
    f.write(timeDate + "\n")
    f.write(localArg)
    f.close()
    build(coreChoice, LocalVersionArg=str(localArg))

elif localChoice == "N":
    subprocess.call("touch .build.py.conf", shell=True)
    f = open(".build.py.conf", "w")

    now = datetime.datetime.now()
    timeDate = now.strftime("%d-%m-%Y %H:%M")
    f.write(timeDate + "\n")
    f.write(localArg)
    f.close()
    build(coreChoice)

else:
    print("You didn't type y or n")


