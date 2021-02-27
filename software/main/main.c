//============================================================
// Codigo em C do programa para execucao no HPS para geracao
// e armazenamento de 2^20 bits aleatorios
// Matheus Mitsuo de A. Kotaki, São Carlos-SP
// EESC - USP - 2021
//============================================================

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <error.h>
#include <stdint.h>
#include <sys/mman.h>
#include "hps_0.h"

#define HPS_TO_FPGA_LW_BASE 0xFF200000
#define HPS_TO_FPGA_LW_SPAN 0x0020000



int main() {
	FILE *fp;
	void * lw_bridge_map = 0;
	int devmem_fd = 0;
    int result = 0;

	//Entradas
	uint32_t *clk_read = 0; 
	uint32_t *done_generation = 0; 
	uint32_t *xt_out = 0; 
	uint32_t *fsm_rst = 0; 
	

	// Saidas
	uint32_t *start = 0; 
	uint32_t *x0 = 0; 
	uint32_t *done = 0; 
	uint32_t *read_addr = 0; 
	


   
    devmem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if(devmem_fd < 0) {
        perror("devmem open");
        exit(EXIT_FAILURE);
    }


    lw_bridge_map = (uint32_t*)mmap(NULL, HPS_TO_FPGA_LW_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, devmem_fd, HPS_TO_FPGA_LW_BASE); 
    if(lw_bridge_map == MAP_FAILED) {
        perror("devmem mmap");
        close(devmem_fd);
        exit(EXIT_FAILURE);
    }
	 clk_read = (uint32_t*)(lw_bridge_map + READ_CLK_BASE);
	 done_generation = (uint32_t*)(lw_bridge_map + GEN_DONE_BASE); 
	 fsm_rst = (uint32_t*)(lw_bridge_map + FSM_RESET_BASE);
	 start = (uint32_t*)(lw_bridge_map + PRNG_START_BASE);
	 x0 = (uint32_t*)(lw_bridge_map + SEED_BASE);
	 xt_out = (uint32_t*)(lw_bridge_map + PRNG_OUT_BASE);
	 done = (uint32_t*)(lw_bridge_map + REC_DONE_BASE);
	 read_addr = (uint32_t*)(lw_bridge_map + R_ADDR_BASE);
	
	//*fsm_rst = 1; 
	*(done_generation+0x3) = 0x1;		//limpa o registrador do detector de borda

	*fsm_rst = 0; 
	*start = 0x0;
	*done = 0x0;
	*clk_read = 0x0;
	*read_addr = 0b000000000000000;
	*x0 = 0x3CD11396;
	
	*start = 0x1; //inicia a geracao 
	while (!(*(done_generation+0x3)>0x0)){} //espera a borda de subida do sinal que avisa a chegada do estado done
	*(done_generation+0x3) = 0x1;		//limpa o registrador do detector de borda
	
	fp = freopen("file.txt", "w+", stdout);		//abre o arquivo para armazenar os valores
	*clk_read = 0x1;

	
	while (!(*read_addr==0b111111111111111)){	//32768 vezes
		*clk_read = 0x0;
		*read_addr = *read_addr + 0b1;	//proximo endereco da RAM
		*clk_read = 0x1;
		printf("%x\r\n",*xt_out);	// armazena no cartao SD
		if (*read_addr==0b111111111111111){
			*clk_read = 0x0;
			*clk_read = 0x1;
			printf("%x\r\n",*xt_out);	// armazena no cartao SD
		}
	}
	fclose(fp);
	
	*done = 0x1;	//indica o fim da gravacao no cartao SD
	*start = 0x0;	// volta ao estado espera
	


	// clean up our memory mapping and exit
    result = munmap(lw_bridge_map, HPS_TO_FPGA_LW_SPAN); 
    if(result < 0) {
        perror("devmem munmap");
        close(devmem_fd);
        exit(EXIT_FAILURE);
    }

    close(devmem_fd);
    exit(EXIT_SUCCESS);



	return( 0 );
}
