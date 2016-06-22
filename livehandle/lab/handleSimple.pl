#!/usr/bin/perl -w

# 编列当前目录下的txt文件
my $dir_to_process = ".";
my @fnames;
opendir DH, $dir_to_process or die "Cannot open $dir_to_process: $!";
foreach $file (readdir DH) {
	if ($file =~ /.*\.txt/) {
            push(@fnames, $file);
	}
}
closedir DH;

# 打开准备输出结果的文件
open my $iperf, ">", "iperf.txt" or die "unable to open output.txt: $!";
open my $down, ">", "down.txt" or die "unable to open down.txt: $!";
open my $up, ">", "up.txt" or die "unable to open up.txt: $!";
open my $encode, ">", "encode.txt" or die "unable to open encode.txt: $!";

for (@fnames) { 
    if($_ ne "output.txt") {
#      print "$_\n";
      handle($_); # 主函数
	}
}

close $out;
close $iperf;
close $down;
close $up;
close $encode;


sub handle {
  my ($fname) = @_;
  
  # 根据不同的结果文件, 调用不同的处理函数
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

# 处理iperf结果
sub parse_iperf {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open '.txt': $!";
  
  my @bw;
  while (<$fh>) {
  	  #区分Mbits和kbits, 分别处理
      if (m/Bytes\s+(\d+.\d+)\s+Mbits/) {
          chomp($1);
          push(@bw, $1*1024); # 数据放入数组
      } else {
        if (m/Bytes\s+(\d+.\d+)\s+Kbits/) {
          chomp($1);
          push(@bw, $1); # 数据放入数组
        }
      }
  }
  # 打印出结果数组
  select $iperf;
  for(@bw) {
  	print "$_\n";
  }
  
  close($fh);
}

# 处理speed结果
sub parse_speed {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open 'speed.txt': $!";
  select $down;
  
  my @bw;
  while (<$fh>) {
      @bw = split /\s+/, $_; #以空格字符为分割符, 将每行进行分割
      if($bw[2] =~ /(\d*)Kb/) { #第3个为我们需要的速度值, 同时使用正则表达式去掉速度单位
        print "$1\n";
      }
  }
  
  close($fh);
}

# 处理livevideoinfo结果
sub parse_livevideoinfo {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open 'speed.txt': $!";
  select $encode;
  
  my @bw;
  while (<$fh>) {
      if($_ =~ /(\d+.\d+) kbps in (\d+.\d+) seconds/) { # 使用正则表达式提取我们主要的速度值
        print "$1\n";
      }
  }
  
  close($fh);
}

# 处理videoSendedFile结果
sub parse_videoSendedFile {
  my ($fname) = @_;
  open($fh, "<", $fname) or die "cannot open 'speed.txt': $!";
  select $up;
  
  my @bw;
  while (<$fh>) {
      if($_ =~ /(\d+.\d+) kbps in (\d+.\d+) seconds/) {  # 使用正则表达式提取我们主要的速度值
        print "$1\n";
      }
  }
  
  close($fh);
}
