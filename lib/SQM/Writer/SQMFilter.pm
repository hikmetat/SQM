use v6;

use StreamDispatcher::SQMDispatcherBase;

=begin pod
=TITLE SQM::Writer::SQMDumper
=para Dumps SQM input

=begin SYNOPSIS
=begin code
SQM::Writer::SQMDumper.new( 
		stream-buffer => Utilities::StreamBuffer.new( 
				input => 'sample.sqm'  
			) 
	).parse;
=end code
=end SYNOPSIS

=begin DESCRIPTION
This is the base class for as SAX-like event dispatcher for SQM handling. It extends 
L<StreamDispatcher::StreamDispatcherBase> by providing a methods for the following events:
=item class-begin
=item attrib
=item class-end
=item array-begin
=item array-elem
=item array-end
Hence the call to event I<the-event> will be I<evp_the-event(%event-hash)>
the methods for events are emty hence unimplemented events will silently be ignored unless
the descendant class implements an action
=end DESCRIPTION

=end pod
=cut

class SQM::Writer::SQMFilter is StreamDispatcher::SQMDispatcherBase {
	
	my Str $last-array-name;
	my @class-stack = { name => 'ROOT', attribs => {}, arrays => {} }, ;
	
	method attrib(Str :$name, Str :$value)	{ 
		say "\tATTRIB $name = $value";
		@class-stack[*-1]<attribs>{$name} = $value
	}
	method class-begin(Str :$name) { 
		say "CLASS = $name";
		@class-stack.push: name=> $name, attribs => {}, arrays => {}
	}
	method array-begin(Str :$name) {
		$last-array-name = $name;
		@class-stack[*-1]<arrays>{$last-array-name} = []
	}
	method array-elem(Str :$value) { 
		push @class-stack[*-1]<arrays>{$last-array-name}: $value
	}
	method class-end(Str :$name) {
		my $class = @class-stack.pop;
		$class<name>.say
	}	
	method array-end(Str :$name) {
		$last-array-name = ''
	}
}