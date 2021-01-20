
TARGETS=ws2812test-pdk14.ihx ws2812test-pdk13.ihx
CLEAN=$(TARGETS)
DEPS=map.asm pdk.asm

AS13=sdaspdk13
AS14=sdaspdk14

all: $(TARGETS)

clean:
	-rm $(CLEAN)

%-pdk13.rel: %.asm $(DEPS)
	$(AS13) -s -o -l $@ $<

%-pdk14.rel: %.asm $(DEPS)
	$(AS14) -s -o -l $@ $<

%.ihx: %.rel
	sdldpdk -muwx -i $@ -Y $< -e
	-rm $(@:.ihx=.cdb) $(@:.ihx=.lst) $(@:.ihx=.map) $(@:.ihx=.rel) $(@:.ihx=.rst) # $(@:.ihx=.sym)
