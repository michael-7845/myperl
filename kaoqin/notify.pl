use Data::Dumper;
BEGIN {require 'email_kaoqin.pl'};

=copyright
Author: Michael Yu
Date: 2013/8/16
File: notify.pl
Help: 
Use it after the kaoqin.pl.
1. produce the statistic report per person;
2. send the mail notification, if required.
=cut

#############################################################
# 配置信息
$email_notification = 0; # 通知 - 1， 不通知 - 0
#############################################################

our $dir = pwd_for_windows();
our %late;
our %absent;
our %mail;
our $fn_per_person = "person.txt";

#############################################################
# 工具函数
sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return ($string);
}

sub pwd_for_windows {
    use Cwd;
    $pwd = getcwd;
    @tmp = split /\//, $pwd;
    $new_pwd = join "\\", @tmp;
    return $new_pwd."\\";
}
#############################################################

sub main {
	print "$dir\n";
	chdir $dir or die "cannot chdir to $dir: $!";
    my @lates = glob "late_*.txt";
    my @absents = glob "absent_*.txt";
    
    foreach $fn (@lates) {
        print "正在处理迟到统计: $fn\n";
        handle_one_late($fn);
    }
    
    foreach $fn (@absents) {
        print "正在处理旷工统计: $fn\n";
        handle_one_absent($fn);
    }
    
    late_info();
    absent_info();
    show_mail();
}

sub handle_one_late($) {
	my $fn = shift @_;
	my $full_fn = $dir.$fn;
	
	open $fh, "<", $full_fn or die "unable to open '$full_fn' for reading: $!\n";
    for my $filerow (<$fh>) {
       if(trim($filerow)) {
           my @array = split /,/, $filerow;
           if (not exists $late{$array[0]}) {
               $late{$array[0]} = [];
           }
           push($late{$array[0]}, {
               name => $array[0],
               date => $array[1],
               type => $array[2],
               result => $array[3],
               lateby => $array[4],
               earlyby => $array[5],
               arrive => $array[6],
               leave => $array[7]
           });
       }
    }
    
    close $fn;
}

sub handle_one_absent($) {
	my $fn = shift @_;
    my $full_fn = $dir.$fn;
    
    open $fh, "<", $full_fn or die "unable to open '$full_fn' for reading: $!\n";
    for my $filerow (<$fh>) {
       if(trim($filerow)) {
           my @array = split /,/, $filerow;
           if (not exists $absent{$array[0]}) {
               $absent{$array[0]} = [];
           }
           push($absent{$array[0]}, {
               name => $array[0],
               date => $array[1],
               type => $array[2],
               result => $array[3],
               lateby => $array[4],
               earlyby => $array[5],
               arrive => $array[6],
               leave => $array[7]
           });
       }
    }
    
    close $fn;
}

sub show_late {
    foreach $name (keys %late) {
    	foreach ($late{$name}) {
    	    print Dumper $_;
    	}
    }
}

sub show_absent {
    foreach $name (keys %absent) {
        foreach ($absent{$name}) {
            print Dumper $_;
        }
    }
}

sub late_info {
	my $message;
    foreach $name (keys %late) {
        foreach $person ($late{$name}) {
            foreach $day (@$person) {
            	$mail{$name} .= "$day->{'name'}, $day->{'date'}, $day->{'type'}, $day->{'result'}, ".
            	                "$day->{'lateby'}, $day->{'earlyby'}, $day->{'arrive'}, $day->{'leave'}\n";
            }
        }
    }
    
    
}

sub absent_info {
    my $message;
    foreach $name (keys %absent) {
        foreach $person ($absent{$name}) {
            foreach $day (@$person) {
                $mail{$name} .= "$day->{'name'}, $day->{'date'}, $day->{'type'}, $day->{'result'}, ".
                                "$day->{'lateby'}, $day->{'earlyby'}, $day->{'arrive'}, $day->{'leave'}\n";
            }
        }
    }
}

sub show_mail {
	open my $fh, ">", $dir.$fn_per_person or die "unable to open $fn_per_person: $!";
	foreach $name (keys %mail) {
		print "正在生成个人的考勤异常情况\n";
        print $fh "$name:\n$mail{$name}\n";
        if ($email_notification) {
        	&send('kemin_yu@163.com', $mail{$name});
        }
    }
    close $fh;
}

main();

#End