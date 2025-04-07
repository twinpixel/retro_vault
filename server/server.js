const express = require('express');
const bodyParser = require('body-parser');

const objectsRoutes = require('./routes/objects');
const categoriesRoutes = require('./routes/categories');
const subcategoriesRoutes = require('./routes/subcategories');
const exhibitGroupingsRoutes = require('./routes/exhibit-groupings');
const acquisitionsRoutes = require('./routes/acquisitions');

const app = express();
const PORT = 3000;

app.use(bodyParser.json());  //  For parsing JSON request bodies

//  Mount the routes
app.use('/objects', objectsRoutes);
app.use('/categories', categoriesRoutes);
app.use('/subcategories', subcategoriesRoutes);
app.use('/exhibit-groupings', exhibitGroupingsRoutes);
app.use('/acquisitions', acquisitionsRoutes);

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});