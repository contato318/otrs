// --
// Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the admin overview module.
 */
Core.Agent.Admin = (function (TargetNS) {
    /**
     * @name Init
     * @memberof Core.Agent.Admin
     * @function
     * @description
     *      Initializes Overview screen.
     */
    TargetNS.Init = function () {

        var Favourites = Core.Config.Get('Favourites');

        window.setTimeout(function() {
            $('.SidebarColumn #Filter').focus();
        }, 100);

        $('.AddAsFavourite').off('click.AddAsFavourite').on('click.AddAsFavourite', function(Event) {

            var $TriggerObj = $(this),
                Module = $(this).data('module');

            if ($TriggerObj.hasClass('Clicked')) {
                return false;
            }

            Event.stopPropagation();
            $(this).addClass('Clicked');
            Favourites.push(Module);
            Core.Agent.PreferencesUpdate('AdminNavigationBarFavourites', JSON.stringify(Favourites), function() {

                var FavouriteHTML = '';

                $TriggerObj.addClass('Clicked');

                // also add the entry to the sidebar favourites list dynamically
                FavouriteHTML = Core.Template.Render('Agent/Admin/Favourite', {
                    'Link'  : $TriggerObj.closest('a').attr('href'),
                    'Name'  : $TriggerObj.closest('a').find('span.Title').clone().children().remove().end().text(),
                    'Module': Module
                });

                // Fade the original icon out and display a success icon
                $TriggerObj.find('i').fadeOut(function() {
                    $(this).closest('li').find('.AddAsFavourite').append('<i class="fa fa-check" style="display: none;"></i>').find('i.fa-check').fadeIn().delay(1000).fadeOut(function() {
                        $(this)
                            .closest('.AddAsFavourite')
                            .hide()
                            .find('i.fa-check')
                            .remove();
                        $('.ItemListGrid').find('[data-module="' + Module + '"]').addClass('IsFavourite');
                    });
                    $(this).hide();
                });

                $('.DataTable.Favourites').append($(FavouriteHTML));
                $('.DataTable.Favourites').show();

            });
            return false;
        });

        $('.DataTable.Favourites').on('click', '.RemoveFromFavourites', function() {

            var Module = $(this).data('module'),
                Index = Favourites.indexOf(Module),
                $TriggerObj = $(this),
                $ListItemObj = $('.ItemListGrid').find('[data-module="' + Module + '"]');

            if ($ListItemObj.hasClass('IsFavourite') && Index > -1) {
                Favourites.splice(Index, 1);
                Core.Agent.PreferencesUpdate('AdminNavigationBarFavourites', JSON.stringify(Favourites), function() {
                    $TriggerObj.closest('tr').fadeOut(function() {
                        var $TableObj = $(this).closest('table');
                        $(this).remove();
                        if (!$TableObj.find('tr').length) {
                            $TableObj.hide();
                        }

                        // also remove the corresponding class from the entry in the grid view and list view
                        $ListItemObj.removeClass('IsFavourite').removeClass('Clicked').show().find('i.fa-star-o').show();
                    });
                });
            }

            return false;
        });

        Core.UI.Table.InitTableFilter($('#Filter'), $('.Filterable'), undefined, true);
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin || {}));
