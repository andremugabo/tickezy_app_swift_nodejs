/**
 * @swagger
 * tags:
 *   name: Tickets
 *   description: Ticket creation, management, and viewing
 */

/**
 * @swagger
 * /api/tickets:
 *   post:
 *     summary: Create a new ticket
 *     tags: [Tickets]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - eventId
 *             properties:
 *               eventId:
 *                 type: string
 *                 format: uuid
 *                 example: 550e8400-e29b-41d4-a716-446655440000
 *               quantity:
 *                 type: integer
 *                 example: 2
 *               checkedInBy:
 *                 type: string
 *                 format: uuid
 *                 example: 123e4567-e89b-12d3-a456-426614174000
 *     responses:
 *       201:
 *         description: Ticket created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 ticket:
 *                   $ref: '#/components/schemas/Ticket'
 *       400:
 *         description: Invalid input or event not found
 */

/**
 * @swagger
 * /api/tickets:
 *   get:
 *     summary: Get all tickets
 *     tags: [Tickets]
 *     responses:
 *       200:
 *         description: List of tickets retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Ticket'
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/tickets/{id}:
 *   get:
 *     summary: Get a ticket by ID
 *     tags: [Tickets]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Ticket ID
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Ticket retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 ticket:
 *                   $ref: '#/components/schemas/Ticket'
 *       404:
 *         description: Ticket not found
 */

/**
 * @swagger
 * /api/tickets/{id}/status:
 *   put:
 *     summary: Update ticket status
 *     tags: [Tickets]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Ticket ID
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [USED, UNUSED]
 *                 example: USED
 *     responses:
 *       200:
 *         description: Ticket status updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 ticket:
 *                   $ref: '#/components/schemas/Ticket'
 *       400:
 *         description: Invalid input or ticket not found
 */

/**
 * @swagger
 * /api/tickets/{id}:
 *   delete:
 *     summary: Delete a ticket
 *     tags: [Tickets]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Ticket ID
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Ticket deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: Ticket deleted successfully
 *       404:
 *         description: Ticket not found
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Ticket:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           example: 550e8400-e29b-41d4-a716-446655440000
 *         eventId:
 *           type: string
 *           format: uuid
 *           example: 123e4567-e89b-12d3-a456-426614174000
 *         quantity:
 *           type: integer
 *           example: 2
 *         purchaseDate:
 *           type: string
 *           format: date-time
 *           example: 2025-10-19T10:00:00.000Z
 *         qrCodeURL:
 *           type: string
 *           example: data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...
 *         checkedInBy:
 *           type: string
 *           format: uuid
 *           example: 123e4567-e89b-12d3-a456-426614174000
 *         status:
 *           type: string
 *           enum: [USED, UNUSED]
 *           example: UNUSED
 *         createdAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-19T10:00:00.000Z
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-19T10:00:00.000Z
 *
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */
