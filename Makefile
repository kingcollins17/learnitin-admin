.PHONY: dev build clean gen watch deps upgrade serve

# Start development server with hot reload
dev:
	jaspr serve

# Build for production
build:
	jaspr build

# Run code generation (freezed, json_serializable)
gen:
	dart run build_runner build --delete-conflicting-outputs

# Watch for changes and auto-generate code
watch:
	dart run build_runner watch --delete-conflicting-outputs

# Install dependencies
deps:
	dart pub get

# Upgrade dependencies
upgrade:
	dart pub upgrade

# Clean build artifacts
clean:
	jaspr clean
	dart run build_runner clean

# Analyze code
analyze:
	dart analyze

# Format code
format:
	dart format .
