SPACE := $(eval) $(eval)

# https://stackoverflow.com/questions/52674/simplest-way-to-reverse-the-order-of-strings-in-a-make-variable
REVERSE = $(shell printf "%s\n" $(strip $1) | tail -r)

SRC := src
OUT := out
EXE := bacpak.out

CXX := g++
CC := gcc
FC := gfortran
ASMC := as

LD_FLAGS := 
G_FLAGS := -Wall
CXX_FLAGS :=
C_FLAGS :=
F_FLAGS :=
ASM_FLAGS :=

GET_SRCS = $(wildcard $(SRC)/*.$1) $(wildcard $(SRC)/*/*.$1)
GET_OBJS = $(foreach file,$(patsubst $(SRC)/%, %, $1),$(patsubst %,$(OUT)/%.o,$(subst $(SPACE),.,$(call REVERSE,$(subst /, ,$(word 1,$(subst ., ,$(file))))) $(word 2,$(subst ., ,$(file))))))

MAKE_OBJ = $($1) -c $($2) $($3) -o $($4)

CXX_SRCS := $(call GET_SRCS,cpp)
C_SRCS := $(call GET_SRCS,c)
F_SRCS := $(call GET_SRCS,f)
ASM_SRCS := $(call GET_SRCS,asm)

CXX_OBJS := $(call GET_OBJS,$(CXX_SRCS))
C_OBJS := $(call GET_OBJS,$(C_SRCS))
F_OBJS := $(call GET_OBJS,$(F_SRCS))
ASM_OBJS := $(call GET_OBJS,$(ASM_SRCS))

MODULES := $(patsubst $(SRC)/%/.,%,$(wildcard $(SRC)/*/.))

define COMPILE
$(1) -c -o $$@ $$< $(2)
endef

define FILE_RECIPE 
MODNAME = $(1)
FILEEXT = $(2)
$(OUT)/%.$$(MODNAME).$$(FILEEXT).o: $(SRC)/$$(MODNAME)/%.$$(FILEEXT) | out
	$(call COMPILE,$(4),$(3))
endef

build: $(EXE)

out:
	mkdir out


$(OUT)/%.f.o: $(SRC)/%.f | out
	$(FC) -c -o $@ $< $(F_FLAGS)
$(foreach mod,$(MODULES),$(eval $(call FILE_RECIPE,$(mod),f,$(F_FLAGS),$(FC))))

$(OUT)/%.cpp.o: $(SRC)/%.cpp | out
	$(CXX) -c -o $@ $< $(CXX_FLAGS)
$(foreach mod,$(MODULES),$(eval $(call FILE_RECIPE,$(mod),cpp,$(CXX_FLAGS),$(CXX))))

.PHONY: build

$(EXE): $(CXX_OBJS) $(C_OBJS) $(F_OBJS) $(ASM_OBJS)
	$(CXX) $(CXX_OBJS) $(C_OBJS) $(F_OBJS) $(ASM_OBJS) $(LD_FLAGS) $(G_FLAGS)
