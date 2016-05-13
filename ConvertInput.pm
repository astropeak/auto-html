# Convert input to a tree representation for internal use.
#
# How to run:
# perl convert-input.pl input
package ConvertInput;
use Aspk::Tree;
use Aspk::debug qw(printHash);

use Exporter;

@ISA=qw(Exporter);
@EXPORT_OK=qw(build_element_tree);

sub get_input {
    my ($file) = @_;
    open my $fh, '<', $file or die "Can' open file $file";

    my @all_input_lines = <$fh>;
    my $regexp_tag = qr/(?:[rc][0-9]{1,10}){1,100}/;
    my @grid= grep {/^[ \t]*$regexp_tag[ \t\r\n]*$/} @all_input_lines;
    # printHash(\@grid);

    # my @property_info = grep {/^[ \t]*$regexp_tag\.([a-z]+)[ \t]+([^\r\n]*)[ \t\r\n]*$/} @all_input_lines;
    my @property= grep {/^[ \t]*$regexp_tag\.([a-z]+)/} @all_input_lines;
    @property= map {/^[ \t]*($regexp_tag)\.([a-z]+)[ \t]+([^\r\n]*)[ \t\r\n]*$/;
                          {tag=>$1, name=>$2, value=>eval $3}} @property;
    # printHash(\@property);
    my %ppp;
    foreach (@property){
        $ppp{$_->{tag}}->{$_->{name}} = $_->{value};
    }

    return {grid=>\@grid, property=>\%ppp};
}

sub build_element_tree{
    my ($file, $width, $height) = @_;
    my $input = get_input($file);
    printHash($input);

    my $t = createGridTree($input->{grid}, $width, $height);
    calculateWidthAndHeight({node=>$t});

    return $t;
}

sub createGridTree{
    my ($grid_info, $width, $height) = @_;

    # printHash(\@g);
    # chomp @g;
    # print @g;
    # print "\nTTTT:\n";

    my $rn = Aspk::Tree->new({data=>{id=>"root",width=>$width,height=>$height}});
    my %elements=();
    foreach my $i (@{$grid_info}){
        # chomp $i;
        # print;
        # $i =~ s/\n$//;

        $i =~ m/(.*)([rc][0-9]{1,10})[ \n]*/; ## After matched, seems $i will be corrupted.
        my ($parent, $child)=($1,$2);
        $i=$parent.$child;
        my $parentNode;
        if ($parent eq ""){
            $parentNode=$rn;
        } else {
            die "Parent node not exist for element $i." if (!exists($elements{$parent}));
            $parentNode=$elements{$parent};
        }
        # print "i: $i, parent: $parent, child: $child \n";
        $elements{$i} = Aspk::Tree->new({data=>{id=>$i},
                                         parent=>$parentNode});

    }
    # foreach my $j (keys(%elements)){
    # print "CCC: key: $j, value: $elements{$j}->{data}->{id}. DDD. \n";
    # }
    return $rn;
}


sub calculateWidthAndHeight{
    my $para=shift;
    my $node =$para->{node};
    # my $data=Tree::getData($node);
    my $data=$node->prop(data);
    # if (exists($data->{width}) && exists($data->{height}) ){
    # }
    # my $children=Tree::getChilderen($node);
    my $children=$node->prop(children);
    if (@{$children}>0) {
        # if (Tree::getData(@{$children}[0])->{id} =~ m/.*c[0-9]{1,10}$/) {
        if (@{$children}[0]->prop(data)->{id} =~ m/.*c[0-9]{1,10}$/) {
            # node is column
            my $i;
            my $w;
            foreach my $c (@{$children}){
                # my $d=Tree::getData($c);
                my $d=$c->prop(data);
                if (!exists($d->{width})){
                    ++$i;
                }else {
                    $w+=$d->{width};
                }
            }

            foreach my $c (@{$children}){
                # if (!exists((Tree::getData($c))->{width})){
                if (!exists($c->prop(data)->{width})){
                    die "Parent width not given: $data->{id}." if (!exists($data->{width}));
                    # (Tree::getData($c))->{width} = ($data->{width}-$w)/$i;
                    $c->prop(data)->{width} = ($data->{width}-$w)/$i;
                }

                # if (!exists((Tree::getData($c))->{height})){
                if (!exists($c->prop(data)->{height})){
                    # (Tree::getData($c))->{height} = $data->{height};
                    $c->prop(data)->{height} = $data->{height};
                }

            }
        } else {
            # parent is row
            my $i;
            my $h;
            foreach my $c (@{$children}){
                # my $d=Tree::getData($c);
                my $d=$c->prop(data);
                if (!exists($d->{height})){
                    ++$i;
                }else {
                    $h+=($d->{height});
                }
            }
            # $h=0;
            foreach my $c (@{$children}){
                # if (!exists((Tree::getData($c))->{height})){
                if (!exists($c->prop(data)->{height})){
                    die "Parent height not given: $data->{id}." if (!exists($data->{height}));
                    my $a= ($data->{height}-$h)/$i;
                    # (Tree::getData($c))->{height} = ($data->{height}-$h)/$i;
                    $c->prop(data)->{height} = ($data->{height}-$h)/$i;
                }
                # if (!exists((Tree::getData($c))->{width})){
                if (!exists($c->prop(data)->{width})){
                    # (Tree::getData($c))->{width} = $data->{width};
                    $c->prop(data)->{width} = $data->{width};
                }
            }
        }

        foreach my $n (@{$children}){
            calculateWidthAndHeight({node=>$n});
        }
    }
}
