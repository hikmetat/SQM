use v6;

=begin pod
=TITLE StreamDispatcher::StreamDispatcherBase
=para Base class for as SAX-like event dispatcher

=begin SYNOPSIS
=begin code
class MyClass is StreamDispatcher::StreamDispatcherBase {...}
my StreamBuffer $buffer .= new( :input($input)  ) ;
my Grammar $grammar;
my $actions;

my MyClass $my-dispatcher .=new( :stream-buffer( $buffer ), :stream-parser-grammar( $grammar ), :stream-parser-actions( $actions ) );
$my-parser.parse();
=end code
=end SYNOPSIS

=begin DESCRIPTION
This is the base class for as SAX-like event dispatcher. It extends L<StreamParser::Base>
by providing a I<process()> method which dispatches calls to methods with names derived from I<event>
by a prefix. It doesn't provide these methods which must be provided by a derived class.
It also provides an empty FALLBACK method for unimplemented event calls which may be extended
by descendant classes
=end DESCRIPTION

=end pod
=cut

use StreamParser::StreamParserBase;

class StreamDispatcher::StreamDispatcherBase is StreamParser::StreamParserBase {

	has Str $.event-prefix = 'evp_';
	
	method process( Str $event, %event-hash ) {
		my $method = $.event-prefix ~ $event;
		self."$method"(%event-hash);
	}
	method FALLBACK( $name, |c ) {}
}