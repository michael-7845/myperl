#!/usr/bin/perl -w

use Data::Dumper;

# Look out!
# Please specify your source file and output file correctly
our $source = 'D:\012app\script\orginal';
our $output = 'D:\012app\script\output'; # postfix "_<vuser>" will be appended

our %results = ();
our %transactions;
our %httpResponses;

sub getDuration {
	my ($line) = @_;
	if ($line =~ /Duration:\s*(.*)\./) {
		$results{duration} = $1;
	}
}

sub getVuser {
	my ($line) = @_;
	if ($line =~ /Maximum Running Vusers:\s*(\S+)/) {
		$results{vuser} = $1;
	}
}

sub getTotalThruput {
	my ($line) = @_;
	if ($line =~ /Total Throughput \(bytes\):\s*(\S+)/) {
		$results{total_thruput} = $1;
	}
}

sub getAverageThruput {
	my ($line) = @_;
	if ($line =~ /Average Throughput \(bytes\/second\):\s*(\S+)/) {
		$results{ave_thruput} = $1;
	}
}

sub getTotalHits {
	my ($line) = @_;
	if ($line =~ /Total Hits:\s*(\S+)/) {
		$results{total_hits} = $1;
	}
}

sub getAverageHits {
	my ($line) = @_;
	if ($line =~ /Average Hits per Second:\s*(\S+)/) {
		$results{ave_hits} = $1;
	}
}

sub getTotalErrors {
	my ($line) = @_;
	if ($line =~ /Total Errors:\s*(\S+)/) {
		$results{total_errors} = $1;
	}
}

sub getTotalTransaction {
	my ($line) = @_;
	
	$digital_mode = '[\d|\.|,]+';
	if ($line =~ /Transactions: Total Passed:\s+($digital_mode)\s+Total Failed:\s+($digital_mode)\s+Total Stopped:\s+($digital_mode)/) {
		$results{passedTran} = $1;
		$results{failedTran} = $2;
		$results{stoppedTran} = $3;
	}
}

sub getSpecificTransaction {
	my ($line) = @_;
	
	my %tran;
	$digital_mode = '[\d|\.|,]+';
	
	if ($line =~ /^(\S*)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)/) {
		$tran{name} = $1;
		$tran{min} = $2;
		$tran{average} = $3;
		$tran{max} = $4;
		$tran{stddeviation} = $5;
		$tran{percent90} = $6;
		$tran{pass} = $7;
		$tran{fail} = $8;
		$tran{stop} = $9;
		$transactions{$1} = \%tran;
	}
}

sub getHttpResponse {
	my ($line) = @_;
	
	my %http;
	$digital_mode = '[\d|\.|,]+';
	
	if ($line =~ /^(HTTP_\d+)\s+($digital_mode)\s+($digital_mode)/) {
		$http{responseCode} = $1;
		$http{total} = $2;
		$http{persecond} = $3;
		$httpResponses{$1} = \%http;
	}
}

sub getConnections {
	my ($line) = @_;
	$digital_mode = '[\d|\.|,]+';
	
	if ($line =~ /(?<!New )Connections\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)/) {
		$results{connections} = $2;
	}
}

sub getConnectionsPerSecond {
	my ($line) = @_;
	$digital_mode = '[\d|\.|,]+';
	
	if ($line =~ /Connection Shutdowns\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)/) {
		$results{connsdownPerSecond} = $2;
	}
	if ($line =~ /New Connections\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)/) {
		$results{newconnsPerSecond} = $2;
	}
}

sub getTransPerSecond {
	my ($line) = @_;
	$digital_mode = '[\d|\.|,]+';
	
	if ($line =~ /\s+(\D+):Pass\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)/) {
		$transactions{$1}->{passPerSecond} = $3;
	}
}

sub getPagesPerSecond {
	my ($line) = @_;
	$digital_mode = '[\d|\.|,]+';
	
	if ($line =~ /Pages\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)\s+($digital_mode)/) {
		$results{pagesPerSecond} = $2;
	}
}

sub parse {
	open($ORIG,"<$source");
	
	while($line = <$ORIG>) {
	#	print "$line";
		getDuration($line);
		getVuser($line);
		getTotalThruput($line);
		getAverageThruput($line);
		getTotalHits($line);
		getAverageHits($line);
		getTotalErrors($line);
		getTotalTransaction($line);
		getSpecificTransaction($line);
		getHttpResponse($line);
		getConnections($line);
		getConnectionsPerSecond($line);
		getTransPerSecond($line);
		getPagesPerSecond($line);
	}
	
	$results{transactions} = \%transactions;
	$results{httpResponses} = \%httpResponses;
	
	#print Dumper %results;
	#print Dumper $results{transactions};
	#print $results{transactions}->{vuser_init_Transaction}->{name};
	
	close($ORIG);
}

