package AssetDialogAuthorFilter::Plugin;
use strict;

use MT::CMS::Asset;

# version 6.0.3
sub _dialog_list_asset {
    my $app = shift;

    my $blog_id = $app->param('blog_id');
    my $mode_userpic = $app->param('upload_mode') || '';
    return $app->return_to_dashboard( redirect => 1 )
        if !$blog_id && $mode_userpic ne 'upload_userpic';

    my $blog_class = $app->model('blog');
    my $blog;
    $blog = $blog_class->load($blog_id) if $blog_id;

    if (   $app->param('edit_field')
        && $app->param('edit_field') =~ m/^customfield_.*$/ )
    {
        return $app->permission_denied()
            unless $app->permissions;
    }
    else {
        return $app->permission_denied()
            if $blog_id && !$app->can_do('access_to_insert_asset_list');
    }

    my $asset_class = $app->model('asset') or return;
    my %terms;
    my %args = ( sort => 'created_on', direction => 'descend' );

    my $class_filter;
    my $filter = ( $app->param('filter') || '' );
    if ( $filter eq 'class' ) {
        $class_filter = $app->param('filter_val');
    }
    elsif ( $filter eq 'userpic' ) {
        $class_filter      = 'image';
        $terms{created_by} = $app->param('filter_val');
        $terms{blog_id}    = 0;

        my $tag = MT::Tag->load( { name => '@userpic' },
            { binary => { name => 1 } } );
        if ($tag) {
            require MT::ObjectTag;
            $args{'join'} = MT::ObjectTag->join_on(
                'object_id',
                {   tag_id            => $tag->id,
                    object_datasource => MT::Asset->datasource
                },
                { unique => 1 }
            );
        }
    }

    $app->add_breadcrumb( $app->translate("Files") );

    if ($blog_id) {
        my $blog_ids = $app->_load_child_blog_ids($blog_id);
        push @$blog_ids, $blog_id;
        $terms{blog_id} = $blog_ids;
    }

    my $hasher = MT::CMS::Asset::build_asset_hasher(
        $app,
        PreviewWidth  => 120,
        PreviewHeight => 120
    );

    if ($class_filter) {
        my $asset_pkg = MT::Asset->class_handler($class_filter);
        $terms{class} = $asset_pkg->type_list;
    }
    else {
        $terms{class} = '*';    # all classes
    }

    # identifier => name
    my $classes = MT::Asset->class_labels;
    my @class_loop;
    foreach my $class ( keys %$classes ) {
        next if $class eq 'asset';
        push @class_loop,
            {
            class_id    => $class,
            class_label => $classes->{$class},
            };
    }

    # Now, sort it
    @class_loop
        = sort { $a->{class_label} cmp $b->{class_label} } @class_loop;

    my $dialog    = $app->param('dialog')    ? 1 : 0;
    my $no_insert = $app->param('no_insert') ? 1 : 0;
    my %carry_params = map { $_ => $app->param($_) || '' }
        (qw( edit_field upload_mode require_type next_mode asset_select ));
    $carry_params{'user_id'} = $app->param('filter_val')
        if $filter eq 'userpic';
    MT::CMS::Asset::_set_start_upload_params( $app, \%carry_params )
        if $app->can_do('upload');
    my ( $ext_from, $ext_to )
        = ( $app->param('ext_from'), $app->param('ext_to') );

    # Check directory for thumbnail image
    MT::CMS::Asset::_check_thumbnail_dir( $app, \%carry_params );

    # Add created_by filter to terms (tinybeans) [start]
    $terms{created_by} = $app->user->id if ($app->user->id);
    # Add created_by filter to terms (tinybeans) [ end ]
    $app->listing(
        {   terms    => \%terms,
            args     => \%args,
            type     => 'asset',
            code     => $hasher,
            template => 'dialog/asset_list.tmpl',
            params   => {
                (   $blog
                    ? ( blog_id      => $blog_id,
                        blog_name    => $blog->name || '',
                        edit_blog_id => $blog_id,
                        ( $blog->is_blog ? ( blog_view => 1 ) : () ),
                        )
                    : (),
                ),
                is_image => defined $class_filter
                    && $class_filter eq 'image' ? 1 : 0,
                dialog_view      => 1,
                dialog           => $dialog,
                no_insert        => $no_insert,
                search_label     => MT::Asset->class_label_plural,
                search_type      => 'asset',
                class_loop       => \@class_loop,
                can_delete_files => $app->can_do('delete_asset_file') ? 1 : 0,
                nav_assets       => 1,
                panel_searchable => 1,
                saved_deleted    => $app->param('saved_deleted') ? 1 : 0,
                object_type      => 'asset',
                (     ( $ext_from && $ext_to )
                    ? ( ext_from => $ext_from, ext_to => $ext_to )
                    : ()
                ),
                %carry_params,
            },
        }
    );
}


1;