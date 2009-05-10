#!/usr/bin/perl

use File::Basename;

$progname = "$0";
$version = "V1.3";
$copyright = "Copyright (C) 2008 Instanton";

$need_help=0;
$lead=9;
$md_afm=$md_type1=$mv_afm=$mv_type1=$extra_run=$vstem="";
$slant="sl";

$exitcode=0;
$ttfdir="%systemroot%\\fonts";
$ttf_folder="$ENV{'SYSTEMROOT'}\\Fonts";
$destdir=".\\Fonts";
$updmap=0;

$pfb=0;
$ttfname=0;
$familyname=0;

$cjkmapbase="cjk";

## default GBK encoding settings: 
	$encoding="GBK";
	$pre="gbk";
	$switches="-GFAe -L cugbk0.map+";
	$range=$range2="0,1,2,3,4,5,6,7,8,9";
	$Uenc="UGBK";
	$set_dim=$set2_dim=10;
	$fdpre="C19";
	$CJKnormal="";
	$fddir="GB";

sub usage
{
	print <<EOF;
FontGen $version: Configure Chinese fonts for TeX system
$copyright

Usage:   FontGen [-options]
Avaliable options:

  [-encoding=...]	  Set encoding of fonts. Supported encodings 
			  are GBK, UTF8 and Big5. Defaults to GBK;
  [-prefix=...]	  	  Prefix for CJK fonts. Defaults to gbk for GBK 
			  encoding, uni for UTF8 and b5 for Big5 encodings.  
			  Normally there is no need to reset this option;
  [-ttf=....ttf/c]	  Specify name of the TrueType fonts;
  [-CJKname=...]	  CJKfamily name of the generated fonts;
  [-psname=...]		  Postscript name of the fonts, can be omitted for
			  Sim* fonts under Windows XP;
  [-cjkmap=...]	  	  Base name of the .map file to be placed under
			  Fonts\\map. Defaults to be cjk (corresponds to 
			  cjk.map and cjk_ttf.map);
  [-ttfdir=...]		  Path to the TrueType fonts. Defaults to
			  %SystemRoot%\\Fonts;
  [-destdir=...]	  Location of destination. Defaults to .\\Fonts;
  [-Type1]		  Force generating Type1 fonts. Will not generate 
			  Type1 fonts if omitted;
  [-stemv=...]		  Add -v parameter into cid-x.map;
  [-updmap]		  Add map file info into updmap.cfg file;
  [--version|-v]	  Version number and copyright infomation;
  [--help|-h]	  	  Show this help text.
EOF
}

sub version
{
	print <<EOF;

FontGen $version: Automatically configure Chinese fonts for TeX
$copyright

This program comes with ABSOLUTELY NO WARRANTY.  This is free software, 
you are welcome to redistribute it under the terms of the GNU General 
Public License.

For help on usage of this program type FontGen --help or FontGen -h.  

EOF
}

