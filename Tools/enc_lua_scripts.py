#coding:utf-8

import os
import sys
import struct
import shutil
import platform
import ctypes  

ll = ctypes.cdll.LoadLibrary   
sysstr = platform.system()
if sysstr == "Linux":
    libxxtea = ll("./xxtea.so") 
elif sysstr == "Windows":
    libxxtea = ll("./xxtea.dll") 


def xor_enc_data(data, data_len, key):
    data_ret = ""
    #data_len = len(data)
    for i in range(0, data_len/2):
    	n = struct.unpack("<H", data[i*2 : (i*2)+2])[0]
    	nn = struct.unpack("<H", struct.pack("<H", n ^ key))[0]
    	#print("%x %d --- %x"%(n,i*2, nn))
    	data_ret += struct.pack("<H", n ^ key)

    left = data_len%2
    if left > 0:
    	data_ret += data[data_len - left: data_len]
    	pass
    if len(data_ret) != data_len:
        print "error"
    return data_ret

def xxtea_enc_data(data): 
    libxxtea.xxtea_enc(data, len(data))
    return data

def enc_file_to(file_path, to_path, key, islog):
    f = open(file_path, "rb")	
    #data_len = os.path.getsize(file_path)
    data = f.read()
    #encdata = xor_enc_data(data, len(data), key)
    encdata = xxtea_enc_data(data)
    if islog :
        print "enc_file", file_path, " file size", os.path.getsize(file_path), "to", to_path, "data len", len(data), " encdata len ", len(encdata)
    f_to = open(to_path, "wb")
    f_to.write(encdata)
    f_to.flush()
    f.close()
    f_to.close()

def enc_path_to(src, dst, key):
    for _o in os.listdir(src):
        fpath = src + '\\' + _o
        if os.path.isdir(fpath):
            os.mkdir(dst + '\\' + _o)
            enc_path_to(fpath, dst + '\\' + _o, key)
        else:
            if _o.endswith(".lua"):
                enc_file_to(fpath, dst + '\\'+ _o, key, False)

def main():
    try:
        if len(sys.argv) < 3:
    		print('need in put lua script src dir and dst dir')
    		exit(100)
        src_path = sys.argv[1]
        dst_path = sys.argv[2]
        print "encrypt ",  src_path , "to", dst_path
        if os.path.exists(dst_path):
            shutil.rmtree(dst_path)
        os.makedirs(dst_path)
        key = 0xaedf
        enc_path_to(src_path, dst_path, key)
        
    except Exception,e:
        print("error")
        print(e)
        exit(20)

main()