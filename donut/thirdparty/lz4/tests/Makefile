# ##########################################################################
# LZ4 programs - Makefile
# Copyright (C) Yann Collet 2011-2020
#
# GPL v2 License
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# You can contact the author at :
#  - LZ4 homepage : http://www.lz4.org
#  - LZ4 source repository : https://github.com/lz4/lz4
# ##########################################################################
# fuzzer  : Test tool, to check lz4 integrity on target platform
# frametest  : Test tool, to check lz4frame integrity on target platform
# fullbench  : Precisely measure speed for each LZ4 function variant
# datagen : generates synthetic data samples for tests & benchmarks
# ##########################################################################

LZ4DIR  := ../lib
PRGDIR  := ../programs
TESTDIR := versionsTest
PYTHON  ?= python3

DEBUGLEVEL?= 1
DEBUGFLAGS = -g -DLZ4_DEBUG=$(DEBUGLEVEL)
CFLAGS  ?= -O3 # can select custom optimization flags. Example : CFLAGS=-O2 make
CFLAGS  += -Wall -Wextra -Wundef -Wcast-qual -Wcast-align -Wshadow \
           -Wswitch-enum -Wdeclaration-after-statement -Wstrict-prototypes \
           -Wpointer-arith -Wstrict-aliasing=1
CFLAGS  += $(DEBUGFLAGS) $(MOREFLAGS)
CPPFLAGS+= -I$(LZ4DIR) -I$(PRGDIR) -DXXH_NAMESPACE=LZ4_
FLAGS    = $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)

include ../Makefile.inc

LZ4 := $(PRGDIR)/lz4$(EXT)


# Default test parameters
TEST_FILES   := COPYING
FUZZER_TIME  := -T90s
NB_LOOPS     ?= -i1

.PHONY: default
default: all

all: fullbench fuzzer frametest roundTripTest datagen checkFrame decompress-partial

all32: CFLAGS+=-m32
all32: all

lz4:
	$(MAKE) -C $(PRGDIR) $@ CFLAGS="$(CFLAGS)"

lib liblz4.pc:
	$(MAKE) -C $(LZ4DIR) $@ CFLAGS="$(CFLAGS)"

lz4c unlz4 lz4cat: lz4
	$(LN_SF) $(LZ4) $(PRGDIR)/$@

lz4c32:   # create a 32-bits version for 32/64 interop tests
	$(MAKE) -C $(PRGDIR) $@ CFLAGS="-m32 $(CFLAGS)"

%.o : $(LZ4DIR)/%.c $(LZ4DIR)/%.h
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

fullbench : DEBUGLEVEL=0
fullbench : lz4.o lz4hc.o lz4frame.o xxhash.o fullbench.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

$(LZ4DIR)/liblz4.a:
	$(MAKE) -C $(LZ4DIR) liblz4.a

fullbench-lib: fullbench.c $(LZ4DIR)/liblz4.a
	$(CC) $(FLAGS) $^ -o $@$(EXT)

fullbench-dll: fullbench.c $(LZ4DIR)/xxhash.c
	$(MAKE) -C $(LZ4DIR) liblz4
	$(CC) $(FLAGS) $^ -o $@$(EXT) -DLZ4_DLL_IMPORT=1 $(LZ4DIR)/dll/$(LIBLZ4).dll

# test LZ4_USER_MEMORY_FUNCTIONS
fullbench-wmalloc: CPPFLAGS += -DLZ4_USER_MEMORY_FUNCTIONS
fullbench-wmalloc: fullbench

fuzzer  : lz4.o lz4hc.o xxhash.o fuzzer.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

frametest: lz4frame.o lz4.o lz4hc.o xxhash.o frametest.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

roundTripTest : lz4.o lz4hc.o xxhash.o roundTripTest.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

datagen : $(PRGDIR)/datagen.c datagencli.c
	$(CC) $(FLAGS) -I$(PRGDIR) $^ -o $@$(EXT)

checkFrame : lz4frame.o lz4.o lz4hc.o xxhash.o checkFrame.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

decompress-partial: lz4.o decompress-partial.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

decompress-partial-usingDict: lz4.o decompress-partial-usingDict.c
	$(CC) $(FLAGS) $^ -o $@$(EXT)

