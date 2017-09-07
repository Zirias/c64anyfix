C64SYS?=c64
C64AS?=ca65
C64LD?=ld65

C64ASFLAGS?=-t $(C64SYS) -g
C64LDFLAGS?=-Ln anyfix.lbl -m anyfix.map -Csrc/anyfix.cfg

anyfix_OBJS:=$(addprefix obj/,main.o numconv.o int16.o stack.o)
anyfix_BIN:=anyfix.prg

all: $(anyfix_BIN)

$(anyfix_BIN): $(anyfix_OBJS)
	$(C64LD) -o$@ $(C64LDFLAGS) $^

obj:
	mkdir obj

obj/%.o: src/%.s src/anyfix.cfg Makefile | obj
	$(C64AS) $(C64ASFLAGS) -o$@ $<

clean:
	rm -fr obj *.lbl *.map

distclean: clean
	rm -f $(anyfix_BIN)

.PHONY: all clean distclean

