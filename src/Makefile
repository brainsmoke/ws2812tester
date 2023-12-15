
TARGETS=ws2812test-pfs154.ihx ws2812test-pms150c.ihx
CLEAN=$(TARGETS)
DEPS=map.asm pdk.asm

AS13=sdaspdk13
AS14=sdaspdk14

all: $(TARGETS)

clean:
	-rm $(CLEAN)

%-pms150c.rel: %.asm $(DEPS)
	$(AS13) -s -o -l $@ $<

%-pfs154.rel: %.asm $(DEPS)
	$(AS14) -s -o -l $@ $<

%.ihx: %.rel
	sdldpdk -muwx -i $@ -Y $< -e
	-rm $(@:.ihx=.cdb) $(@:.ihx=.lst) $(@:.ihx=.map) $(@:.ihx=.rel) $(@:.ihx=.rst) # $(@:.ihx=.sym)