.PHONY: clean
clean:
	@$(MAKE) -C $(LZ4DIR) $@ > $(VOID)
	@$(MAKE) -C $(PRGDIR) $@ > $(VOID)
	@$(RM) -rf core *.o *.test tmp* \
        fullbench-dll$(EXT) fullbench-lib$(EXT) \
        fullbench$(EXT) fullbench32$(EXT) \
        fuzzer$(EXT) fuzzer32$(EXT) \
        frametest$(EXT) frametest32$(EXT) \
        fasttest$(EXT) roundTripTest$(EXT) \
        datagen$(EXT) checkTag$(EXT) \
        frameTest$(EXT) decompress-partial$(EXT) \
		lz4_all.c
	@$(RM) -rf $(TESTDIR)
	@echo Cleaning completed

.PHONY: versionsTest
versionsTest:
	$(PYTHON) test-lz4-versions.py

.PHONY: listTest
listTest: lz4
	QEMU_SYS=$(QEMU_SYS) $(PYTHON) test-lz4-list.py

checkTag: checkTag.c $(LZ4DIR)/lz4.h
	$(CC) $(FLAGS) $< -o $@$(EXT)

#-----------------------------------------------------------------------------
# validated only for Linux, OSX, BSD, Hurd and Solaris targets
#-----------------------------------------------------------------------------
ifeq ($(POSIX_ENV),Yes)

MD5:=md5sum
ifneq (,$(filter $(shell $(UNAME)), Darwin ))
MD5:=md5 -r
endif

# note : we should probably settle on a single compare utility
CMP:=cmp
DIFF:=diff
ifneq (,$(filter $(shell $(UNAME)),SunOS))
DIFF:=gdiff
endif

CAT:=cat
DD:=dd
DATAGEN:=./datagen

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

.PHONY: check
check: test-lz4-essentials

.PHONY: test
test: test-lz4 test-lz4c test-frametest test-fullbench test-fuzzer test-install test-amalgamation listTest test-decompress-partial

.PHONY: test32
test32: CFLAGS+=-m32
test32: test

.PHONY: test-amalgamation
test-amalgamation: lz4_all.o

lz4_all.c: $(LZ4DIR)/lz4.c $(LZ4DIR)/lz4hc.c $(LZ4DIR)/lz4frame.c
	$(CAT) $^ > $@

.PHONY: test-install
test-install: lz4 lib liblz4.pc
	lz4_root=.. ./test_install.sh

.PHONY: test-compile-with-lz4-memory-usage
test-compile-with-lz4-memory-usage:
	$(MAKE) clean; CFLAGS=-O0 CPPFLAGS=-D'LZ4_MEMORY_USAGE=LZ4_MEMORY_USAGE_MIN' $(MAKE) all
	$(MAKE) clean; CFLAGS=-O0 CPPFLAGS=-D'LZ4_MEMORY_USAGE=LZ4_MEMORY_USAGE_MAX' $(MAKE) all

.PHONY: test-lz4-sparse
test-lz4-sparse: lz4 datagen
	@echo "\n ---- test sparse file support ----"
	$(DATAGEN) -g5M  -P100 > tmplsdg5M
	$(LZ4) -B4D tmplsdg5M -c | $(LZ4) -dv --sparse > tmplscB4
	$(DIFF) -s tmplsdg5M tmplscB4
	$(LZ4) -B5D tmplsdg5M -c | $(LZ4) -dv --sparse > tmplscB5
	$(DIFF) -s tmplsdg5M tmplscB5
	$(LZ4) -B6D tmplsdg5M -c | $(LZ4) -dv --sparse > tmplscB6
	$(DIFF) -s tmplsdg5M tmplscB6
	$(LZ4) -B7D tmplsdg5M -c | $(LZ4) -dv --sparse > tmplscB7
	$(DIFF) -s tmplsdg5M tmplscB7
	$(LZ4) tmplsdg5M -c | $(LZ4) -dv --no-sparse > tmplsnosparse
	$(DIFF) -s tmplsdg5M tmplsnosparse
	ls -ls tmpls*
	$(DATAGEN) -s1 -g1200007 -P100 | $(LZ4) | $(LZ4) -dv --sparse > tmplsodd   # Odd size file (to generate non-full last block)
	$(DATAGEN) -s1 -g1200007 -P100 | $(DIFF) -s - tmplsodd
	ls -ls tmplsodd
	@$(RM) tmpls*
	@echo "\n Compatibility with Console :"
	echo "Hello World 1 !" | $(LZ4) | $(LZ4) -d -c
	echo "Hello World 2 !" | $(LZ4) | $(LZ4) -d | $(CAT)
	echo "Hello World 3 !" | $(LZ4) --no-frame-crc | $(LZ4) -d -c
	@echo "\n Compatibility with Append :"
	$(DATAGEN) -P100 -g1M > tmplsdg1M
	$(CAT) tmplsdg1M tmplsdg1M > tmpls2M
	$(LZ4) -B5 -v tmplsdg1M tmplsc
	$(LZ4) -d -v tmplsc tmplsr
	$(LZ4) -d -v tmplsc -c >> tmplsr
	ls -ls tmp*
	$(DIFF) tmpls2M tmplsr
	@$(RM) tmpls*

