all: lazy.cat.zsh.zwc opts.cat.zsh.zwc
.PHONY: all

test: all
	zsh tests/completion.zsh
.PHONY: test


%.zsh.zwc: %.zsh
	zsh -c "zcompile $<"

OPTS_FILES = $(wildcard opts/*.zsh)
LAZY_FILES = $(wildcard lazy/*.zsh)

opts.cat.zsh: $(OPTS_FILES) opts
	cat `find opts -name '*.zsh' | sort` > $@

lazy.cat.zsh: $(LAZY_FILES) lazy
	cat `find lazy -name '*.zsh' | sort` > $@

clean:
	rm -f *.zwc *.cat.zsh
.PHONY: clean
