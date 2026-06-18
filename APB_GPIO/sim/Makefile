#Makefile 
RTL = ../rtl/*.v

TB1 = ../tb/test.v

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64

cmp_tb1:
	vcs $(RTL) $(TB1) -cm line+tgl+fsm+branch+cond
	./simv -cm line+tgl+fsm+branch+cond urg -dir simv.vdb
	verdi -cov -covdir simv.vdb
	
clean:
	rm -rf csrc .fsdb novas_dump.log simv* simv.daidir ucli.key verdi* novas.* cm.log vdCov*
	clear


help:
	@echo ===========================================================================================================================
	@echo " USAGE   	--  make target"
	@echo " clean   	=>  clean the earlier log and intermediate files."
	@echo " cmp_tb1        	=>  To compile RTL, TB & simulate the RTL using TB in batch mode." 
	@echo " run1       	=>  To clean,compile the source codes & simulate the RTL in batch mode."              
	@echo ===========================================================================================================================

run1: clean cmp_tb1


