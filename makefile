.PHONY: download run

include .env
export

download:
	python ingest/download_data.py

dbt-run:
	dbt deps
	dbt run

dbt-test:
	dbt test

dbt-docs:
	dbt docs generate

evidence:
	npm --prefix reports run sources
	npm --prefix reports run build

