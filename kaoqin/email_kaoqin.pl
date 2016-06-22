#!/usr/bin/perl -w
use Net::SMTP_auth;

=copyright
Author: Michael Yu
Date: 2013/8/16
File: email_kaoqin.pl
Help: 
Tool subprocess of sending mail.
Called by notify.pl.
=cut

#############################################################
# 手工配置
#smtp邮件服务器和端口
my $smtpHost = 'smtp.163.com';
my $smtpPort = '25';
my $sslPort = '465';

#smtp服务器认证用户名密码(就是你登陆邮箱的时候的用户名和密码)
my $username = 'cktcd_ykm';
my $passowrd = 'zaq12wsx';

#邮件来自哪儿，要去哪儿,邮件标题
my $from = 'cktcd_ykm@163.com';
my $subject = '[通知]考勤异常';

#############################################################

sub send {
	my ($to, $message) = @_;
	
#设置邮件header
my $header = << "MAILHEADER";
From:$from
To:$to
Subject:$subject
Mime-Version:1.0
Content-Type:text/plain;charset="GBK"
Content-Trensfer-Encoding:7bit

MAILHEADER

#设置邮件内容
my $mailbody = << "MAILBODY";
你好！

这是您名下可能的考情异常，请核对情况，及时提交请假单。
$message
敬上，
虞科敏
MAILBODY
    
    #获得邮件域名部分，用于连接的时候表名身份
    my @helo = split /\@/, $from;
    
    #普通方式，通信过程不加密
    my $smtp = Net::SMTP_auth->new(
                    "$smtpHost:$smtpPort",
                    Hello => $helo[1],
                    Timeout => 30
                    ) or die("Error:连接到$smtpHost失败！");
    $smtp->auth('LOGIN',$username,$passowrd) or die("Error:认证失败！");
    
    #发送邮件
    $smtp->mail($from);
    $smtp->to($to);
    $smtp->data();
    $smtp->datasend($header);
    $smtp->datasend($mailbody);
    $smtp->dataend();
    $smtp->quit();
    
    print "Email sending to $to OK\n";
}

#&send('kemin_yu@163.com', "陈旭,  2013-07-08,  正常上班,  迟到,  1,  ,  9:03,  21:18\n");

#End

