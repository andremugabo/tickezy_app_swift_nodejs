const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');


const options = {
    definition: {
      openapi: '3.0.0',
      info: { title: 'Backend API', version: '1.0.0', description: 'Tickezy App  APIs' },
      servers: [{ url: 'http://localhost:3000' }],
      components: {
        securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } },
      },
      security: [{ bearerAuth: [] }],
    },
    apis: ['./docs/swagger/*.js'],
  };
  
  const specs = swaggerJsDoc(options);
  
  function setupSwagger(app) {
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
  }
  
  module.exports = setupSwagger;