#!/bin/zsh

echo "Installed as /usr/local/bin/$TARGET_NAME"
echo "You can now run: $TARGET_NAME add numbers 2 3"

# Build the project
swift build || { echo "Build failed"; exit 1; }

# Set the executable name and target
EXECUTABLE=".build/debug/CLIManagerExecutable"
TARGET_NAME="aos-cli"

# Check if the executable exists
if [[ ! -f "$EXECUTABLE" ]]; then
  echo "Executable not found: $EXECUTABLE"
  exit 1
fi

echo "Copying executable to /usr/local/bin (may require sudo)..."
sudo cp "$EXECUTABLE" "/usr/local/bin/$TARGET_NAME"
sudo chmod +x "/usr/local/bin/$TARGET_NAME"

echo "Installed as /usr/local/bin/$TARGET_NAME"
echo "You can now run: $TARGET_NAME add numbers 2 3"