if ($#ARGV<0) 
{
    usage();
	exit;
}
foreach $arg (@ARGV)
{
	if($arg =~ /-ttfdir=/)
	{
		$ttfdir=$arg;	
		$ttfdir =~ s/(-ttfdir=)(.+)/$2/;
		if(!(-e $ttfdir))
		{
			print "TrueType font directry not found!\n";
			exit;
		}
		$ttf_folder=$ttfdir;
	}
	elsif($arg =~ /-ttf=/)
	{
		$ttfname=$arg;
		$ttfname=~ s/(-ttf=)(.+)/$2/;
		$ttfbase=$ttfname;
		$ttfbase=~ s/(.*)(.[tT][tT][fFcC])/$1/;
		if("$ttfname" eq "$ttfbase")
		{
			$ttfext=".ttf";
			$ttfname=$ttfbase.$ttfext;
		}
	}
	if($arg =~ /-encoding=/) 
	{
		$encoding=$arg;
		$encoding =~ s/(-encoding=)(.+)/$2/;
		if($encoding eq "GBK")
		{
		}
		elsif($encoding eq "UTF8")
		{
			$pre="uni";
			$switches="-GFAE -l plane+0x";
			$range=$range2="0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f";
			$Uenc="Unicode";
			$set_dim=$set2_dim=16;
			$fdpre="C70";
			$CJKnormal="\\CJKnormal";
			$fddir="UTF8";
		}
		elsif($encoding eq "Big5")
		{
			$pre="b5";
			$switches="-GFAe -L cubig5.map+";
			$range="0,1,2,3,4,5";
			$range2="0,1,2,3,4,5,6,7,8,9";
			$Uenc="UBig5";
			$set_dim=6;
			$set2_dim=10;
			$fdpre="C00";
			$fddir="Bg5";
		}
		else
		{
			print "Font encoding $encoding not supported.\n";
			exit;
		}
	}
	elsif($arg =~ /-prefix=/)
	{
		$pre=$arg;	
		$pre =~ s/(-prefix=)(.+)/$2/;
	}
	elsif($arg =~ /-stemv=/)
	{
		$vs=$arg;	
		$vs =~ s/(-stemv=)([0-9]+)/$2/;
		$vstem="-v $vs";
	}
	elsif($arg =~ /-CJKname=/)
	{
		$familyname=$arg;	
		$familyname =~ s/(-CJKname=)(.+)/$2/;
	}
	elsif($arg =~ /-psname=/)
	{
		$psname=$arg;	
		$psname =~ s/(-psname=)(.+)/$2/;
	}
	elsif($arg =~ /-cjkmap=/)
	{
		$cjkmapbase=$arg;	
		$cjkmapbase =~ s/(-cjkmap=)(.+)/$2/;
	}
	elsif($arg =~ /-destdir=/)
	{
		$destdir=$arg;	
		$destdir =~ s/(-destdir=)(.+)/$2/;
	}
	elsif($arg eq "-Type1")
	{
		$pfb=1;	
	}
	elsif($arg eq "-updmap")
	{
		$updmap=1;	
	}
	elsif(($arg eq "--version")||($arg eq "-v"))
	{
		version();
		exit;
	}
	elsif(($arg eq "--help")||($arg eq "-h"))
	{
		usage();
		exit;
	}
	elsif($arg !~ /=/) 
	{
		print "Unrecognized option: $arg. Type FontsGen -h for usage information.\n";
		exit;
	}
	elsif($arg =~ /=/)
	{
		$testarg = $arg;
		$testarg =~ s/(.*)(=.*)/$1/;
		if(!(($testarg eq "-ttf") || ($testarg eq "-ttfdir") || ($testarg eq "-encoding") || ($testarg eq "-prefix") || ($testarg eq "-CJKname") || ($testarg eq "-destdir")|| ($testarg eq "-psname")))
		{
			print "Unrecognized option: $arg. Type FontsGen -h for usage information.\n";
			exit;
		}
	}
}

if(!$ttfname)
{
	print "No TrueType font specified!\n";
	exit;
}
elsif(!$familyname)
{
	print "No CJKfamily name specified!\n";
	exit;
}
elsif(!(-e "$ttf_folder\\$ttfname"))
{
	print "TrueType font file $ttfname not found!\n";
	exit
}
	
if($pfb)
{
	$extra_run="for %%i in ($range) do (\n  for %%j in ($range2) do (\n    if exist $pre$familyname%%i%%j.enc ttf2pt1 -W0 -b $switches%%i%%j  %ttfile% $pre$familyname%%i%%j\n))";
	$md_afm="if not exist $destdir\\fonts\\afm\\Chinese\\$pre$familyname mkdir $destdir\\fonts\\afm\\Chinese\\$pre$familyname";
	$md_type1="if not exist $destdir\\fonts\\type1\\Chinese\\$pre$familyname mkdir $destdir\\fonts\\type1\\Chinese\\$pre$familyname";
	$mv_afm="move *.afm $destdir\\fonts\\afm\\Chinese\\$pre$familyname\\";
	$mv_type1="move *.pfb $destdir\\fonts\\type1\\Chinese\\$pre$familyname\\"
}

@genfonts=(
	"\@echo off\n",
	"set ttfile=$ttfdir\\$ttfname\n",
	"if not exist $destdir\\fonts\\enc\\Chinese\\$pre$familyname mkdir $destdir\\fonts\\enc\\Chinese\\$pre$familyname\n",
	"if not exist $destdir\\fonts\\tfm\\Chinese\\$pre$familyname mkdir $destdir\\fonts\\tfm\\Chinese\\$pre$familyname\n",
	"if not exist $destdir\\ttf2tfm\\base mkdir $destdir\\ttf2tfm\\base\n",
	"if not exist $destdir\\dvipdfm\\config mkdir $destdir\\dvipdfm\\config\n",
	"$md_afm\n",
	"$md_type1\n\n",
	"ttf2tfm $ttfdir\\$ttfname -w $pre$familyname\@$Uenc\@.tfm\n",
	"ttf2tfm $ttfdir\\$ttfname -s 0.167 $pre$familyname$slant\@$Uenc\@.tfm\n",
	"move *.tfm $destdir\\fonts\\tfm\\Chinese\\$pre$familyname\n\n",
	"$extra_run\n",
	"move *.enc $destdir\\fonts\\enc\\Chinese\\$pre$familyname\\\n",
	"$mv_afm\n",
	"$mv_type1\n"
);
open(F, ">genfonts.bat");
	print F @genfonts;
close(F);

$exec=`genfonts.bat`;
unlink "genfonts.bat";

open(F, "<$destdir\\dvipdfm\\config\\cid-x.map");
@cid_content=<F>;
close(F);
foreach $fileline (@cid_content)
{
	chop($fileline);
	if($fileline =~ /$pre$familyname/)
	{
		$exitcode=1;
	}
}
undef @cid_content;
if($exitcode)
{
	exit;
}

open(F, ">>$destdir\\dvipdfm\\config\\cid-x.map");
print F "$pre$familyname\@$Uenc\@ unicode :0:$ttfname $vstem\n";
print F "$pre$familyname$slant\@$Uenc\@ unicode :0:$ttfname -s .167 $vstem\n\n";
close(F);

open(F, ">>$destdir\\ttf2tfm\\base\\ttfonts.map");
print F "$pre$familyname\@$Uenc\@  $ttfname Pid = 3 Eid = 1\n";
print F "$pre$familyname$slant\@$Uenc\@  $ttfname Slant=0.167 Pid = 3 Eid = 1\n\n";
close(F);

if(!(-e "$destdir\\fonts\\map"))
{
	mkdir "$destdir\\fonts\\map";
}

$ttfsuffix="-ttf";
open(FF, ">> $destdir\\fonts\\map\\$cjkmapbase-$familyname$ttfsuffix.map");

@set=("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");
for ($i=0;$i<$set_dim;$i=$i+1)
{
	for ($j=0;$j<$set2_dim;$j=$j+1)
	{
		if (-e "$destdir\\fonts\\enc\\Chinese\\$pre$familyname\\$pre$familyname@set[$i]@set[$j].enc")
		{
			print FF "$pre$familyname@set[$i]@set[$j] < $pre$familyname@set[$i]@set[$j].enc < $ttfname\n";
			print FF "$pre$familyname$slant@set[$i]@set[$j] < $pre$familyname@set[$i]@set[$j].enc < $ttfname\n";
		}
	}	
}			
print FF "\n";
close(FF);
if($pfb)
{
	get_psname: for ($i=0;$i<$set_dim;$i=$i+1)
	{
		for ($j=0;$j<$set2_dim;$j=$j+1)
		{
			if (-e "$destdir\\fonts\\type1\\Chinese\\$pre$familyname\\$pre$familyname@set[i]@set[j].pfb") {
				open(F, "<$destdir\\fonts\\type1\\Chinese\\$pre$familyname\\$pre$familyname@set[i]@set[j].pfb");
				@pfb=<F>;
				close(F);
				@pfb=grep(/\/FontName.*def/, @pfb);
				$psname = @pfb[1];
				$psname =~ s/\/FontName \/(.+)-.+ def/$1/;
				last get_psname;
			}
		}
	}
	open(GG, ">> $destdir\\fonts\\map\\$cjkmapbase-$familyname.map");
	for ($i=0;$i<$set_dim;$i=$i+1)
	{
		for ($j=0;$j<$set2_dim;$j=$j+1)
		{
			if (-e "$destdir\\fonts\\enc\\Chinese\\$pre$familyname\\$pre$familyname@set[$i]@set[$j].enc")
			{
				print FF "$pre$familyname@set[$i]@set[$j] < $pre$familyname@set[$i]@set[$j].enc < $ttfname\n";
				print FF "$pre$familyname$slant@set[$i]@set[$j] < $pre$familyname@set[$i]@set[$j].enc < $ttfname\n";
				if($pfb)
				{
					print GG "$pre$familyname@set[$i]@set[$j]  $psname-@set[$i]@set[$j] < $pre$familyname@set[$i]@set[$j].pfb\n";
					print GG "$pre$familyname$slant@set[$i]@set[$j]  $psname-@set[$i]@set[$j] \" .167 SlantFont \" < $pre$familyname@set[$i]@set[$j].pfb\n";
				}
			}
		}	
	}			
	print GG "\n";
	close(GG);
}

@genfd=(
"% This is the file $fdpre$familyname.fd of the CJK package\n",
"%   for using Asian logographs (Chinese\/Japanese\/Korean) with LaTeX2e\n",
"%\n",
"% created by Werner Lemberg <wl\@gnu.org>\n",
"% automatically generated by FontsGen $version\n",
"\n",
"\\def\\fileversion{4.8.0}\n",
"\\def\\filedate{2008/05/22}\n",
"\\ProvidesFile{$fdpre$familyname.fd}[\\filedate\\space\\fileversion]\n",
"\n",
"% Chinese characters\n",
"%\n",
"% character set: $encoding\n",
"% font encoding: CJK ($encoding)\n",
"\n",
"\\DeclareFontFamily{$fdpre}{$familyname}{\\hyphenchar \\font\\m\@ne}\n",
"\n",
"\\DeclareFontShape{$fdpre}{$familyname}{m}{n}{<-> CJK * $pre$familyname}{$CJKnormal}\n",
"\\DeclareFontShape{$fdpre}{$familyname}{bx}{n}{<-> CJKb * $pre$familyname}{\\CJKbold}\n",
"\\DeclareFontShape{$fdpre}{$familyname}{m}{it}{<-> CJK * $pre$familyname$slant}{$CJKnormal}\n",
"\\DeclareFontShape{$fdpre}{$familyname}{bx}{it}{<-> CJKb * $pre$familyname$slant}{\\CJKbold}\n",
"\\DeclareFontShape{$fdpre}{$familyname}{m}{sl}{<-> CJK * $pre$familyname$slant}{$CJKnormal}\n",
"\\DeclareFontShape{$fdpre}{$familyname}{bx}{sl}{<-> CJKb * $pre$familyname$slant}{\\CJKbold}\n",
"\n",
"\\endinput\n"
);

if(!(-e "$destdir\\tex\\latex\\CJK\\$fddir"))
{
	system("mkdir", "$destdir\\tex\\latex\\CJK\\$fddir");
}
open(FD, "> $destdir\\tex\\latex\\CJK\\$fddir\\$fdpre$familyname.fd");
	print FD @genfd;
close(FD);

if($updmap)
{
	if(!(-e "$destdir\\web2c"))
	{
		system("mkdir", "$destdir\\web2c");
	}
	open(F, ">> $destdir\\web2c\\updmap.cfg");
	if($pfb)
	{
		print F "Map $cjkmapbase.map\n";
	}
	else
	{
		print F "MixedMap $cjkmapbase$ttfsuffix.map\n";
	}
	close(F);
}
