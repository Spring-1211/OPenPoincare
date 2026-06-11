.PHONY: update cache build check-pending check-no-sorry blueprint-web blueprint-pdf blueprint-all blueprint-check clean

update:
	lake update

cache:
	lake exe cache get

build:
	lake build

check-pending:
	python3 scripts/check_pending.py

check-no-sorry:
	python3 scripts/check_pending.py --fail-on-sorry

blueprint-web:
	leanblueprint web

blueprint-pdf:
	leanblueprint pdf

blueprint-all:
	leanblueprint all

blueprint-check:
	python3 scripts/check_blueprint.py

clean:
	rm -rf .lake/build blueprint/web blueprint/print blueprint/*.aux blueprint/*.log blueprint/*.out blueprint/*.toc blueprint/*.pdf blueprint/plastex.cache
