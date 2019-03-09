#!/usr/bin/perl -w
use strict;
use Image::Magick;
no warnings 'recursion';

my $MAXX      = 20;
my $MAXY      = 20;
# ----------------------------
$MAXX         = $MAXX * 2 + 1;
$MAXY         = $MAXY * 2 + 1;
my $WALL      = "#";
my $EMPTY     = " ";
my $UNVISITED = "u";

my $arefTmp = [];

my $animation = Image::Magick->new();

# Generate an empty maze
sub initMaze() {
  foreach my $iX (1 .. $MAXX) {
    $arefTmp->[$iX] = [];
    foreach my $iY (1 .. $MAXY) {
      $arefTmp->[$iX][$iY] = (($iX % 2 == 0 && $iY % 2 == 0) ? $UNVISITED : $WALL);
    }
  }
}

# Just find the unvisited neighbour cells
sub findNieghbours{
  my ($iX, $iY) = @_;
  
  my @aTmp;
  push (@aTmp, {x => $iX - 2, y => $iY})     if ($iX - 2 > 1     && $arefTmp->[$iX - 2][$iY] eq $UNVISITED);
  push (@aTmp, {x => $iX,     y => $iY - 2}) if ($iY - 2 > 1     && $arefTmp->[$iX][$iY - 2] eq $UNVISITED);
  push (@aTmp, {x => $iX + 2, y => $iY})     if ($iX + 2 < $MAXX && $arefTmp->[$iX + 2][$iY] eq $UNVISITED);
  push (@aTmp, {x => $iX,     y => $iY + 2}) if ($iY + 2 < $MAXY && $arefTmp->[$iX][$iY + 2] eq $UNVISITED);
  
  return @aTmp;
}

# Main loop (recursive)
sub iterateMaze {
  my ($iX, $iY) = @_;

  $arefTmp->[$iX][$iY] = $EMPTY;
  my @aNeigbours = findNieghbours($iX, $iY);
  while ( @aNeigbours ) {
    my $hrefDest = splice(@aNeigbours, int(rand(@aNeigbours)), 1);
    if ($arefTmp->[$hrefDest->{x}][$hrefDest->{y}] eq $UNVISITED) {
      $arefTmp->[($hrefDest->{x}+$iX)/2][($hrefDest->{y}+$iY)/2] = $EMPTY;
      addAnimationFrame();
      iterateMaze($hrefDest->{x}, $hrefDest->{y});
    }
  }
}

sub addAnimationFrame {
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
  push @$animation, $image;
}

initMaze();
iterateMaze(2, 2);
addAnimationFrame();

$animation->[0]->Coalesce();
$animation->Set(delay => 5);
$animation->Scale( width => $MAXX * 10, height => $MAXY * 10 );
$animation->Write( "maze2_anim.gif" );