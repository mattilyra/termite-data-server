#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import subprocess

DEFAULT_DATASET = 'infovis'
DATASETS = [ DEFAULT_DATASET, '20newsgroups', 'nsfgrants', 'nsf25k', 'nsf10k', 'nsf1k', 'poliblogs', 'fomc' ]

DEFAULT_MODEL = 'mallet'
MODELS = [ DEFAULT_MODEL, 'treetm', 'stmt', 'stm', 'gensim' ]

def Shell(command):
	p = subprocess.Popen(command, stdout = subprocess.PIPE, stderr = subprocess.STDOUT)
	while p.poll() is None:
		line = p.stdout.readline().rstrip('\n')
		if len(line) > 0:
			print line

def Demonstrate(dataset, model, is_quiet, force_overwrite):
	database_filename = 'data/demo/{}/corpus/corpus.db'.format(dataset)
	corpus_filename = 'data/demo/{}/corpus/corpus.txt'.format(dataset)
	model_folder = 'data/demo/{}/model-{}'.format(dataset, model)
	app_name = '{}_{}'.format(dataset, model)

	def PrepareDataset():
		executable = 'bin/fetch_dataset.sh'
		Shell([executable, dataset])
	
	def PrepareModel():
		executable = 'bin/setup_{}.sh'.format(model)
		Shell([executable])
	
	def PrepareOthers():
		executable = 'bin/setup_corenlp.sh'
		Shell([executable])
	
	def ExtractCorpus():
		executable = 'bin/export_corpus.py'
		Shell([executable, database_filename, corpus_filename])
	
	def TrainModel():
		executable = 'bin/train_{}.py'.format(model)
		if model == 'stm':
			corpus_folder = 'data/demo/{}/corpus'.format(dataset)
			command = [executable, corpus_folder, model_folder]
		else:
			command = [executable, corpus_filename, model_folder]
		if is_quiet:
			command.append('--quiet')
		if force_overwrite:
			command.append('--overwrite')
		Shell(command)

	def ImportModel():
		executable = 'bin/read_{}.py'.format(model)
		command = [executable, app_name, model_folder, corpus_filename, database_filename]
		if is_quiet:
			command.append('--quiet')
		if force_overwrite:
			command.append('--overwrite')
		Shell(command)

	print '--------------------------------------------------------------------------------'
	print 'Build a topic model ({}) using a demo dataset ({})'.format(model, dataset)
	print 'database = {}'.format(database_filename)
	print '  corpus = {}'.format(corpus_filename)
	print '   model = {}'.format(model_folder)
	print '     app = {}'.format(app_name)
	print '--------------------------------------------------------------------------------'
	
	PrepareDataset()
	PrepareModel()
	PrepareOthers()
	ExtractCorpus()
	TrainModel()
	ImportModel()
	
def main():
	parser = argparse.ArgumentParser( description = 'Import a MALLET topic model as a web2py application.' )
	parser.add_argument( 'dataset'     , nargs = '?', type = str, default = DEFAULT_DATASET, choices = DATASETS, help = 'Dataset identifier' )
	parser.add_argument( 'model'       , nargs = '?', type = str, default = DEFAULT_MODEL  , choices = MODELS  , help = 'Model type' )
	parser.add_argument( '--quiet'     , const = True, default = False, action = 'store_const', help = 'Show fewer debugging messages' )
	parser.add_argument( '--overwrite' , const = True, default = False, action = 'store_const', help = 'Overwrite any existing model'  )
	args = parser.parse_args()
	Demonstrate( args.dataset, args.model, args.quiet, args.overwrite )

if __name__ == '__main__':
	main()
