#!/usr/bin/perl -w
use perlchartdir;
use List::Util qw(first max maxstr min minstr reduce shuffle sum); 

#########################################
# to_chart.pl
# by Michael
# 使用方法
# 将本脚本和经过handleSimple.pl处理产生的数据文件放到同一个目录下:
#  encode.txt, up.txt, down. txt, iperf.txt
# 执行本脚本
# 效果
# 根据数据文件绘制出曲线图
##########################################

##############################################
# 第一部分 准备数据

# 定义源数据文件
my @results = ("up.txt", "down.txt", "iperf.txt", "encode.txt");

# 从文件中读入数据
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

#格式化数据
print "$#up, $#down, $#iperf, $#encode\n";
$len = max(($#up, $#down, $#iperf, $#encode));

for(0 .. $len) { #每5秒一个数据, 转化为每1秒一个数据, 缺失的数据使用$perlchartdir::NoValue填充
    if (($_+1)%5==0) {
    	if(@up) { #数组非空
            push(@up_linedata, shift(@up));
        } else { #数组空
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
#for(@down_linedata) { #已经是每秒1个数据
#    print "$_\n";
#}

for(0 .. $len) { #每5秒一个数据, 转化为每1秒一个数据, 缺失的数据使用$perlchartdir::NoValue填充
    if (($_+1)%5==0) {
        if(@iperf) { #数组非空
            push(@iperf_linedata, shift(@iperf));
        } else { #数组空
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
#for(@encode_linedata) { #已经是每秒1个数据
#    print "$_\n";
#}


# 根据数据个数生成标注信息
my @lab;
my $labels = \@lab;
for(0..$#down) {
    push(@lab, "$_");   
}

##############################################
# 第二部分 绘图图表
$title = "Live Broadcast Speed Info.";
$y_title = "Kbits per second";
$x_title = "60 second / unit";
$chart_name = "speed.png";
$adjust = 4;

# 创建画布, 尺寸 600 x 300像素, 底色 0xEEEEFF, 边框 0x000000, 边框宽1像素, 圆角
my $c = new XYChart(600*$adjust, 300*$adjust, 0xeeeeff, 0x000000, 1);
$c->setRoundedFrame();

# 指定绘图区域, 左上角 (55, 58), 尺寸520 x 195像素, 底色0xffffff. 横坐标和纵坐标网格打开, 网格线颜色0xcccccc
$c->setPlotArea(55*$adjust, 58*$adjust, 520*$adjust, 195*$adjust, 0xffffff, -1, -1, 0xcccccc, 0xcccccc);

# 添加图例, 左上角(50,30), 水平排版, 使用9pt的Arial Bold字体
# 背景设为透明
$c->addLegend(50*$adjust, 30*$adjust, 0, "arialbd.ttf", 9)->setBackground($perlchartdir::Transparent);

# 添加标题, 内容为$title, 使用15pt的Times粗体斜体字体
# 背景设为0xccccff颜色, 玻璃效果
$c->addTitle($title, "timesbi.ttf", 15)->setBackground(0xccccff, 0x000000,
    perlchartdir::glassEffect());

# 添加Y轴的标题
$c->yAxis()->setTitle($y_title);

# 指定X轴的标注
$c->xAxis()->setLabels($labels);

# 指定X轴的标注步长, 每多少个标注显示
$c->xAxis()->setLabelStep(60);

# 添加X周的标题
$c->xAxis()->setTitle($x_title);

# 添加绘线层
my $layer = $c->addLineLayer2();

# 绘线宽2像素
$layer->setLineWidth(2);

# 根据数据绘制曲线
# 指定数据, 颜色, 内容标题
$layer->addDataSet(\@up_linedata, 0xff0000, "uplink");
$layer->addDataSet(\@down_linedata, 0x888800, "downlink");
$layer->addDataSet(\@iperf_linedata, 0x00ff00, "iperf")->setDataSymbol($perlchartdir::GlassSphere2Shape, 11);
$layer->addDataSet(\@encode_linedata, 0x0000ff, "encode");
$layer->setGapColor($c->dashLineColor(0xff0000));

# 输出图表
$c->makeChart($chart_name);