test-lz4-contentSize: lz4 datagen
	@echo "\n ---- test original size support ----"
	$(DATAGEN) -g15M > tmplc1
	$(LZ4) -v tmplc1 -c | $(LZ4) -t
	$(LZ4) -v --content-size tmplc1 -c | $(LZ4) -d > tmplc2
	$(DIFF) tmplc1 tmplc2
	$(LZ4) -f tmplc1 -c > tmplc1.lz4
	$(LZ4) --content-size tmplc1 -c > tmplc2.lz4
	! $(DIFF) tmplc1.lz4 tmplc2.lz4  # must differ, due to content size
	$(LZ4) --content-size < tmplc1 > tmplc3.lz4
	$(DIFF) tmplc2.lz4 tmplc3.lz4  # both must contain content size
	$(CAT) tmplc1 | $(LZ4) > tmplc4.lz4
	$(DIFF) tmplc1.lz4 tmplc4.lz4  # both don't have content size
	$(CAT) tmplc1 | $(LZ4) --content-size > tmplc5.lz4 # can't determine content size
	$(DIFF) tmplc1.lz4 tmplc5.lz4  # both don't have content size
	@$(RM) tmplc*

test-lz4-frame-concatenation: lz4 datagen
	@echo "\n ---- test frame concatenation ----"
	@echo -n > tmp-lfc-empty
	@echo hi > tmp-lfc-nonempty
	$(CAT) tmp-lfc-nonempty tmp-lfc-empty tmp-lfc-nonempty > tmp-lfc-src
	$(LZ4) -zq tmp-lfc-empty -c > tmp-lfc-empty.lz4
	$(LZ4) -zq tmp-lfc-nonempty -c > tmp-lfc-nonempty.lz4
	$(CAT) tmp-lfc-nonempty.lz4 tmp-lfc-empty.lz4 tmp-lfc-nonempty.lz4 > tmp-lfc-concat.lz4
	$(LZ4) -d tmp-lfc-concat.lz4 -c > tmp-lfc-result
	$(CMP) tmp-lfc-src tmp-lfc-result
	@$(RM) tmp-lfc-*
	@echo frame concatenation test completed

