use v6;
=begin pod
=TITLE StreamParser::Base
=para Base class for as SAX-like stream processor

=begin SYNOPSIS
=begin code
my Utilities::StreamBuffer $buffer .= new( :input($input)  ) ;
say $buffer.get;
$buffer.unget('Something');

=end code
=end SYNOPSIS

=begin DESCRIPTION
This class takes various inputs (file handles, file paths, strings), provides lines from these inputs via an internal buffer through L<get()>
and allows strings to be pushed back through the routine L<unget()> in a LIFO fashion.
=end DESCRIPTION

=begin METHOD 
=begin code
Utilities::StreamBuffer.=new( :input($input) )
=end code
I<new()> creates an instance of B<Utilities::StreamBuffer>

B<Arguments:>
=item input: file handle, file path or string input
=end METHOD

=begin METHOD 
=begin code
get()
=end code
The method I<get()> fetches one line from the input
=end METHOD

=begin METHOD 
=begin code
unget(Str $line)
=end code
The method I<unget()> returns back one line to the input buffer. Unget does not alter the underlying input stream (ungets are only buffered not saved).
B<Arguments:>
=item line: string input
=end METHOD


=end pod
=cut

class Utilities::StreamBuffer {

	has IO::Handle $.file;
	has Str @.buffered-lines;
	has Str $.input-type;
	has Int $.char-position;
	has Int $.line-position;
	
	# take a file handle or a string of file to open as new arg
	
	multi method new( IO::Handle :$input! )						{ self.bless( file => $input, 						 											input-type => 'IO::Handle'	) }
	multi method new( Str :$input! where {$input.IO ~~ :e} )	{ self.bless( file => open($input),										 						input-type => 'Path'		) }
	multi method new( Str :$input! )							{ self.bless( 						buffered-lines => $input.split("\n"), 						input-type => 'Text' 	 	) }
	multi method new( :@input! )								{ self.bless( 						buffered-lines => @input.map( { .Str.split("\n") } ).flat, 	input-type => 'Array' 	  	) }
	multi method new(  )										{ self.bless( 																					input-type => 'Null' 	  	) }
	
	multi method new( Any :$input! )							{ die 'Unhandled input type' }
	
	multi method source( IO::Handle :$input!, Bool :$reset-pos = False, Bool :$flush = True ) { 
		self!_source( :$input, :type( 'IO::Handle' ), :$reset-pos, :$flush, :new-lines( [] ) )					
	}
	multi method source( Str :$input! where {$input.IO.e}, Bool :$reset-pos = False, Bool :$flush = True ) { 			
		self!_source( :input( open($input) ), :type( 'Path' ), :$reset-pos, :$flush, :new-lines( [] ) )						
	}
	multi method source( Str :$input!, Bool :$reset-pos = False, Bool :$flush = True ) { 		
		self!_source( :type( 'Text' ), :$reset-pos, :$flush, :new-lines( $input.split("\n") ) )
	}
	multi method source( :@input!, Bool :$reset-pos = False, Bool :$flush = True ) { 		
		self!_source( :type( 'Array' ), :$reset-pos, :$flush, :new-lines( @input.map( { .Str.split("\n") } ).flat ) )				
	}
	multi method source( Bool :$reset-pos = False, Bool :$flush = True ) { 			
		self!_source( :type( 'Null' ), :$reset-pos, :$flush, :new-lines( [] ) )					
	}
	multi method source( Any :$input!, Bool :$reset-pos = False, Bool :$flush = True ) { 		
		die 'Unhandled input type'				
	}
	method !_source( IO::Handle :$input, Str :$type!, Bool :$reset-pos!, Bool :$flush!, :@new-lines! ) {
		$input.defined ?? ($!file = $input) !! ($!file = IO::Handle);
		$!input-type	 = $type;
		$!char-position  = $!char-position * +!$reset-pos;
		$!line-position  = $!line-position * +!$reset-pos;
		@!buffered-lines = Empty if $flush;
		@!buffered-lines = (@new-lines, @!buffered-lines).flat;
	}
	method !_eof() {
		$!file.defined ?? $!file.eof !! True
	}
	
	# get line from 'returns', if not file
	method get() {
		my Str $line;
		# get a new line into buffer from the file if it is a file and not eof
		@!buffered-lines.push( $!file.get ) unless self!_eof;		
		# if there is a line update position and return with true even if empty str
		if @!buffered-lines {
			my $line = @!buffered-lines.shift;
			$!char-position += $line.chars;
			++$!line-position;
			return $line but True		
		} else {
			return '' but False
		}
	}
	
	# push back line to 'returns'
	method unget(Str $line) { 
		# split on LB
		my @new-lines = $line.split("\n");
		# unshift lines
		@!buffered-lines = (@new-lines, @!buffered-lines).flat;
		# rewind char-position by chars - LB's
		$!char-position -= $line.chars - @new-lines.elems + 1;
		$!line-position -= @new-lines.elems;
	
	}
}
