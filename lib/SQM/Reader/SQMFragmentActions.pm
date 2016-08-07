use v6;

class SQM::Reader::SQMFragmentActions {
	method TOP($/) { 
		$/.make: $<attrib>.made ;
		$/.make: $<class-begin>.made if $<class-begin>;
		$/.make: $<array-begin>.made if $<array-begin>;
		$/.make: $<array-elem>.made if $<array-elem>;
		$/.make: $<closer>.made if $<closer>;
	}
	method attrib($/) 		{ $/.make: 'attrib'			=>	{ name => ~$<attrib-name>, 	value => ~$<attrib-value>		} }	
	method class-begin($/)	{ $/.make: 'class-begin'	=>	{ name => ~$<class-name> 									} }	
	method array-begin($/)	{ $/.make: 'array-begin'	=>	{ name => ~$<array-name> 									} }	
	method array-elem($/)	{ $/.make: 'array-elem'		=>	{ 							value => ~$<array-elem-value> 	} }	
	method closer($/)		{ $/.make: 'closer'			=>	{															} }	
}	
	

