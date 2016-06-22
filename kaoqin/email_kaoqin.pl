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
# �ֹ�����
#smtp�ʼ��������Ͷ˿�
my $smtpHost = 'smtp.163.com';
my $smtpPort = '25';
my $sslPort = '465';

#smtp��������֤�û�������(�������½�����ʱ����û���������)
my $username = 'cktcd_ykm';
my $passowrd = 'zaq12wsx';

#�ʼ������Ķ���Ҫȥ�Ķ�,�ʼ�����
my $from = 'cktcd_ykm@163.com';
my $subject = '[֪ͨ]�����쳣';

#############################################################

sub send {
	my ($to, $message) = @_;
	
#�����ʼ�header
my $header = << "MAILHEADER";
From:$from
To:$to
Subject:$subject
Mime-Version:1.0
Content-Type:text/plain;charset="GBK"
Content-Trensfer-Encoding:7bit

MAILHEADER

#�����ʼ�����
my $mailbody = << "MAILBODY";
��ã�

���������¿��ܵĿ����쳣����˶��������ʱ�ύ��ٵ���
$message
���ϣ�
�ݿ���
MAILBODY
    
    #����ʼ��������֣��������ӵ�ʱ��������
    my @helo = split /\@/, $from;
    
    #��ͨ��ʽ��ͨ�Ź��̲�����
    my $smtp = Net::SMTP_auth->new(
                    "$smtpHost:$smtpPort",
                    Hello => $helo[1],
                    Timeout => 30
                    ) or die("Error:���ӵ�$smtpHostʧ�ܣ�");
    $smtp->auth('LOGIN',$username,$passowrd) or die("Error:��֤ʧ�ܣ�");
    
    #�����ʼ�
    $smtp->mail($from);
    $smtp->to($to);
    $smtp->data();
    $smtp->datasend($header);
    $smtp->datasend($mailbody);
    $smtp->dataend();
    $smtp->quit();
    
    print "Email sending to $to OK\n";
}

#&send('kemin_yu@163.com', "����,  2013-07-08,  �����ϰ�,  �ٵ�,  1,  ,  9:03,  21:18\n");

#End

