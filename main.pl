# push(@INC, "/home/astropeak/Dropbox/project/aspk-code-base/perl");
use Aspk::HtmlElement;
use ConvertInput qw(build_element_tree);
use Aspk::debug qw(printHash);

sub _divide_element_horizonally{
    my ($element, $len) =@_;
    foreach (@{$len}) {
        my $e = Aspk::HtmlElement->new({tag=>"div", parent=>$element});
        $e->style(height,$_);
        $e->style(width,"100%");
    }

    return $element->prop(children);
}

sub _divide_element_vertically{
    my ($element, $len) =@_;
    my $left=0;
    foreach (@{$len}) {
        my $e = Aspk::HtmlElement->new({tag=>"div", parent=>$element});
        # $e->style(height,"100%");
        # $e->style(width,$_);
        # $e->style(display, "inline-block");
        $e  ->style(position, "absolute")
            ->style(top,0)
            ->style(bottom,0)
            ->style(left,$left)
            ->style(width,$_);

        $left+=$_;
    }

    return $element->prop(children);
}


sub divide_element {
    my ($element, $oritation, $len) =@_;
    print "Enter divide $oritation\n";
    printHash($len);

    if ($oritation eq "horizonally") {
        return _divide_element_horizonally($element, $len);
    } else {
        return _divide_element_vertically($element, $len);
    }
}



sub aaaaa{
    my ($element, $input_tree)= @_;

    print "Enter aaaaa. element:\n";
    printHash($element);
    print "input_tree:\n";
    printHash($input_tree);

    my $children = $input_tree->prop(children);
    print "length of children: ".scalar(@{$children})."\n";

    $element->html_prop(id, $input_tree->prop(data)->{id});

    if (scalar(@{$children})>0) {
        print "here\n";
        my @width = map {$_->prop(data)->{width}} @{$children};
        my @height = map {$_->prop(data)->{height}} @{$children};

        if ($width[0] == $input_tree->prop(data)->{width}) {
            divide_element($element, "horizonally", \@height);
        } else {
            @width = map {$_ - 0} @width;
            divide_element($element, "vertically", \@width);
        }

        my $total = scalar(@{$children});
        for(my $i=0; $i<$total; $i++) {
            print "i: $i, total: $total\n";
            aaaaa($element->prop(children)->[$i], $children->[$i]);
        }
    } else {
        print "in else\n";
    }
    print "Exit aaaaa\n";
}







my $h = Aspk::HtmlElement->new({tag=>"html"});
my $b = Aspk::HtmlElement->new({tag=>"body", parent=>$h});

my $e=Aspk::HtmlElement->new({tag=>"div", prop=>{id=>"wrapper"}, parent=>$b});
# $e->print();


# print "\nDivide the element:\n";
# # divide_element($e, "vertically", ["30%", "60%", "10%"]);
# divide_element($e, "horizonally", ["30%", "50%", "10%"]);
# # $e->print();

# my $tc=Aspk::HtmlElement->new({tag=>"text", prop=>{content=>"I am a connect"}, parent=>$e->prop(children)->[0]});
my $tc=Aspk::HtmlElement->new({tag=>"text", prop=>{content=>"I am a connect"}});
# # $e->prop(children)->[0]->add_child($tc);

# divide_element($e->prop(children)->[1], "vertically", ["30%", "40%"]);

# print "\nHtml:\n";



my $width=600;
my $height=400;
$e->style("height", $height);
$e->style("width", $width);
my $input_tree = build_element_tree("./input", $width, $height);
aaaaa($e, $input_tree);
# print "herer after aaaaa\n";
# printHash($e);




$h->traverse({prefunc=> sub
              {
                  my $para=shift;
                  my $e = $para->{node};
                  $e  ->style("border", "solid 1px grey")
                      # ->style('box-sizing', "border-box")
                      ->style('padding', 0)
                      ->style('margin-left',"-0px")
                      ->style('vertical-align',"top")
                      ->style('overflow','hidden')
                      ->style('border-collapse','collapse')
                      # ->style('position','relative')
                      # ->style('font-size',0)
                      if ($e->prop(tag) eq 'div');

                  $e->add_child($tc) if ($e->prop(tag) eq 'div') && (scalar(@{($e->prop(children))}) == 0) && ($e->style(width) >= 100) && ($e->style(width) ne "100%");

                  $e->style('position','relative') if ($e->style('position') ne 'absolute');
              }});


$rst = $h->format();
# print "RST:\n\n$rst";
open my $fh, ">", "output.html" or die "Can't open file ";
print $fh $rst;