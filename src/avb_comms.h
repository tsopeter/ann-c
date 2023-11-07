/*
 * avb_comms.h
 *
 *  Created on: Oct 18, 2023
 *      Author: p221t801
 */

#ifndef SRC_AVB_COMMS_H_
#define SRC_AVB_COMMS_H_

#define AVB_BASE_ADDR 0xA0040000
#define AVB_DAC_MEM_0 0x14
#define AVB_DAC_MEM_1 0x18
#define AVB_BRAM_0    0x00
#define AVB_ILA_0     0x04
#define AVB_TRIG_0    0x08
#define AVB_DDS_0     0x0C

#define POSIX 1

#include <stdio.h>
#include <stdlib.h>
#if POSIX
    #include <unistd.h>

    uint16_t dac_mem_0[4096]={0};
    uint16_t dac_mem_1[4096]={0};
    uint16_t bram[4096]={0};
    uint32_t ila_enable={0};
    uint32_t dds_enable={0};
    uint32_t trig_enable={0};
    uint32_t bram_addr={0};

    void avb_comms_vm_write32(uint32_t offset, uint32_t val) {
        uint16_t addr = (val >> 16);
        uint16_t val2 = val;
        switch(offset) {
            case AVB_DAC_MEM_0:
                dac_mem_0[addr]=val2; break;
            case AVB_DAC_MEM_1:
                dac_mem_1[addr]=val2; break;
            case AVB_BRAM_0:
                bram_addr=val; break;
            case AVB_ILA_0:
                ila_enable=val; break;
            case AVB_TRIG_0:
                trig_enable=val; break;
            case AVB_DDS_0:
                dds_enable=val; break;
        }
    }

    uint32_t avb_comms_vm_read32(uint32_t offset) {
        switch(offset) {
            case AVB_BRAM_0:
                return bram[bram_addr];
        }
        return -1;
    }
#endif

typedef struct _avb_comms {
	uint32_t base_addr;
} avb_comms;

int avb_comms_write32(avb_comms *comms, uint32_t offset, uint32_t val) {
	uint32_t addr = comms->base_addr+offset;
	if (addr > 0xA004FFFF)
		return -1;

#ifndef POSIX
	volatile uint32_t *LocalAddr = (volatile uint32_t *)addr;
	*LocalAddr = val;
#else
    avb_comms_vm_write32(offset, val);
#endif
	return 0;
}

uint32_t avb_comms_read32(avb_comms *comms, uint32_t offset, int *succ) {
	uint32_t addr = comms->base_addr+offset;
	if (addr > 0xA004FFFF) {
		*succ = -1;
		return 0x0;
	}

	uint32_t ret;
#ifndef POSIX
	volatile uint32_t *LocalAddr = (volatile uint32_t *)addr;
	ret = *(uint32_t*)LocalAddr;
#else
    ret = avb_comms_vm_read32(offset);
#endif
	*succ=0;
	return ret;
}

void avb_write_to_dac_ram(avb_comms *comms, int index, uint32_t val) {
	/**
	 * 	We have the physical memory organized as two banks
	 *
	 * DAC MEM 0
	 * +-----------+
	 * |0x0000     |
	 * |0x0001     |
	 * |...        |
	 * +-----------+
	 *
	 * DAC MEM 1
	 * +-----------+
	 * |0x0000     |
	 * |0x0001     |
	 * |...        |
	 * +-----------+
	 *
	 * And we want to interleave it to a virtual single bank.
	 */
	int lf = index % 2;

	// if it is odd, use DAC MEM 1
	if (lf) {

	}
	else {	// else, use DAC MEM 0

	}

}

void avb_identify (avb_comms *comms) {
    #if POSIX
        printf("bram_addr={%x}\n",bram_addr);
        printf("ila_enable={%d}\n",ila_enable>0);
        printf("trig_enable={%d}\n",trig_enable>0);
        printf("dds_enable={%d}\n",dds_enable>0);
    #endif
}

void avb_print_buffer(avb_comms *comms, FILE *fd0, FILE *fd1) {
    #if POSIX
    if (fd0 == NULL)
        fd0 = stdout;
    if (fd1 == NULL)
        fd1 = stdout;

    for (size_t i = 0; i < 4096; ++i) {
        fprintf(fd0, "%d\n",0x0000FFFF & dac_mem_0[i]);
    }

    for (size_t i = 0; i < 4096; ++i) {
        fprintf(fd1, "%d\n",0x0000FFFF & dac_mem_1[i]);
    }
    #endif
}

#endif /* SRC_AVB_COMMS_H_ */