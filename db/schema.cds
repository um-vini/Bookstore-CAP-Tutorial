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
    stock       : Integer;
    status      : Association to BookStatus;
    // Composition from books to chapters
    Chapters    : Composition of many Chapters
                      on Chapters.book = $self;
}

entity BookStatus {
    key code        : BookStatusCode;
        criticality : Integer;
        displayText : String;
}

type BookStatusCode : String(1) enum {
    Available = 'A';
    Low_Stock = 'L';
    Unavailable = 'U';
}

entity Authors : cuid, managed {
    name  : String;
    books : Association to many Books
                on books.author = $self;

}

entity Chapters : cuid, managed {
        // Association from chapters to books
    key book   : Association to Books;
        number : Integer;
        title  : String;
        pages  : Integer;
}