test-lz4-multiple: lz4 datagen
	@echo "\n ---- test multiple files ----"
	@$(DATAGEN) -s1        > tmp-tlm1 2> $(VOID)
	@$(DATAGEN) -s2 -g100K > tmp-tlm2 2> $(VOID)
	@$(DATAGEN) -s3 -g200K > tmp-tlm3 2> $(VOID)
	# compress multiple files : one .lz4 per source file
	$(LZ4) -f -m tmp-tlm*
	test -f tmp-tlm1.lz4
	test -f tmp-tlm2.lz4
	test -f tmp-tlm3.lz4
	# decompress multiple files : one output file per .lz4
	mv tmp-tlm1 tmp-tlm1-orig
	mv tmp-tlm2 tmp-tlm2-orig
	mv tmp-tlm3 tmp-tlm3-orig
	$(LZ4) -d -f -m tmp-tlm*.lz4
	$(CMP) tmp-tlm1 tmp-tlm1-orig   # must be identical
	$(CMP) tmp-tlm2 tmp-tlm2-orig
	$(CMP) tmp-tlm3 tmp-tlm3-orig
	# compress multiple files into stdout
	$(CAT) tmp-tlm1.lz4 tmp-tlm2.lz4 tmp-tlm3.lz4 > tmp-tlm-concat1
	$(RM) *.lz4
	$(LZ4) -m tmp-tlm1 tmp-tlm2 tmp-tlm3 -c > tmp-tlm-concat2
	test ! -f tmp-tlm1.lz4  # must not create .lz4 artefact
	$(CMP) tmp-tlm-concat1 tmp-tlm-concat2  # must be equivalent
	# decompress multiple files into stdout
	$(RM) tmp-tlm-concat1 tmp-tlm-concat2
	$(LZ4) -f -m tmp-tlm1 tmp-tlm2 tmp-tlm3   # generate .lz4 to decompress
	$(CAT) tmp-tlm1 tmp-tlm2 tmp-tlm3 > tmp-tlm-concat1   # create concatenated reference
	$(RM) tmp-tlm1 tmp-tlm2 tmp-tlm3
	$(LZ4) -d -m tmp-tlm1.lz4 tmp-tlm2.lz4 tmp-tlm3.lz4 -c > tmp-tlm-concat2
	test ! -f tmp-tlm1  # must not create file artefact
	$(CMP) tmp-tlm-concat1 tmp-tlm-concat2  # must be equivalent
	# compress multiple files, one of which is absent (must fail)
	! $(LZ4) -f -m tmp-tlm-concat1 notHere tmp-tlm-concat2  # must fail : notHere not present
	@$(RM) tmp-tlm*

test-lz4-multiple-legacy: lz4 datagen
	@echo "\n ---- test multiple files (Legacy format) ----"
	@$(DATAGEN) -s1        > tmp-tlm1 2> $(VOID)
	@$(DATAGEN) -s2 -g100K > tmp-tlm2 2> $(VOID)
	@$(DATAGEN) -s3 -g200K > tmp-tlm3 2> $(VOID)
	# compress multiple files using legacy format: one .lz4 per source file
	$(LZ4) -f -l -m tmp-tlm*
	test -f tmp-tlm1.lz4
	test -f tmp-tlm2.lz4
	test -f tmp-tlm3.lz4
	# decompress multiple files compressed using legacy format: one output file per .lz4
	mv tmp-tlm1 tmp-tlm1-orig
	mv tmp-tlm2 tmp-tlm2-orig
	mv tmp-tlm3 tmp-tlm3-orig
	$(LZ4) -d -f -m tmp-tlm*.lz4
	$(LZ4) -l -d -f -m tmp-tlm*.lz4 # -l mustn't impact -d option
	$(CMP) tmp-tlm1 tmp-tlm1-orig   # must be identical
	$(CMP) tmp-tlm2 tmp-tlm2-orig
	$(CMP) tmp-tlm3 tmp-tlm3-orig
	# compress multiple files into stdout using legacy format
	$(CAT) tmp-tlm1.lz4 tmp-tlm2.lz4 tmp-tlm3.lz4 > tmp-tlm-concat1
	$(RM) *.lz4
	$(LZ4) -l -m tmp-tlm1 tmp-tlm2 tmp-tlm3 -c > tmp-tlm-concat2
	test ! -f tmp-tlm1.lz4  # must not create .lz4 artefact
	$(CMP) tmp-tlm-concat1 tmp-tlm-concat2  # must be equivalent
	# # # decompress multiple files into stdout using legacy format
	$(RM) tmp-tlm-concat1 tmp-tlm-concat2
	$(LZ4) -l -f -m tmp-tlm1 tmp-tlm2 tmp-tlm3   # generate .lz4 to decompress
	$(CAT) tmp-tlm1 tmp-tlm2 tmp-tlm3 > tmp-tlm-concat1   # create concatenated reference
	$(RM) tmp-tlm1 tmp-tlm2 tmp-tlm3
	$(LZ4) -d -m tmp-tlm1.lz4 tmp-tlm2.lz4 tmp-tlm3.lz4 -c > tmp-tlm-concat2
	$(LZ4) -d -l -m tmp-tlm1.lz4 tmp-tlm2.lz4 tmp-tlm3.lz4 -c > tmp-tlm-concat2 # -l mustn't impact option -d
	test ! -f tmp-tlm1  # must not create file artefact
	$(CMP) tmp-tlm-concat1 tmp-tlm-concat2  # must be equivalent
	# # # compress multiple files, one of which is absent (must fail)
	! $(LZ4) -f -l -m tmp-tlm-concat1 notHere-legacy tmp-tlm-concat2  # must fail : notHere-legacy not present
	@$(RM) tmp-tlm*

