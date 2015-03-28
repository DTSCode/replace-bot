#!/usr/local/bin/perl -w

use strict;
use IO::Socket;

my $server = "irc.freenode.net";
my $nick = "replace-bot";
my $login = "replace-bot";
my $channel = "#cplusplus.com";
my $sock = IO::Socket::INET->new(PeerAddr => $server, PeerPort => 6667, Proto => "tcp", Type => SOCK_STREAM) or die "Can't Connect.\n";

print $sock "NICK $nick\r\n";
print $sock "USER $login * * :Search and Replace Bot\r\n";

while(my $input = <$sock>) {
    if($input =~ /004/) {
        last;
    }

    elsif($input =~ /433/) {
        die "Nickname is already in use.";
    }
}

print $sock "JOIN $channel\r\n";

my $previnput = "";
my $prevnick = "";

while(my $input = <$sock>) {
    chop $input;

    if($input =~ /^PING(.*)$/i) {
        print $sock "PONG $1\r\n";
    }

    my @msg = split ' ', $input, 4;

    if($msg[1] =~ /^PRIVMSG$/i) {
        if($msg[3] =~ /^:\/s\/(.+?)\/(.+?)\//i or $msg[3] =~ /^:s\/(.+?)\/(.+?)\//i) {
            my $find = quotemeta $1;
            my $replace = $2;
            $previnput =~ s/$find/$replace/g;
            print $sock "PRIVMSG $msg[2] :$prevnick meant: $previnput\r\n";
        }

        elsif($msg[3] =~ /^:!(help|info|about)$/i) {
            print $sock "PRIVMSG $msg[2] :$nick is a bot to search and replace accidental text.\r\n";
            print $sock "PRIVMSG $msg[2] :Usage: /s/text to find/text to replace/ (Note that the / at the beginning is optional.\r\n";
        }

        elsif($msg[3] =~ /^:!source$/) {
            print $sock "PRIVMSG $msg[2] :Source: https://github.com/DTSCode/replace-bot\r\n";
        }

        $prevnick = substr $msg[0], 1, index($msg[0], '!') - 1;
        $previnput = substr $msg[3], 1, -1;
    }

    print "$input\n";
}
