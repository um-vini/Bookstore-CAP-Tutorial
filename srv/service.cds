using {tutorial.db as db} from '../db/schema';

service BookstoreService {
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
    entity Books      as projection on db.Books
                         // Bound actions
        actions {
            @(Common.SideEffects: {TargetProperties: ['stock']})
            action addStock();
            action changePublishDate(newDate: Date);
            @(Common.SideEffects: {TargetProperties: ['status_code']})
            action changeStatus( @(Common: {
                                     ValueListWithFixedValues: true,
                                     Label                   : 'New Status',
                                     ValueList               : {
                                         $Type         : 'Common.ValueListType',
                                         CollectionPath: 'BookStatus',
                                         Parameters    : [{
                                             $Type            : 'Common.ValueListParameterInOut',
                                             LocalDataProperty: newStatus,
                                             ValueListProperty: 'code',
                                         }, ],
                                     },
                                 }) newStatus: String);
        };

    // Unbound actions
    @(Common.SideEffects: {TargetEntities: ['/BookstoreService.EntityContainer/Books']})

    action addDiscount();

    entity Authors    as projection on db.Authors;
    entity Chapters   as projection on db.Chapters;
    entity BookStatus as projection on db.BookStatus;

    entity GenresVH   as projection on db.Genres;
}

// Can be annotated direcly in the annotations.cds file
annotate BookstoreService.Books with @odata.draft.enabled;
// annotate BookstoreService.Books with @requires: 'Admin';
