CC := gcc
OPT := -O2
CFLAGS := -Wall -Wextra -pedantic $(OPT) -g
TARGET_EXEC := main

BUILD_DIR := ./build
SRC_DIR := ./src
INCLUDE_DIRS := ./include

# Get all the source files required for compilation.
SRCS := $(shell find $(SRC_DIR) -name '*.c' -or -name '*.cpp')

# Prepend BUILD_DIR% and append .o to every source file from SRCS
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
#OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

DEPS := $(OBJS:.o=.d)

# Add prefix -I to all the files in INCLUDE_DIRS.
INC_FLAGS := $(addprefix -I,$(INCLUDE_DIRS))

# Detect changes in include files.
CPPFLAGS := -MMD -MP $(INC_FLAGS)

# Final Build
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# Source files to object files.
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

# Suppress any initial .d makefiles missing errors.
-include $(DEPS)
