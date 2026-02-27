
# Makefile for neon_voyager

.PHONY: run-macos run-web run-ios run-android gen watch clean test lint help

# Default target
help:
	@echo "Available commands:"
	@echo "  make run-macos    - Run app on macOS"
	@echo "  make run-web      - Run app in Chrome"
	@echo "  make run-ios      - Run app on iOS Simulator (Default flavor: dev. Override with FLAVOR=prod make run-ios)"
	@echo "  make run-android  - Run app on Android Emulator (Default flavor: dev. Override with FLAVOR=prod make run-android)"
	@echo "  make run-device   - Run app on specific device (usage: make run-device DEVICE=<device_id>)"
	@echo "  make gen          - Run build_runner build"
	@echo "  make watch        - Run build_runner watch"
	@echo "  make clean        - Clean project and get packages"
	@echo "  make test         - Run tests"
	@echo "  make lint         - Run analyzer"

FLAVOR ?= dev

STT_FRAMEWORK := build/macos/Build/Products/Debug/neon_voyager.app/Contents/Frameworks/speech_to_text.framework
STT_PLIST     := $(STT_FRAMEWORK)/Versions/A/Resources/Info.plist
APP_BUNDLE    := build/macos/Build/Products/Debug/neon_voyager.app

# Patch and re-sign the speech_to_text framework so macOS TCC accepts the
# privacy usage descriptions (TCC validates the code signature; patching the
# Info.plist without re-signing causes TCC to silently reject the changes).
patch-stt-framework:
	@if [ -f "$(STT_PLIST)" ]; then \
		echo "→ Patching speech_to_text framework Info.plist..."; \
		/usr/libexec/PlistBuddy -c "Delete :NSMicrophoneUsageDescription" "$(STT_PLIST)" 2>/dev/null || true; \
		/usr/libexec/PlistBuddy -c "Delete :NSSpeechRecognitionUsageDescription" "$(STT_PLIST)" 2>/dev/null || true; \
		/usr/libexec/PlistBuddy -c "Add :NSMicrophoneUsageDescription string 'We need access to your microphone for voice search.'" "$(STT_PLIST)"; \
		/usr/libexec/PlistBuddy -c "Add :NSSpeechRecognitionUsageDescription string 'We need access to speech recognition for voice search.'" "$(STT_PLIST)"; \
		echo "→ Re-signing speech_to_text framework..."; \
		codesign --force --deep --sign - "$(STT_FRAMEWORK)"; \
		echo "→ Re-signing app bundle..."; \
		codesign --force --deep --sign - "$(APP_BUNDLE)"; \
		echo "✅ speech_to_text framework patched and re-signed"; \
	fi

run-macos:
	@echo "Killing any process on port 8080..."
	@lsof -ti :8080 | xargs kill -9 2>/dev/null || true
	@echo "Killing any leftover app processes..."
	@pkill -f "neon_voyager" 2>/dev/null || true
	@echo "Clearing stale Hive lock files..."
	@rm -f "$(HOME)/Library/Containers/com.neonvoyager.app/Data/Documents/"*.lock 2>/dev/null || true
	@echo "Starting API proxy..."
	@cd infra/cloud-run/api-proxy && \
		source .venv/bin/activate && \
		export $$(grep -v '^#' ../../../.env | xargs) && \
		APP_CHECK_ENABLED=false uvicorn main:app --port 8080 & \
		PROXY_PID=$$!; \
		echo "Proxy started (PID: $$PROXY_PID)"; \
		flutter run --dart-define=appFlavor=$(FLAVOR) -d macos; \
		echo "Stopping proxy (PID: $$PROXY_PID)..."; \
		kill $$PROXY_PID

# Dev-macos is obsolete since run-macos now attaches automatically, but kept for compatibility
dev-macos:
	flutter attach -d macos

run-web:
	@echo "Killing any process on port 8080..."
	@lsof -ti :8080 | xargs kill -9 2>/dev/null || true
	@echo "Killing any process on port 3000..."
	@lsof -ti :3000 | xargs kill -9 2>/dev/null || true
	@echo "Starting API proxy..."
	@cd infra/cloud-run/api-proxy && \
		source .venv/bin/activate && \
		export $$(grep -v '^#' ../../../.env | xargs) && \
		APP_CHECK_ENABLED=false uvicorn main:app --port 8080 & \
		PROXY_PID=$$!; \
		echo "Proxy started (PID: $$PROXY_PID)"; \
		flutter run -d web-server --web-port=3000 --web-hostname=localhost --dart-define=appFlavor=$(FLAVOR); \
		echo "Stopping proxy (PID: $$PROXY_PID)..."; \
		kill $$PROXY_PID

run-ios:
	flutter run --flavor $(FLAVOR) -d ios

run-android:
	flutter run --flavor $(FLAVOR) -d android

run-device:
	flutter run -d $(DEVICE)

gen:
	flutter pub run build_runner build --delete-conflicting-outputs

watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean
	flutter pub get

test:
	flutter test

lint:
	flutter analyze
