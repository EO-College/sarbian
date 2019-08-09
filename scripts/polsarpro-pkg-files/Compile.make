SOURCES = $(wildcard *.c)
OBJECTS := $(SOURCES:.c=.o)
EXECUTABLE = $(SOURCES:.c=.exe)

# Debug build flags
ifeq ($(dbg),1)
      CCFLAGS += -g -G
      TARGET := debug
else
      TARGET := $(SUBDIR)
endif

define mk-objects =
$(CC) -c $< $(CCFLAGS) $(LDFLAGS) -o $@
endef

define mk-executables =
mkdir -p "$(BIN)/$(TARGET)"
$(CXX) $(CCFLAGS) $< $(LIB_O) $(LDFLAGS) -o $(BIN)/$(TARGET)/$@
endef

all: $(EXECUTABLE)

.SECONDARY: $(OBJECTS)

%.exe : %.o
	$(mk-executables)

%.o : %.c
	$(mk-objects)
