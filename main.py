from matplotlib import pyplot as plt

dac_mem_0=[0]*4096
dac_mem_1=[0]*4096

for i in range(0, 4096):
    j=(2*i)*256-65535
    dac_mem_0[i]=0x0000FFFF & j

for i in range(0, 4096):
    j=(2*i+1)*256-65535
    dac_mem_1[i]=0x0000FFFF & j

# interleave
dac_mem_full=[0]*8192

c1=0
c2=0
for i in range(0, 8192):
    if i % 2 == 0:
        dac_mem_full[i]=dac_mem_0[c1]
        c1 += 1
    else:
        dac_mem_full[i]=dac_mem_1[c2]
        c2 += 1

# just append lol
dac_mem_app=[0]*4096
for i in range(0, 4096):
    dac_mem_app[i]=(dac_mem_1[i]<<16)|dac_mem_0[i]

plt.plot(dac_mem_app)
plt.show()
