router = require('express').Router()
router.get('/', (req, res) -> res.render('_root/index'))
module.exports = router