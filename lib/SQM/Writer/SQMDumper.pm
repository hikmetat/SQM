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

class SQM::Writer::SQMDumper is StreamDispatcher::SQMDispatcherBase {
	
	method attrib(Str :$name, Str :$value)	{ say sprintf( "%-20s%-35s%-1000s", 'Attribute', 'Name=' ~ $name, 'Value=' ~ $value ) }
	method class-begin(Str :$name) 			{ say sprintf( "%-20s%-35s", 'Class Begin', 'Name=' ~ $name ) }
	method array-begin(Str :$name)			{ say sprintf( "%-20s%-35s", 'Array Begin', 'Name=' ~ $name ) }
	method array-elem(Str :$value)			{ say sprintf( "%-20s%-35s%-1000s", 'Array Elem', '', 'Value=' ~ $value ) }
	method class-end(Str :$name)			{ say sprintf( "%-20s%-35s", 'Class End', 'Name=' ~ $name ) }	
	method array-end(Str :$name)			{ say sprintf( "%-20s%-35s", 'Array End', 'Name=' ~ $name ) }
		
}