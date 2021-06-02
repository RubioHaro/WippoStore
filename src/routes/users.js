var express = require('express');
var router = express.Router();

const pool = require('../db');

/* GET users listing. BUYER USER */
router.get('/principalUU', (req, res) => { /*UNREGISTERED USER*/
    res.render('principalUU', { message: req.flash('message') });
});

router.get('/principalC', async(req, res) => {
    const products = await pool.query('SELECT * FROM producto');
    console.log(products);
    res.render('userC/principalC', { products });
});

router.get('/profileC', (req, res) => {
    address_list = [
        { id: 0, name: "Casa", street: "Mar meditarraneo", number: "48", distrit: "Gustavo A. Madero", city: "Ciudad de Mexico", cp: 554001 },
        { id: 1, name: "Oficina", street: "Mar meditarraneo", number: "50", distrit: "Gustavo A. Madero", city: "Ciudad de Mexico", cp: 554001 }
    ]

    payments_list = [
        { id: 0, name: "Visa", type: "debito", last_numbers: "178" },
        { id: 1, name: "Mastercad", type: "debito", last_numbers: "178" }
    ]

    user = {
        name: "Roy",
        mail: "roy@gmail.com",
    }
    res.render('userC/profileC', {
        user: user, 
        address_list: address_list,
        payments_list: payments_list 
    });
});

router.get('/editProfileC', (req, res) => {
    res.render('userC/editProfileC');
});
router.get('/addDirectionC', (req, res) => {
    res.render('userC/addDirectionC');
});
router.get('/addCardC', (req, res) => {
    res.render('userC/addCardC');
});
router.get('/shoppingCartC', (req, res) => {
    res.render('userC/shoppingCartC');
});


router.get('/shoppingDetails', (req, res) => {
    var subtotal = 500;
    const iva = 0.16;
    var tax = subtotal * iva;
    var total = subtotal + tax;

    addess_list = [
        { id: 0, name: "Casa", street: "Mar meditarraneo", number: "48", distrit: "Gustavo A. Madero", city: "Ciudad de Mexico", cp: 554001 },
        { id: 1, name: "Oficina", street: "Mar meditarraneo", number: "50", distrit: "Gustavo A. Madero", city: "Ciudad de Mexico", cp: 554001 }
    ]

    payments_list = [
        { id: 0, name: "Visa", type: "debito", last_numbers: "178" },
        { id: 1, name: "Mastercad", type: "debito", last_numbers: "178" }
    ]


    res.render('userC/shoppingDetails', {
        price: subtotal,
        tax: tax,
        total: total,
        addres_list: addess_list,
        payments_list: payments_list
    });
});


/* GET users listing. SELLER USER*/
router.get('/principalV', (req, res) => {
    user = {
        name: "Roy"
    };
    res.render('userV/principal',{
        user: user
    });
});

router.get('/profileV', (req, res) => {
    user = {
        name: "Roy"
    };
    res.render('userV/profile',{
        user: user
    });
});
module.exports = router;