test-lz4-basic: lz4 datagen unlz4 lz4cat
	@echo "\n ---- test lz4 basic compression/decompression ----"
	$(DATAGEN) -g0       | $(LZ4) -v     | $(LZ4) -t
	$(DATAGEN) -g16KB    | $(LZ4) -9     | $(LZ4) -t
	$(DATAGEN) -g20KB > tmp-tlb-dg20k
	$(LZ4) < tmp-tlb-dg20k | $(LZ4) -d > tmp-tlb-dec
	$(DIFF) -q tmp-tlb-dg20k tmp-tlb-dec
	$(LZ4) --no-frame-crc < tmp-tlb-dg20k | $(LZ4) -d > tmp-tlb-dec
	$(DIFF) -q tmp-tlb-dg20k tmp-tlb-dec
	$(DATAGEN)           | $(LZ4) -BI    | $(LZ4) -t
	$(DATAGEN) -g6M -P99 | $(LZ4) -9BD   | $(LZ4) -t
	$(DATAGEN) -g17M     | $(LZ4) -9v    | $(LZ4) -qt
	$(DATAGEN) -g33M     | $(LZ4) --no-frame-crc | $(LZ4) -t
	$(DATAGEN) -g256MB   | $(LZ4) -vqB4D | $(LZ4) -t
	@echo "hello world" > tmp-tlb-hw
	$(LZ4) --rm -f tmp-tlb-hw tmp-tlb-hw.lz4
	test ! -f tmp-tlb-hw                      # must fail (--rm)
	test   -f tmp-tlb-hw.lz4
	$(PRGDIR)/lz4cat tmp-tlb-hw.lz4           # must display hello world
	test   -f tmp-tlb-hw.lz4
	$(PRGDIR)/unlz4 --rm tmp-tlb-hw.lz4 tmp-tlb-hw
	test   -f tmp-tlb-hw
	test ! -f tmp-tlb-hw.lz4                  # must fail (--rm)
	test ! -f tmp-tlb-hw.lz4.lz4              # must fail (unlz4)
	$(PRGDIR)/lz4cat tmp-tlb-hw               # pass-through mode
	test   -f tmp-tlb-hw
	test ! -f tmp-tlb-hw.lz4                  # must fail (lz4cat)
	$(LZ4) tmp-tlb-hw tmp-tlb-hw.lz4          # creates tmp-tlb-hw.lz4
	$(PRGDIR)/lz4cat < tmp-tlb-hw.lz4 > tmp-tlb3  # checks lz4cat works with stdin (#285)
	$(DIFF) -q tmp-tlb-hw tmp-tlb3
	$(PRGDIR)/lz4cat < tmp-tlb-hw > tmp-tlb2      # checks lz4cat works in pass-through mode
	$(DIFF) -q tmp-tlb-hw tmp-tlb2
	cp tmp-tlb-hw ./-d
	$(LZ4) --rm -- -d -d.lz4               # compresses ./d into ./-d.lz4
	test   -f ./-d.lz4
	test ! -f ./-d
	mv ./-d.lz4 ./-z
	$(LZ4) -d --rm -- -z tmp-tlb4          # uncompresses ./-z into tmp-tlb4
	test ! -f ./-z
	$(DIFF) -q tmp-tlb-hw tmp-tlb4
	$(LZ4) -f tmp-tlb-hw
	$(LZ4) --list tmp-tlb-hw.lz4           # test --list on valid single-frame file
	$(LZ4) --list < tmp-tlb-hw.lz4         # test --list from stdin (file only)
	$(CAT) tmp-tlb-hw >> tmp-tlb-hw.lz4
	! $(LZ4) -f tmp-tlb-hw.lz4             # uncompress valid frame followed by invalid data (must fail now)
	$(LZ4) -BX tmp-tlb-hw -c -q | $(LZ4) -tv  # test block checksum
	# $(DATAGEN) -g20KB generates the same file every single time
	# cannot save output of $(DATAGEN) -g20KB as input file to lz4 because the following shell commands are run before $(DATAGEN) -g20KB
	test "$(shell $(DATAGEN) -g20KB | $(LZ4) -c --fast | wc -c)" -lt "$(shell $(DATAGEN) -g20KB | $(LZ4) -c --fast=9 | wc -c)" # -1 vs -9
	test "$(shell $(DATAGEN) -g20KB | $(LZ4) -c -1 | wc -c)" -lt "$(shell $(DATAGEN) -g20KB| $(LZ4) -c --fast=1 | wc -c)" # 1 vs -1
	test "$(shell $(DATAGEN) -g20KB | $(LZ4) -c --fast=1 | wc -c)" -eq "$(shell $(DATAGEN) -g20KB| $(LZ4) -c --fast| wc -c)" # checks default fast compression is -1
	! $(LZ4) -c --fast=0 tmp-tlb-dg20K # lz4 should fail when fast=0
	! $(LZ4) -c --fast=-1 tmp-tlb-dg20K # lz4 should fail when fast=-1
	# High --fast values can result in out-of-bound dereferences #876
	$(DATAGEN) -g1M | $(LZ4) -c --fast=999999999 > /dev/null
	# Test for #596
	@echo "TEST" > tmp-tlb-test
	$(LZ4) -m tmp-tlb-test
	$(LZ4) tmp-tlb-test.lz4 tmp-tlb-test2
	$(DIFF) -q tmp-tlb-test tmp-tlb-test2
	@$(RM) tmp-tlb*



