#!/usr/bin/perl -w

# ���е�ǰĿ¼�µ�txt�ļ�
my $dir_to_process = ".";
my @fnames;
opendir DH, $dir_to_process or die "Cannot open $dir_to_process: $!";
foreach $file (readdir DH) {
	if ($file =~ /.*\.txt/) {
            push(@fnames, $file);
	}
}
closedir DH;

# ��׼�����������ļ�
open my $iperf, ">", "iperf.txt" or die "unable to open output.txt: $!";
open my $down, ">", "down.txt" or die "unable to open down.txt: $!";
open my $up, ">", "up.txt" or die "unable to open up.txt: $!";
open my $encode, ">", "encode.txt" or die "unable to open encode.txt: $!";

for (@fnames) { 
    if($_ ne "output.txt") {
#      print "$_\n";
      handle($_); # ������
	}
}

close $out;
close $iperf;
close $down;
close $up;
close $encode;


sub handle {
  my ($fname) = @_;
  
  # ���ݲ�ͬ�Ľ���ļ�, ���ò�ͬ�Ĵ�����
  if ($fname =~ /logiperf/) {
  	parse_iperf($fname);
  } elsif ($fname =~ /speed_\d*\.txt/) {
  	parse_speed($fname);
  } elsif ($fname =~ /livevideoinfo\.txt/) {
    parse_livevideoinfo($fname);
  } elsif ($fname =~ /videoSendedFile\.txt/) {
    parse_videoSendedFile($fname);
  }
  
#  print "=============================================================\n";
}

# ����iperf���
sub parse_iperf {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open '.txt': $!";
  
  my @bw;
  while (<$fh>) {
  	  #����Mbits��kbits, �ֱ���
      if (m/Bytes\s+(\d+.\d+)\s+Mbits/) {
          chomp($1);
          push(@bw, $1*1024); # ���ݷ�������
      } else {
        if (m/Bytes\s+(\d+.\d+)\s+Kbits/) {
          chomp($1);
          push(@bw, $1); # ���ݷ�������
        }
      }
  }
  # ��ӡ���������
  select $iperf;
  for(@bw) {
  	print "$_\n";
  }
  
  close($fh);
}

# ����speed���
sub parse_speed {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open 'speed.txt': $!";
  select $down;
  
  my @bw;
  while (<$fh>) {
      @bw = split /\s+/, $_; #�Կո��ַ�Ϊ�ָ��, ��ÿ�н��зָ�
      if($bw[2] =~ /(\d*)Kb/) { #��3��Ϊ������Ҫ���ٶ�ֵ, ͬʱʹ��������ʽȥ���ٶȵ�λ
        print "$1\n";
      }
  }
  
  close($fh);
}

# ����livevideoinfo���
sub parse_livevideoinfo {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open 'speed.txt': $!";
  select $encode;
  
  my @bw;
  while (<$fh>) {
      if($_ =~ /(\d+.\d+) kbps in (\d+.\d+) seconds/) { # ʹ��������ʽ��ȡ������Ҫ���ٶ�ֵ
        print "$1\n";
      }
  }
  
  close($fh);
}

# ����videoSendedFile���
sub parse_videoSendedFile {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open 'speed.txt': $!";
  select $up;
  
  my @bw;
  while (<$fh>) {
      if($_ =~ /(\d+.\d+) kbps in (\d+.\d+) seconds/) {  # ʹ��������ʽ��ȡ������Ҫ���ٶ�ֵ
        print "$1\n";
      }
  }
  
  close($fh);
}
