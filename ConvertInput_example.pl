use ConvertInput qw(build_element_tree);
use Aspk::Debug;

my $t=build_element_tree("./input", 300, 100);
print "\nbuild_element_tree:\n";
dbgl($t);


# The two functions also works
# my $rn=ConvertInput::createGridTree("./input", 300, 100);
# print "\nAfter created:\n";
# dbgl($rn);

# ConvertInput::calculateWidthAndHeight({node=>$rn});
# print "\nAfter calculating:\n";
# dbgl($rn);