test-lz4-dict: lz4 datagen
	@echo "\n ---- test lz4 compression/decompression with dictionary ----"
	$(DATAGEN) -g16KB > tmp-dict
	$(DATAGEN) -g32KB > tmp-dict-sample-32k
	< tmp-dict-sample-32k $(LZ4) -D tmp-dict | $(LZ4) -dD tmp-dict | diff - tmp-dict-sample-32k
	$(DATAGEN) -g128MB > tmp-dict-sample-128m
	< tmp-dict-sample-128m $(LZ4) -D tmp-dict | $(LZ4) -dD tmp-dict | diff - tmp-dict-sample-128m
	touch tmp-dict-sample-0
	< tmp-dict-sample-0 $(LZ4) -D tmp-dict | $(LZ4) -dD tmp-dict | diff - tmp-dict-sample-0

	< tmp-dict-sample-32k $(LZ4) -D tmp-dict-sample-0 | $(LZ4) -dD tmp-dict-sample-0 | diff - tmp-dict-sample-32k
	< tmp-dict-sample-0 $(LZ4) -D tmp-dict-sample-0 | $(LZ4) -dD tmp-dict-sample-0 | diff - tmp-dict-sample-0

	@echo "\n ---- test lz4 dictionary loading ----"
	$(DATAGEN) -g128KB > tmp-dict-data-128KB
	set -e; \
	for l in 0 1 4 128 32767 32768 32769 65535 65536 65537 98303 98304 98305 131071 131072 131073; do \
		$(DATAGEN) -g$$l > tmp-dict-$$l; \
		$(DD) if=tmp-dict-$$l of=tmp-dict-$$l-tail bs=1 count=65536 skip=$$((l > 65536 ? l - 65536 : 0)); \
		< tmp-dict-$$l      $(LZ4) -D stdin tmp-dict-data-128KB -c | $(LZ4) -dD tmp-dict-$$l-tail | $(DIFF) - tmp-dict-data-128KB; \
		< tmp-dict-$$l-tail $(LZ4) -D stdin tmp-dict-data-128KB -c | $(LZ4) -dD tmp-dict-$$l      | $(DIFF) - tmp-dict-data-128KB; \
	done

	@$(RM) tmp-dict*

