const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const path = require('path'); // Add this import

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const setupSwagger = require('./swagger');
const userRoutes = require('./src/routes/userRoutes');
const eventRoutes = require('./src/routes/eventRoutes')

// Middleware
app.use(express.json());

// Enable CORS
app.use(cors({
  origin: '*', // Replace with your frontend URL in production
  methods: ['GET','POST','PUT','DELETE'],
}));

// ✅ ADD THIS LINE - Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/events', eventRoutes);

// Swagger
setupSwagger(app);

// Health check
app.get('/', (req, res) => {
  res.send('Tickezy App Backend is Healthy!!');
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));