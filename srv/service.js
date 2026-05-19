const cds = require('@sap/cds');
const { Books } = require('#cds-models/BookstoreService');

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

    this.before(['READ'], Books, async (req) => {
      console.log('Before READ Books');
    });

    this.after('READ', Books, async (books, req) => {
      for (const book of books) {
        if (book.genre_code === 'Art') {
          book.price *= 0.8;
        }
      }
    });

    return super.init();
  }
};