sub output_obsolete {
	#general
	#输出: Vuser总数 | 持续时间 | 吞吐量总 | 平均(byte/s) | 点击总 | 点击/s | 错误总数 | 连接总数平均值 | 连接/s平均值 | 下载页面数/s
	$part1 = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
		$results{vuser}, $results{duration}, $results{total_thruput}, $results{ave_thruput}, 
		$results{total_hits}, $results{ave_hits}, $results{total_errors}, $results{connections},
		$results{connsdownPerSecond}, $results{newconnsPerSecond}, $results{pagesPerSecond});
	print "part1:\n$part1\n\n";
	
	#transaction
	#输出： 名称|最小|平均|最大|标准偏差|90%|通过|失败|每秒通过事务数
	$part2 = '';
	foreach $tran(keys $results{transactions}) {
		#print Dumper $results{transactions}->{$tran};
		$tran_ref = $results{transactions}->{$tran};
		$part2 .= sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
			$tran_ref->{name}, $tran_ref->{min}, $tran_ref->{average},
			$tran_ref->{max}, $tran_ref->{stddeviation}, $tran_ref->{percent90},
			$tran_ref->{pass}, $tran_ref->{fail}, $tran_ref->{passPerSecond});
	}
	print "part2:\n$part2\n";
	
	#http response
	$part3 = '';
	foreach $resp(keys $results{httpResponses}) {
		#print Dumper $results{httpResponses}->{$resp};
		$resp_ref = $results{httpResponses}->{$resp};
		$part3 .= sprintf("%s\t%s\n",
			$resp_ref->{responseCode}, $resp_ref->{persecond});
	}
	print "part3:\n$part3\n\n";
}

sub output {
	$output_file = $output . '_' . $results{vuser};
	print "Please check $output_file\n";
	open($OUT,">$output_file");
	
	#general
	#输出: Vuser总数 | 持续时间 | 吞吐量总 | 平均(byte/s) | 点击总 | 点击/s | 错误总数 | 连接总数平均值 | 连接/s平均值 | 下载页面数/s
	my $part1 = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
		$results{vuser}, $results{duration}, $results{total_thruput}, $results{ave_thruput}, 
		$results{total_hits}, $results{ave_hits}, $results{total_errors}, $results{connections},
		$results{connsdownPerSecond}, $results{newconnsPerSecond}, $results{pagesPerSecond});
	my $part1_blank = " \t \t \t \t \t \t \t \t \t \t ";
	
	#transaction
	#输出： 名称|最小|平均|最大|标准偏差|90%|通过|失败|每秒通过事务数
	my @part2;
	my $line = 0;
	foreach $tran(keys $results{transactions}) {
		#print Dumper $results{transactions}->{$tran};
		$tran_ref = $results{transactions}->{$tran};
		$part2[$line++]= sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s",
			$tran_ref->{name}, $tran_ref->{min}, $tran_ref->{average},
			$tran_ref->{max}, $tran_ref->{stddeviation}, $tran_ref->{percent90},
			$tran_ref->{pass}, $tran_ref->{fail}, $tran_ref->{passPerSecond});
	}
	my $part2_blank = " \t \t \t \t \t \t \t \t ";
	
	#http response
	my @part3;
	$line = 0;
	foreach $resp(keys $results{httpResponses}) {
		#print Dumper $results{httpResponses}->{$resp};
		$resp_ref = $results{httpResponses}->{$resp};
		$part3[$line++] = sprintf("%s\t%s",
			$resp_ref->{responseCode}, $resp_ref->{persecond});
	}
	my $part3_blank = " \t ";
	
	my $max_line = $#part2 > $#part3 ? $#part2 : $#part3;
	print 
	my $output = '';
	my $part1_line = '';
	my $part2_line = '';
	my $part3_line = '';
	foreach $line (0 .. $max_line) {
		$part1_line = $line > 0 ? $part1_blank : $part1;
		$part2_line = $line > $#part2 ? $part2_blank : $part2[$line];
		$part3_line = $line > $#part3 ? $part3_blank : $part3[$line];
		
		$output .= sprintf("%s\t%s\t%s\n", $part1_line, $part2_line, $part3_line);
	}
	#print $output;
	print $OUT $output;
	
	close($OUT);
}

&parse();
&output();

#End