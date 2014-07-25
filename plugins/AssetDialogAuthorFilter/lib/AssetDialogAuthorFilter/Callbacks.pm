package AssetDialogAuthorFilter::Callbacks;
use strict;

sub _param_asset_list {
    my ($cb, $app, $param, $tmpl) = @_;
    my $author_name = $param->{author_name}
        or return;
    my @_object_loop;
    foreach my $asset (@{$param->{object_loop}}) {
        if ($asset->{created_by} eq $author_name) {
            push(@_object_loop, $asset);
        }
    }
    $param->{object_loop} = \@_object_loop;
}

1;