test-lz4-hugefile: lz4 datagen
	@echo "\n ---- test huge files compression/decompression ----"
	./datagen -g6GB    | $(LZ4) -vB5D  | $(LZ4) -qt
	./datagen -g4500MB | $(LZ4) -v3BD | $(LZ4) -qt
	# test large file size [2-4] GB
	@$(DATAGEN) -g3G -P100 | $(LZ4) -vv | $(LZ4) --decompress --force --sparse - tmphf1
	@ls -ls tmphf1
	@$(DATAGEN) -g3G -P100 | $(LZ4) --quiet --content-size | $(LZ4) --verbose --decompress --force --sparse - tmphf2
	@ls -ls tmphf2
	$(DIFF) -s tmphf1 tmphf2
	@$(RM) tmphf*

test-lz4-testmode: lz4 datagen
	@echo "\n ---- bench mode ----"
	$(LZ4) -bi0
	@echo "\n ---- test mode ----"
	! $(DATAGEN) | $(LZ4) -t
	! $(DATAGEN) | $(LZ4) -tf
	@echo "\n ---- pass-through mode ----"
	@echo "Why hello there " > tmp-tlt2.lz4
	! $(LZ4) -f tmp-tlt2.lz4 > $(VOID)
	! $(DATAGEN) | $(LZ4) -dc  > $(VOID)
	! $(DATAGEN) | $(LZ4) -df > $(VOID)
	$(DATAGEN) | $(LZ4) -dcf > $(VOID)
	@echo "Hello World !" > tmp-tlt1
	$(LZ4) -dcf tmp-tlt1
	@echo "from underground..." > tmp-tlt2
	$(LZ4) -dcfm tmp-tlt1 tmp-tlt2
	@echo "\n ---- non-existing source ----"
	! $(LZ4)     file-does-not-exist
	! $(LZ4) -f  file-does-not-exist
	! $(LZ4) -t  file-does-not-exist
	! $(LZ4) -fm file1-dne file2-dne
	@$(RM) tmp-tlt tmp-tlt1 tmp-tlt2 tmp-tlt2.lz4

test-lz4-opt-parser: lz4 datagen
	@echo "\n ---- test opt-parser ----"
	$(DATAGEN) -g16KB      | $(LZ4) -12      | $(LZ4) -t
	$(DATAGEN) -P10        | $(LZ4) -12B4    | $(LZ4) -t
	$(DATAGEN) -g256K      | $(LZ4) -12B4D   | $(LZ4) -t
	$(DATAGEN) -g512K -P25 | $(LZ4) -12BD    | $(LZ4) -t
	$(DATAGEN) -g1M        | $(LZ4) -12B5    | $(LZ4) -t
	$(DATAGEN) -g1M -s2    | $(LZ4) -12B4D   | $(LZ4) -t
	$(DATAGEN) -g2M -P99   | $(LZ4) -11B4D   | $(LZ4) -t
	$(DATAGEN) -g4M        | $(LZ4) -11vq    | $(LZ4) -qt
	$(DATAGEN) -g8M        | $(LZ4) -11B4    | $(LZ4) -t
	$(DATAGEN) -g16M -P90  | $(LZ4) -11B5    | $(LZ4) -t
	$(DATAGEN) -g32M -P10  | $(LZ4) -11B5D   | $(LZ4) -t

test-lz4-essentials : lz4 datagen test-lz4-basic test-lz4-multiple test-lz4-multiple-legacy \
                      test-lz4-frame-concatenation test-lz4-testmode \
                      test-lz4-contentSize test-lz4-dict
	@$(RM) tmp*

test-lz4: lz4 datagen test-lz4-essentials test-lz4-opt-parser \
          test-lz4-sparse test-lz4-hugefile test-lz4-dict
	@$(RM) tmp*

test-lz4c: lz4c datagen
	@echo "\n ---- test lz4c variant ----"
	$(DATAGEN) -g256MB | $(LZ4)c -l -v    | $(LZ4)c   -t

test-lz4c32: CFLAGS+=-m32
test-lz4c32: test-lz4

