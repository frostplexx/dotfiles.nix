CC = clang
FRAMEWORKS = -framework Foundation -framework ScriptingBridge
TARGET = notification_center
SOURCE = main.m

all: $(TARGET)

$(TARGET): $(SOURCE) SystemEvents.h
	$(CC) $(FRAMEWORKS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run
