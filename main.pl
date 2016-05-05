# push(@INC, "/home/astropeak/Dropbox/project/aspk-code-base/perl");
use Aspk::HtmlElement;

sub add_child {
    my ($parent, $child, $pos) = @_;
}

sub _divide_element_vertically{
    my ($element, $len) =@_;
    foreach (@{$len}) {
        my $e = Aspk::HtmlElement->new({tag=>"div"});
        $e->style(height,$_);
        $e->style(width,"100%");
        $element->add_child($e);
    }

    # return $element->prop(children);
}

sub _divide_element_horizonally{
    my ($element, $len) =@_;
    foreach (@{$len}) {
        my $e = Aspk::HtmlElement->new({tag=>"div"});
        $e->style(height,"100%");
        $e->style(width,$_);
        $element->add_child($e);
    }

    # return $element->prop(children);
}


sub divide_element {
    my ($element, $oritation, $len) =@_;
    if ($oritation eq "horizonally") {
        return _divide_element_horizonally($element, $len);
    } else {
        return _divide_element_vertically($element, $len);
    }
}

my $e=Aspk::HtmlElement->new({tag=>"div", prop=>{id=>"wrapper"}});
$e->style("height", "100px");
$e->print();

print "\nDivide the element:\n";
divide_element($e, "vertically", ["30%", "60%", "10%"]);
$e->print();
