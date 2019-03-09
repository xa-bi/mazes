#!/usr/bin/perl -w
use strict;

my $SIZEX     = 20;
my $SIZEY     = 20;
# ----------------------------
my $MAXX      = $SIZEX * 2 + 1;
my $MAXY      = $SIZEY * 2 + 1;
my $WALL      = "#";
my $EMPTY     = " ";

my $arefTmp = [];

# Generate an empty maze (Just the borders)
sub initMaze {
  foreach my $iX (1 .. $MAXX) {
    $arefTmp->[$iX][1] = $WALL;
    $arefTmp->[$iX][$MAXY] = $WALL;
  }
  foreach my $iY (2 .. $MAXY-1) {
    $arefTmp->[1][$iY] = $WALL;
    foreach my $iX (2 .. $MAXX-1) {
      $arefTmp->[$iX][$iY] = $EMPTY;
    }
    $arefTmp->[$MAXX][$iY] = $WALL;
  }
}

sub divideVertical {
  my ($x1, $y1, $x2, $y2) = @_;
  
  my $xmiddle   = ($x2 + $x1) / 2;                               # Middle of the area  
  $xmiddle += 1 if ($xmiddle %2 == 0);
  my $iPosibles = ($y2 - $y1) / 2;                               # Posible doors
  my $iCut = $y1 -1 + (int(rand($iPosibles)) + 1) * 2;           # Get one random hole
  foreach my $iY ($y1+1 .. $y2-1) {                              # Draw vertical wall
    $arefTmp->[$xmiddle][$iY] = ($iY == $iCut ? $EMPTY : $WALL); # But the door
  }

  divideHorizontal($x1,      $y1, $xmiddle, $y2) if ($xmiddle - $x1 > 3);
  divideHorizontal($xmiddle, $y1, $x2,      $y2) if ($x2 - $xmiddle > 3);
}

sub divideHorizontal {
  my ($x1, $y1, $x2, $y2) = @_;
  
  my $ymiddle = ($y2 + $y1) / 2;                                 # Middle of the area  
  $ymiddle -= 1 if ($ymiddle %2 == 0);
  my $iPosibles = ($x2 - $x1) / 2;                               # Posible doors
  my $iCut = $x1 -1 + (int(rand($iPosibles)) + 1) * 2;           # Get one random hole
  foreach my $iX ($x1+1 .. $x2-1) {                              # Draw vertical wall
    $arefTmp->[$iX][$ymiddle] = ($iX == $iCut ? $EMPTY : $WALL); # But the door
  }

 divideVertical($x1, $y1,      $x2, $ymiddle) if ($ymiddle - $y1 > 3);
 divideVertical($x1, $ymiddle, $x2,      $y2) if ($y2 - $ymiddle > 3);
}

sub generateGifMaze {
  use Image::Magick;

  my $image = Image::Magick->new;
  $image->Set(size=>'' . $MAXX . 'x' . $MAXY . '');
  $image->ReadImage('xc:white');
  foreach my $iY (1 .. $MAXY) {
    foreach my $iX (1 .. $MAXX) {
      $image->Set('pixel[' . ($iX - 1) . ',' . ($iY - 1) . ']'=>'red') if ($arefTmp->[$iX][$iY] eq $WALL);
    }
  };
  $image->Set('pixel[1,0]'=>'green');
  $image->Set('pixel[' . ($MAXX - 2) . ',' . ($MAXY - 1) . ']'=>'green');
  $image->Write(filename=>"maze1.gif");
}

initMaze();
divideVertical(1, 1, $MAXX, $MAXY);
generateGifMaze();