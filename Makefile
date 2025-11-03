.PHONY := builds finalize.romfs x_finalize_helper.firm clean 

all: builds/x_finalize_helper.firm

builds:
	@[ -d builds ] || mkdir -p builds

builds/finalize.romfs: builds
	@$(MAKE) -C Anemone3DS
	@cp Anemone3DS/out/Anemone3DS.cia romfs/finalize/Anemone3DS.cia
	@$(MAKE) -C Checkpoint 3ds
	@cp Checkpoint/3ds/out/Checkpoint.cia romfs/finalize/Checkpoint.cia
	@$(MAKE) -C FBI-NH
	@cp FBI-NH/FBI-NH.cia romfs/finalize/FBI-NH.cia
	@3dstool -c -t romfs --romfs-dir romfs --file $@

builds/x_finalize_helper.firm: builds/finalize.romfs
	@cp finalize_helper.gm9 GodMode9/data/autorun.gm9
	@sed -i s/FINALIZE_SHA256SUM/$(shell sha256sum $< | awk '{print $$1}')/g GodMode9/data/autorun.gm9
	@$(MAKE) -C GodMode9 SCRIPT_RUNNER=1
	@cp GodMode9/output/GodMode9.firm $@
	@printf '\001' | dd conv=notrunc bs=1 seek=16 of=$@
clean:
	@rm -rf builds
	@rm -rf romfs/finalize/Anemone3DS.cia
	@rm -rf romfs/finalize/Checkpoint.cia
	@rm -rf romfs/finalize/FBI-NH.cia
	@$(MAKE) -C GodMode9 clean
	@$(MAKE) -C Anemone3DS clean
	@$(MAKE) -C Checkpoint clean
	@$(MAKE) -C FBI-NH clean
	@rm GodMode9/data/autorun.gm9
