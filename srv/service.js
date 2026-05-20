const cds = require('@sap/cds');
const { Books, Authors } = require('#cds-models/BookstoreService');

module.exports = class BookstoreService extends cds.ApplicationService {
  init() {
    //Unbound actions
    this.on('addDiscount', async () => {
      await UPDATE(Books).set({
        price: {
          func: 'ROUND',
          args: [{ xpr: [{ ref: ['price'] }, '*', { val: 0.9 }] }, { val: 2 }],
        },
      });
    });

    //Bound actions
    this.on('addStock', Books, async (req) => {
      const bookId = req.params[0].ID;

      await UPDATE(Books)
        .set({ stock: { '+=': 1 } })
        .where({ ID: bookId });
    });

    this.on('changePublishDate', Books, async (req) => {
      const bookId = req.params[0].ID;
      const newDate = req.data.newDate;

      await UPDATE(Books).set({ publishedAt: newDate }).where({ ID: bookId });
    });

    this.on('changeStatus', Books, async (req) => {
      const bookId = req.params[0].ID;
      const newStatus = req.data.newStatus;

      await UPDATE(Books).set({ status_code: newStatus }).where({ ID: bookId });
    });

    this.before(['CREATE', 'UPDATE'], Books, async (req) => {
      const book = req.data;

      if (book.price !== undefined && book.price <= 0) {
        req.error(400, 'Price needs to be more than 0!');
      }
    });

    this.after('READ', Books, async (books, req) => {
      for (const book of books) {
        if (book.genre_code === 'Art') {
          book.price *= 0.8;
        }
      }
    });

    //Virtual fields always afeter the after handlers
    this.after('READ', Books, async (books, req) => {
      const author = books[0].author?.ID;
      
      if (!author) {
        return;
      }

      const bookCounts = await SELECT.from(Books)
        .columns('author_ID', { func: 'count' })
        .where({ author_ID: author })
        .groupBy('author_ID');

      const booksTotal = bookCounts.length > 0 ? bookCounts[0].count : 0;

      for (const book of books) {
        if (book.author && book.author.ID === author) {
          book.author.bookCount = booksTotal;
        }
      }
    });

    return super.init();
  }
};
