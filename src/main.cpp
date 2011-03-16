#include <iostream>
#include <string>
#include <vector>
#include <boost/program_options.hpp>

using namespace std;
namespace po = boost::program_options;

int main(int argc, char const **argv) {
	string mode, scheme;

	po::options_description explicit_options;
	explicit_options.add_options()
		("encoding,c", po::value<string>()->default_value("UTF-8"),
"Specifies the input and output encoding of the tokenizer. UTF-8 is used if none is specified.")
		("file-list,l", po::value< vector<string> >()->composing(),
"A list of input files to be processed. If mode is TRAIN and this setting is omitted, the file train.fl in scheme-path is used instead. For the EVALUATE mode, the file evaluate.fl is used as default. If the paths are relative, they are evaluated with respect to the location of the file list. More than 1 file list can be specified.")
		("filename-regexp,r", po::value<string>()->default_value("(.*)\\.txt/\1.tok"),
"A regular expression/replacement string used to generate a set of pairs of input/output files. Output files are written to in TOKENIZE mode and are used as correct answers in TRAIN and EVALUATE modes. If no such expression is given in TRAIN and EVALUATE modes, the contents of files train.fnre and evaluate.fnre in the directory scheme-path are used instead. If the mode is TOKENIZE, the output of tokenization is printed to the standard output.")
		("help,h", "Prints this usage information.")
		("preserve-paragraphs,p", "Replaces paragraph breaks with a blank line.")
		("detokenize,d", "Doesn't apply word splitting and joining decisions. The words found in the input are preserved, whitespace is condensed into single spaces or newlines in case of sentence break.")
		("preserve-segments,s", "Assumes sentence boundaries are already specified by newlines.")
		("hide-xml,x", "Hides XML markup from the tokenizer and then reintroduces it to the output.")
		("expand-entities,e", "Treats entities as the characters they represent. The output will preserve these characters as entities.")
		("print-questions,q", "Prints the questions presented to the maximum entropy classifier. In TOKENIZE mode, the classifier's answer is present as well; in TRAIN mode, it is the answer induced from the data. In EVALUATE mode, both the answer given by the classifier and the correct answer are output.")
		;

	po::options_description positional_options;
	positional_options.add_options()
		("mode", po::value<string>(&mode),"")
		("scheme", po::value<string>(&scheme), "")
		;
	
	po::positional_options_description pod;
	pod.add("mode", 1).add("scheme", 1);

	po::options_description all_options;
	all_options.add(explicit_options).add(positional_options);
	po::command_line_parser cmd_line(argc, argv);
	cmd_line.options(all_options).positional(pod);

	po::variables_map vm;
	po::store(cmd_line.run(), vm);
	po::notify(vm);

	if (vm.count("help"))
	{
		cout << "Usage: trtok <prepare|train|tokenize|evaluate> SCHEME [OPTION]... [FILE]..." << endl;
		cout << explicit_options;
	}
}
