#!/usr/bin/perl
# Copyright (C) 2011  Francois Boulogne <fboulogne at april dot org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use warnings;
use strict;

use Encode;
use JSON::XS;
use LWP::Simple;


my $DATADIR="wiki-april/"; #Directory for data
mkdir $DATADIR; 


my $from = "";
my $count = 0;
use constant TITLE => $from;


#loop on different pages. Stop when $count==1.
while()
{
	$count=0;
	my $text= get("http://wiki.april.org/api.php?action=query&list=allpages&aplimit=500&format=json&apfilterredir=nonredirects&apfrom=$from");
	my $ret = JSON::XS->new->utf8->decode($text);
	my $elements = $ret->{query}->{allpages};

	#loop on all elements of the current page($from)
	foreach (@$elements)
	{
		my $title=encode("utf8","$_->{title}");
		$from=$title; #Do not modify this variable. No perl module for constant in arch extra/community...
		print $title."\n";
		my $raw_link="http://wiki.april.org/index.php?title=".$title ."&printable=yes&action=edit";
		my $raw = get($raw_link); #Download the page
		
		if (defined $raw)
                    {  
                        #modify raw data: keep only source code
                        $raw=~s/(.|\n)*name="wpTextbox1"\>//;
                        $raw=~s/\<\/textarea(.|\n)*//;
                        my $tmp = $title;
                        $tmp=~ s/\//_/g;
                        $tmp=~ s/ /_/g;
                        my $fname_raw=$DATADIR.$tmp.'.txt';
                        open (FILE,">:utf8",$fname_raw) or die "cannot open file $fname_raw";
                        print FILE $raw;
                        close(FILE);
                    }
		$count++;
	}
	last if($count == 1) #end of while loop
}
