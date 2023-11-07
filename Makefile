PROG_NAME  = a.out
CC         = clang
CFLAGS     = -std=c11 -Wall -g -Werror -O1
LFLAGS     = -std=c11 -Wall -g -Werror -O1
C_ASAN     = -fsanitize=address -fno-omit-frame-pointer
L_ASAN     = -fsanitize=address
CC2        = clang++

SOURCE_DIR = src
OBJECT_DIR = obj

source    := $(wildcard $(SOURCE_DIR)/*.c)
object    := $(wildcard $(OBJECT_DIR)/*.o)

default: build

build: $(source) $(object)
	make compile
	make link

compile: $(source)
	$(CC) $(CFLAGS) $(C_ASAN) -c $(source)
	mv *.o $(OBJECT_DIR)

link: $(object)
	$(CC) $(LFLAGS) $(L_ASAN) $(object) -o $(PROG_NAME)

clean: $(object) $(PROG_NAME)
	rm $(object) $(PROG_NAME)

imbuild:
	$(CC2) -std=c++20 make_images.cpp -o zzx

runim:
	make imbuild
	./zzx
	rm ./zzx

