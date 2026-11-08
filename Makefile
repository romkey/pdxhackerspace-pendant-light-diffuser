OPENSCAD ?= openscad

PARTS := e27_plug diffuser_segment diffuser_disc diffuser_hex_segment diffuser_hex
STLS  := $(PARTS:%=stl/%.stl)
DXFS  := dxf/diffuser_hex_laser.dxf

.PHONY: all clean check

all: $(STLS) $(DXFS)

stl/%.stl: src/%.scad src/params.scad src/diffuser_lib.scad
	@mkdir -p stl
	$(OPENSCAD) --hardwarnings -o $@ $<

# Laser parts: render the cut and engrave layers separately, then merge them
# into one DXF with CUT (red) and ENGRAVE (blue) layers.
dxf/%.dxf: src/%.scad src/params.scad scripts/merge_dxf.awk
	@mkdir -p dxf
	$(OPENSCAD) --hardwarnings -D 'layer="cut"' -o $@.cut.dxf $<
	$(OPENSCAD) --hardwarnings -D 'layer="engrave"' -o $@.engrave.dxf $<
	awk -f scripts/merge_dxf.awk -v layers="CUT:1,ENGRAVE:5" $@.cut.dxf $@.engrave.dxf > $@
	rm -f $@.cut.dxf $@.engrave.dxf

# Render everything (including the assembly) without keeping output.
check: all
	$(OPENSCAD) --hardwarnings -o /tmp/assembly.stl src/assembly.scad
	$(OPENSCAD) --hardwarnings -D 'shape="hex"' -o /tmp/assembly_hex.stl src/assembly.scad

clean:
	rm -f $(STLS) $(DXFS)
