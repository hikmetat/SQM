use v6;

my $b = {
	use StreamDispatcher::StreamDispatcherBase;
	use SQM::Reader::SQMFragmentActions;
	use SQM::Reader::SQMFragmentGrammar;
	
	class StreamDispatcher::SQMDispatcherBase is StreamDispatcher::StreamDispatcherBase {}
}
use StreamParser::StreamParserBase;

class StreamDispatcher::StreamDispatcherBase is StreamParser::StreamParserBase {}


