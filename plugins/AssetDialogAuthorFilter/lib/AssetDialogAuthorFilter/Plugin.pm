package AssetDialogAuthorFilter::Plugin;
use strict;

sub _dialog_list_asset {
    my ($cb, $app, $terms, $args, $param, $hasher) = @_;
    $terms->{created_by} = $app->user->id if ($app->user->id);
}


1;
