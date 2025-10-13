# tickezy_app_swift_nodejs
Here’s a professional and comprehensive **README.md** template for your Tickezy backend project:

````markdown
# Tickezy Backend

Node.js & Express backend for **Tickezy**, a mobile ticketing app that allows users to browse, purchase, and manage event tickets securely. The backend provides authentication, profile management, and admin features.

---

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Running the App](#running-the-app)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## Features
- User registration and login with JWT authentication
- Password hashing with bcrypt
- Role-based access control (Admin / Customer)
- User profile management
- Swagger API documentation
- PostgreSQL database integration via Sequelize ORM

---

## Tech Stack
- Node.js
- Express.js
- PostgreSQL
- Sequelize ORM
- JWT for authentication
- Bcrypt for password hashing
- Swagger (swagger-jsdoc + swagger-ui-express)
- CORS support

---

## Installation

Clone the repository:

```bash
git clone https://github.com/andremugabo/tickezy_app_swift_nodejs.git
cd tickezy_backend
````

Install dependencies:

```bash
npm install
```

---

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Server
PORT=3000
NODE_ENV=development

# Database (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_db_password
DB_NAME=tickezyApp_db
DB_DIALECT=postgres

# JWT
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=1d

# Other settings
UPLOAD_FOLDER=uploads
```

---

## Database Setup

1. Ensure PostgreSQL is installed and running.
2. Create the database:

```sql
CREATE DATABASE tickezyApp_db;
```

3. Sequelize will automatically sync models with the database when the server starts.
   (Make sure your `User` model includes all required columns.)

---

## Running the App

Start the development server:

```bash
npm run dev
```

Visit `http://localhost:3000` to check if the server is running.

---

## API Documentation

Swagger API documentation is available at:

```
http://localhost:3000/api-docs
```

Endpoints include:

* `POST /api/users/register` - Register a new user
* `POST /api/users/login` - Log in
* `GET /api/users/profile` - Get logged-in user's profile
* `GET /api/users/all` - Get all users (Admin only)

---

## Project Structure

```
tickezy_backend/
│
├── src/
│   ├── controller/         # Controllers
│   ├── models/             # Sequelize models
│   ├── routes/             # Express routes
│   ├── services/           # Business logic & helpers
│   └── middleware/         # Authentication & authorization
│
├── db.js                   # Database connection (Sequelize)
├── server.js               # Entry point
├── swagger.js              # Swagger setup
├── package.json
├── .env
└── README.md
```

---

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License.

