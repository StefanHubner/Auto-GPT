all:
	docker compose build auto-gpt

clean:
	docker compose rm auto-gpt
