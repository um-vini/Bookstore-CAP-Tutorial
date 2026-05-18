using {
    cuid,
    managed,
} from '@sap/cds/common';

namespace tutorial.db;

entity Books : cuid, managed {
    title       : String;
    author      : Association to Authors;
    genre       : String;
    publishedAt : Date;
    pages       : Integer;
    price       : Decimal(10, 2);
    // Composition from books to chapters
    Chapters    : Composition of many Chapters
                      on Chapters.book = $self;
}

entity Authors : cuid, managed {
    name  : String;
    books : Association to many Books
                on books.author = $self;

}

entity Chapters : cuid, managed {
        number : Integer;
        // Association from chapters to books
    key book   : Association to Books;
}
