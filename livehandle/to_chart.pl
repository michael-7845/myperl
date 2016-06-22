#!/usr/bin/perl -w
use perlchartdir;
use List::Util qw(first max maxstr min minstr reduce shuffle sum); 

#########################################
# to_chart.pl
# by Michael
# ʹ�÷���
# �����ű��;���handleSimple.pl��������������ļ��ŵ�ͬһ��Ŀ¼��:
#  encode.txt, up.txt, down. txt, iperf.txt
# ִ�б��ű�
# Ч��
# ���������ļ����Ƴ�����ͼ
##########################################

##############################################
# ��һ���� ׼������

# ����Դ�����ļ�
my @results = ("up.txt", "down.txt", "iperf.txt", "encode.txt");

# ���ļ��ж�������
my @up, @down, @iperf, @encode;
my @up_linedata, @down_linedata, @iperf_linedata, @encode_linedata;
my $res_ref;

for(@results) {
	open($fh, "<", $_) or die "cannot open '$_': $!";
	if(/up/) {
		$res_ref = \@up;
	} elsif(/down/) {
		$res_ref = \@down;
	} elsif(/iperf/) {
		$res_ref = \@iperf;
	} elsif(/encode/) {
		$res_ref = \@encode;
	}
	
	while (<$fh>) {
        chomp($_);
        push(@$res_ref, $_);
    }
    close $fh;
}

#��ʽ������
print "$#up, $#down, $#iperf, $#encode\n";
$len = max(($#up, $#down, $#iperf, $#encode));

for(0 .. $len) { #ÿ5��һ������, ת��Ϊÿ1��һ������, ȱʧ������ʹ��$perlchartdir::NoValue���
    if (($_+1)%5==0) {
    	if(@up) { #����ǿ�
            push(@up_linedata, shift(@up));
        } else { #�����
            push(@up_linedata, $perlchartdir::NoValue);
    	}
    } else {
    	push(@up_linedata, $perlchartdir::NoValue);
    }	
}
#for(@up_linedata) {
#    print "$_\n";
#}

@down_linedata = @down;
#for(@down_linedata) { #�Ѿ���ÿ��1������
#    print "$_\n";
#}

for(0 .. $len) { #ÿ5��һ������, ת��Ϊÿ1��һ������, ȱʧ������ʹ��$perlchartdir::NoValue���
    if (($_+1)%5==0) {
        if(@iperf) { #����ǿ�
            push(@iperf_linedata, shift(@iperf));
        } else { #�����
            push(@iperf_linedata, $perlchartdir::NoValue);
        }
    } else {
        push(@iperf_linedata, $perlchartdir::NoValue);
    }   
}
#for(@iperf_linedata) {
#    print "$_\n";
#}

@encode_linedata = @encode;
#for(@encode_linedata) { #�Ѿ���ÿ��1������
#    print "$_\n";
#}


# �������ݸ������ɱ�ע��Ϣ
my @lab;
my $labels = \@lab;
for(0..$#down) {
    push(@lab, "$_");   
}

##############################################
# �ڶ����� ��ͼͼ��
$title = "Live Broadcast Speed Info.";
$y_title = "Kbits per second";
$x_title = "60 second / unit";
$chart_name = "speed.png";
$adjust = 4;

# ��������, �ߴ� 600 x 300����, ��ɫ 0xEEEEFF, �߿� 0x000000, �߿��1����, Բ��
my $c = new XYChart(600*$adjust, 300*$adjust, 0xeeeeff, 0x000000, 1);
$c->setRoundedFrame();

# ָ����ͼ����, ���Ͻ� (55, 58), �ߴ�520 x 195����, ��ɫ0xffffff. ������������������, ��������ɫ0xcccccc
$c->setPlotArea(55*$adjust, 58*$adjust, 520*$adjust, 195*$adjust, 0xffffff, -1, -1, 0xcccccc, 0xcccccc);

# ���ͼ��, ���Ͻ�(50,30), ˮƽ�Ű�, ʹ��9pt��Arial Bold����
# ������Ϊ͸��
$c->addLegend(50*$adjust, 30*$adjust, 0, "arialbd.ttf", 9)->setBackground($perlchartdir::Transparent);

# ��ӱ���, ����Ϊ$title, ʹ��15pt��Times����б������
# ������Ϊ0xccccff��ɫ, ����Ч��
$c->addTitle($title, "timesbi.ttf", 15)->setBackground(0xccccff, 0x000000,
    perlchartdir::glassEffect());

# ���Y��ı���
$c->yAxis()->setTitle($y_title);

# ָ��X��ı�ע
$c->xAxis()->setLabels($labels);

# ָ��X��ı�ע����, ÿ���ٸ���ע��ʾ
$c->xAxis()->setLabelStep(60);

# ���X�ܵı���
$c->xAxis()->setTitle($x_title);

# ��ӻ��߲�
my $layer = $c->addLineLayer2();

# ���߿�2����
$layer->setLineWidth(2);

# �������ݻ�������
# ָ������, ��ɫ, ���ݱ���
$layer->addDataSet(\@up_linedata, 0xff0000, "uplink");
$layer->addDataSet(\@down_linedata, 0x888800, "downlink");
$layer->addDataSet(\@iperf_linedata, 0x00ff00, "iperf")->setDataSymbol($perlchartdir::GlassSphere2Shape, 11);
$layer->addDataSet(\@encode_linedata, 0x0000ff, "encode");
$layer->setGapColor($c->dashLineColor(0xff0000));

# ���ͼ��
$c->makeChart($chart_name);

