DEMO_PATH = data/itm

all: web2py tools/mallet

web2py:
	bin/setup_web2py.sh

tools/mallet:
	bin/setup_mallet.sh

tools/gensim:
	bin/setup_gensim.sh

tools/stm:
	bin/setup_stm.sh

tools/treetm:
	bin/setup_treetm.sh

tools/stmt:
	bin/setup_stmt.sh

apps/infovis_mallet: web2py tools/mallet
	./demo.sh infovis mallet

apps/poliblogs_stm: web2py tools/stm data/poliblogs
	bin/import_stm.py poliblogs_stm data/poliblogs/corpus/poliblogs2008.RData
	bin/import_corpus.py poliblogs_stm --csv data/poliblogs/corpus/poliblogs2008.csv

apps/nsf1k_mallet: web2py tools/mallet data/demo/nsf127992
	./demo.sh nsf1k mallet

apps/nsf10k_mallet: web2py tools/mallet data/demo/nsf127992
	./demo.sh nsf10k mallet

apps/nsf25k_mallet: web2py tools/mallet data/demo/nsf127992
	./demo.sh nsf25k mallet

data/poliblogs:
	mkdir -p data
	mkdir -p data/poliblogs
	bin/fetch_poliblogs.sh data/poliblogs

data/demo/nsf127992:
	mkdir -p data
	mkdir -p data/demo
	mkdir -p data/demo/nsf127992
	bin/fetch_nsf127992.sh data/demo/nsf127992
	
data/itm/corpus:
	mkdir -p data
	mkdir -p data/itm
	bin/fetch_20newsgroups.sh data/itm

apps/10newsgroups: data/itm/corpus tools/mallet web2py
	bin/train_mallet.sh data/itm/corpus data/itm/10newsgroups 10
	bin/import_mallet.py 10newsgroups data/itm/10newsgroups
	bin/import_corpus.py 10newsgroups --terms data/itm/10newsgroups/corpus.mallet

apps/15newsgroups: data/itm/corpus tools/mallet web2py
	bin/train_mallet.sh data/itm/corpus data/itm/15newsgroups 15
	bin/import_mallet.py 15newsgroups data/itm/15newsgroups
	cp -r apps/10newsgroups/data/corpus apps/15newsgroups/data/corpus

apps/20newsgroups: data/itm/corpus tools/mallet web2py
	bin/train_mallet.sh data/itm/corpus data/itm/20newsgroups 20
	bin/import_mallet.py 20newsgroups data/itm/20newsgroups
	cp -r apps/10newsgroups/data/corpus apps/20newsgroups/data/corpus

clean:
	rm -rf externals
	rm -rf web2py
	rm -rf tools/mallet*
	rm -rf tools/treetm*
	rm -rf data/demo/infovis apps/infovis_mallet web2py/applications/infovis_mallet
	rm -rf data/itm
	rm -rf apps/10newsgroups web2py/applications/10newsgroups
	rm -rf apps/15newsgroups web2py/applications/15newsgroups
	rm -rf apps/20newsgroups web2py/applications/20newsgroups
