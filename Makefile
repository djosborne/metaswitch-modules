.PHONEY: modules

modules:
	docker build -t djosborne/metamodules .
