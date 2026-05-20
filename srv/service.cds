using {tutorial.db as db} from '../db/schema';

service BookstoreService {

    // Security
    @(restrict: [
        {
            grant: ['*'],
            to   : 'Admin'
        },
        {
            grant: ['READ'],
            to   : 'authenticated-user'
        }
    ])
    entity Books      as
        projection on db.Books {
            * // Project all data
        }

        // excluding {
        //     createdAt,
        //     createdBy,
        //     modifiedAt,
        //     modifiedBy
        // }
        // Bound actions linked to the entity Books
        actions {

            // Updates the ui when stock in changed
            @Common.SideEffects: {TargetProperties: ['stock']}
            action addStock();

            // Change publish date
            action changePublishDate(newDate: Date);

            // Change status oppening a pop-up with automatic Dropdown (ValueHelp)
            @Common.SideEffects: {TargetProperties: ['status_code']}
            action changeStatus(
                                @(Common: {
                                    Label                   : 'New Status',
                                    ValueListWithFixedValues: true,
                                    ValueList               : {
                                        $Type         : 'Common.ValueListType',
                                        CollectionPath: 'BookStatus',
                                        Parameters    : [{
                                            $Type            : 'Common.ValueListParameterInOut',
                                            LocalDataProperty: newStatus,
                                            ValueListProperty: 'code'
                                        }]
                                    }
                                })
                                newStatus: String);
        };

    // Ação Não Vinculada (Unbound Action) - Global para todo o serviço
    // Unbound action (global)
    // Updates the ui when discount in applied
    @Common.SideEffects: {TargetEntities: ['/BookstoreService.EntityContainer/Books']}
    action addDiscount();

    // Table projections
    entity Authors    as projection on db.Authors;
    entity Chapters   as projection on db.Chapters;
    entity BookStatus as projection on db.BookStatus;

    // View helper for genres used in the dropdowns of the interface
    entity GenresVH   as projection on db.Genres;
}

// Activate draft for Books entity
annotate BookstoreService.Books with @odata.draft.enabled;
