FLUTTER ?= flutter
DART ?= dart

.PHONY: get gen analyze test format run-dev run-staging run-prod clean

get:
	$(FLUTTER) pub get

gen:
	$(DART) run build_runner build --delete-conflicting-outputs

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test --coverage

format:
	$(DART) format lib test

run-dev:
	$(FLUTTER) run --flavor dev --target lib/main_dev.dart

run-staging:
	$(FLUTTER) run --flavor staging --target lib/main_staging.dart

run-prod:
	$(FLUTTER) run --flavor prod --target lib/main_prod.dart

clean:
	$(FLUTTER) clean
