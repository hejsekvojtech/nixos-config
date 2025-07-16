SRC_DIR := /etc/nixos
DST_DIR := $(CURDIR)

.PHONY: update restore diff commit backup clean-local clean-etc

update: clean-local
	@echo "Updating local repo with /etc/nixos/*.nix..."
	cp $(SRC_DIR)/*.nix $(DST_DIR)/

restore: clean-etc
	@echo "Restoring /etc/nixos from repo *.nix files..."
	sudo cp $(DST_DIR)/*.nix $(SRC_DIR)/

diff:
	@echo "Showing diffs..."
	@for f in $(DST_DIR)/*.nix; do \
		base=$$(basename $$f); \
		diff -uN $$f $(SRC_DIR)/$$base || true; \
	done

commit:
	@git add *.nix
	@git commit -m "Update nix config $$(date +'%Y-%m-%d %H:%M:%S')"

backup:
	@mkdir -p backups/$(shell date +%F)
	cp $(SRC_DIR)/*.nix backups/$(shell date +%F)/

clean-local:
	rm -f $(DST_DIR)/*.nix

clean-etc:
	sudo rm -f $(SRC_DIR)/*.nix