test-interop-32-64: lz4 lz4c32 datagen
	@echo "\n ---- test interoperability 32-bits -vs- 64 bits ----"
	$(DATAGEN) -g16KB  | $(LZ4)c32 -9     | $(LZ4)    -t
	$(DATAGEN) -P10    | $(LZ4)    -9B4   | $(LZ4)c32 -t
	$(DATAGEN)         | $(LZ4)c32        | $(LZ4)    -t
	$(DATAGEN) -g1M    | $(LZ4)    -3B5   | $(LZ4)c32 -t
	$(DATAGEN) -g256MB | $(LZ4)c32 -vqB4D | $(LZ4)    -qt
	$(DATAGEN) -g1G -P90 | $(LZ4)         | $(LZ4)c32 -t
	$(DATAGEN) -g6GB   | $(LZ4)c32 -vq9BD | $(LZ4)    -qt

test-lz4c32-basic: lz4c32 datagen
	@echo "\n ---- test lz4c32 32-bits version ----"
	$(DATAGEN) -g16KB  | $(LZ4)c32 -9     | $(LZ4)c32 -t
	$(DATAGEN)         | $(LZ4)c32        | $(LZ4)c32 -t
	$(DATAGEN) -g256MB | $(LZ4)c32 -vqB4D | $(LZ4)c32 -qt
	$(DATAGEN) -g6GB   | $(LZ4)c32 -vqB5D | $(LZ4)c32 -qt

test-platform:
	@echo "\n ---- test lz4 $(QEMU_SYS) platform ----"
	$(QEMU_SYS) $(DATAGEN) -g16KB  | $(QEMU_SYS) $(LZ4) -9     | $(QEMU_SYS) $(LZ4) -t
	$(QEMU_SYS) $(DATAGEN)         | $(QEMU_SYS) $(LZ4)        | $(QEMU_SYS) $(LZ4) -t
	$(QEMU_SYS) $(DATAGEN) -g256MB | $(QEMU_SYS) $(LZ4) -vqB4D | $(QEMU_SYS) $(LZ4) -qt
ifneq ($(QEMU_SYS),qemu-arm-static)
	$(QEMU_SYS) $(DATAGEN) -g3GB   | $(QEMU_SYS) $(LZ4) -vqB5D | $(QEMU_SYS) $(LZ4) -qt
endif

test-fullbench: fullbench
	./fullbench --no-prompt $(NB_LOOPS) $(TEST_FILES)

test-fullbench32: CFLAGS += -m32
test-fullbench32: test-fullbench

test-fuzzer: fuzzer
	./fuzzer $(FUZZER_TIME)

test-fuzzer32: CFLAGS += -m32
test-fuzzer32: test-fuzzer

test-frametest: frametest
	./frametest -v $(FUZZER_TIME)

test-frametest32: CFLAGS += -m32
test-frametest32: test-frametest

test-mem: lz4 datagen fuzzer frametest fullbench
	@echo "\n ---- valgrind tests : memory analyzer ----"
	valgrind --leak-check=yes --error-exitcode=1 $(DATAGEN) -g50M > $(VOID)
	$(DATAGEN) -g16KB > ftmdg16K
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) -9 -BD -f ftmdg16K $(VOID)
	$(DATAGEN) -g16KB -s2 > ftmdg16K2
	$(DATAGEN) -g16KB -s3 > ftmdg16K3
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) --force --multiple ftmdg16K ftmdg16K2 ftmdg16K3
	$(DATAGEN) -g7MB > ftmdg7M
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) -9 -B5D -f ftmdg7M ftmdg16K2
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) -t ftmdg16K2
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) -bi1 ftmdg7M
	valgrind --leak-check=yes --error-exitcode=1 ./fullbench -i1 ftmdg7M ftmdg16K2
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) -B4D -f -vq ftmdg7M $(VOID)
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) --list -m ftm*.lz4
	valgrind --leak-check=yes --error-exitcode=1 $(LZ4) --list -m -v ftm*.lz4
	$(RM) ftm*
	valgrind --leak-check=yes --error-exitcode=1 ./fuzzer -i64 -t1
	valgrind --leak-check=yes --error-exitcode=1 ./frametest -i256

test-mem32: lz4c32 datagen
# unfortunately, valgrind doesn't seem to work with non-native binary...

test-decompress-partial : decompress-partial decompress-partial-usingDict
	@echo "\n ---- test decompress-partial ----"
	./decompress-partial$(EXT)
	@echo "\n ---- test decompress-partial-usingDict ----"
	./decompress-partial-usingDict$(EXT)

endif
