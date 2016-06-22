use Win32::OLE;   #����win32 OLE��
use Data::Dumper;
use Cwd;

=copyright
Author: Michael Yu
Date: 2013/8/16
File: kaoqin.pl
Help: 
Use it at first.
Put it in the same folder where the excel data exists.
1. produce the late and absent report per day.
=cut

#############################################################
our $dir = pwd_for_windows();
our @floor3_range;
our @floor6_range;
#############################################################

#############################################################
# ���ߺ���
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

sub show_time($){
    ($time)=@_;
    $my_time=$time*1440;
    $my_time=($my_time>int($my_time)) ? int($my_time)+1 : int($my_time);
    
    $hour=int($my_time/60);
    $minute=$my_time%60;
    $minute=(length($minute)==1) ? "0".$minute : $minute;
    
    $result_time=$hour.":".$minute;
    return $result_time;
}

sub print_result_text {
	my ($date, $late, $absent) = @_;
	$filename_late = "late_".$date.".txt";
	$filename_absent = "absent_".$date.".txt";
	
	if(%$late) {
		open my $fh_late, ">", $filename_late or die "unable to open $filename_late: $!";
		foreach $name (keys %$late) {
			my $ref = $late->{$name};
            print $fh_late $ref->{"name"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"date"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"type"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"result"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"lateby"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"earlyby"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"arrive"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_late $ref->{"leave"}.", " or die "writing text to '$filename_late' failed: $!\n";
			print $fh_late "\n" or die "writing text to '$filename_late' failed: $!\n";
		}
		close $fh_late;
	}
	
	if(%$absent) {
        open my $fh_absent, ">", $filename_absent or die "unable to open $filename_absent: $!";
        foreach $name (keys %$absent) {
            my $ref = $absent->{$name};
            print $fh_absent $ref->{"name"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"date"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"type"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"result"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"lateby"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"earlyby"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"arrive"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent $ref->{"leave"}.", " or die "writing text to '$filename_late' failed: $!\n";
            print $fh_absent "\n" or die "writing text to '$filename_absent' failed: $!\n";
        }
        close $fh_absent;
    }
}

sub scan_excel {
	$filename = shift @_;
	my $excel = $dir.$filename;
	
	# ����EXCELӦ�ö���
    my $app_xls = Win32::OLE->new('Excel.Application', sub{$_[0]->Quit}) or die "Excel ��ʼ��ʧ�ܣ������û�а�װExcel��";
    $app_xls->{DisplayAlerts} = 'False';    #�ص�excel����ʾ�������Ƿ񱣴��޸�֮���
    
    #��һ�����ڻ��ṩ��EXCEL�ļ�
    my $src_book = $app_xls->WorkBooks->Open($excel);
    my $src_sheet = $src_book->Worksheets(1); #ѡ�е�һ��������
    
    my $is_floor3 = 1;
    my $is_floor6 = 0;
    foreach $line (1 .. 500) {
    	my $name = trim($src_sheet->Cells($line,1)->{Value});  #ȡ�ô��е�����
    	if ($is_floor3) {
    		if ($name eq '����') {
    			$floor3_range[0] = $line + 1; # 3¥��ʼ��
    		} elsif (!$name) {
    			$floor3_range[1] = $line - 1; # 3¥������
    			$is_floor3 = 0;
    		}
    	} else {
    		if ($name eq '����') {
                $floor6_range[0] = $line + 1; # 6¥��ʼ��
                $is_floor6 = 1;
            } elsif ((!$name) and ($is_floor6)) {
                $floor6_range[1] = $line - 1; # 6¥������
                $is_floor6 = 0;
            }
    	}
    }	
    	
    undef $src_book; #�����˾������������������
    undef $dst_book; #�����˾������������������
    undef $app_xls;  #�ص����򿪵�excelӦ��
}
#############################################################

sub handle_one {
	$filename = shift @_;
	
    my %floor3;
    my %floor6;
    my $date;
    my $excel = $dir.$filename;
    
    $date = $filename;
    $date =~ s/\.xls$//;
    
    scan_excel($filename);
    
    # ����EXCELӦ�ö���
    my $app_xls = Win32::OLE->new('Excel.Application', sub{$_[0]->Quit}) or die "Excel ��ʼ��ʧ�ܣ������û�а�װExcel��";
    $app_xls->{DisplayAlerts} = 'False';    #�ص�excel����ʾ�������Ƿ񱣴��޸�֮���
    
    #��һ�����ڻ��ṩ��EXCEL�ļ�
    my $src_book = $app_xls->WorkBooks->Open($excel);
    my $src_sheet = $src_book->Worksheets(1); #ѡ�е�һ��������
    
    # �õ�3¥����
    foreach $line ($floor3_range[0] .. $floor3_range[1]) {
        my $name = $src_sheet->Cells($line,1)->{Value};  #ȡ�ô��е�����
        # ����    ����    ������    ���ڽ��    �ٵ�ʱ��(��) ����ʱ��(��) ǩ��ʱ��    ǩ��ʱ��
        $floor3{$name} = {
            name => $name,
            date => $src_sheet->Cells($line,2)->{Value},
            type => $src_sheet->Cells($line,3)->{Value},
            result => $src_sheet->Cells($line,4)->{Value},
            lateby => $src_sheet->Cells($line,5)->{Value},
            earlyby => $src_sheet->Cells($line,6)->{Value},
            arrive => $src_sheet->Cells($line,7)->{Value},
            leave => $src_sheet->Cells($line,8)->{Value}
        };
    }
    #print Dumper %floor3;
    
    # �õ���¥����
    foreach $line ($floor6_range[0] .. $floor6_range[1]) {
        my $name = $src_sheet->Cells($line,1)->{Value};  #ȡ�ô��е�����
        # ����    ����    ������    ���ڽ��    �ٵ�ʱ��(��) ����ʱ��(��) ǩ��ʱ��    ǩ��ʱ��
        $floor6{$name} = {
            name => $name,
            date => $src_sheet->Cells($line,2)->{Value},
            type => $src_sheet->Cells($line,3)->{Value},
            result => $src_sheet->Cells($line,4)->{Value},
            lateby => $src_sheet->Cells($line,5)->{Value},
            quitby => $src_sheet->Cells($line,6)->{Value},
            arrive => show_time($src_sheet->Cells($line,7)->{Value}),
            leave => show_time($src_sheet->Cells($line,8)->{Value})
        };
    }
    #print Dumper %floor6;
    
    my %late;
    my %absent;
    
    # ������¥����
    foreach $name (keys %floor3) {
       if (trim($floor3{$name}->{'result'}) or trim($floor3{$name}->{'lateby'})) {
        $f3_ref = $floor3{$name};
        if (trim($f3_ref->{'result'})) {
            $absent{$name} = {
                name => $f3_ref->{'name'},
                date => $f3_ref->{'date'},
                type => $f3_ref->{'type'},
                result => $f3_ref->{'result'},
                lateby => $f3_ref->{'lateby'},
                earlyby => $f3_ref->{'earlyby'},
                arrive => $f3_ref->{'arrive'},
                leave => $f3_ref->{'leave'}
            };
        } elsif (trim($floor3{$name}->{'lateby'})) {
            $late{$name} = {
                name => $f3_ref->{'name'},
                date => $f3_ref->{'date'},
                type => $f3_ref->{'type'},
                result => $f3_ref->{'result'},
                lateby => $f3_ref->{'lateby'},
                earlyby => $f3_ref->{'earlyby'},
                arrive => $f3_ref->{'arrive'},
                leave => $f3_ref->{'leave'}
            };
        }
       }
    }
    
    # ������¥����
    foreach $name (keys %floor6) {
        if (trim($floor6{$name}->{'result'}) ne '����') {
            $f6_ref = $floor6{$name};
            if (trim($floor6{$name}->{'result'}) eq '����') {
                $absent{$name} = {
                    name => $f6_ref->{'name'},
                    date => $f6_ref->{'date'},
                    type => $f6_ref->{'type'},
                    result => $f6_ref->{'result'},
                    lateby => $f6_ref->{'lateby'},
                    earlyby => $f6_ref->{'earlyby'},
                    arrive => $f6_ref->{'arrive'},
                    leave => $f6_ref->{'leave'}
                };
            } elsif (trim($floor6{$name}->{'result'}) eq '�ٵ�') {
                $late{$name} = {
                    name => $f6_ref->{'name'},
                    date => $f6_ref->{'date'},
                    type => $f6_ref->{'type'},
                    result => $f6_ref->{'result'},
                    lateby => $f6_ref->{'lateby'},
                    earlyby => $f6_ref->{'earlyby'},
                    arrive => $f6_ref->{'arrive'},
                    leave => $f6_ref->{'leave'}
                };
            }
        }
    }
    
    print_result_text($date, \%late, \%absent);
    
    undef $src_book; #�����˾������������������
    undef $dst_book; #�����˾������������������
    undef $app_xls;  #�ص����򿪵�excelӦ��
}

sub main {
	chdir $dir or die "cannot chdir to $dir: $!";
	my @all_files = glob "*.xls";
	
	foreach $fn (@all_files) {
		print "���ڴ���: $fn\n";
		handle_one($fn);
	}
}

main();

#End
