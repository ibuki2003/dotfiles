all: lazy.cat.zsh.zwc opts.cat.zsh.zwc
.PHONY: all


%.zsh.zwc: %.zsh
	zsh -c "zcompile $<"

OPTS_FILES = $(wildcard opts/*.zsh)
LAZY_FILES = $(wildcard lazy/*.zsh)

opts.cat.zsh: $(OPTS_FILES)
	cat `find opts -name '*.zsh' | sort` > $@

lazy.cat.zsh: $(LAZY_FILES)
	cat `find lazy -name '*.zsh' | sort` > $@

clean:
	rm -f *.zwc *.cat.zsh
.PHONY: clean
