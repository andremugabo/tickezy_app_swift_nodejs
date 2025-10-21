/**
 * @swagger
 * tags:
 *   name: Tickets
 *   description: Endpoints for creating, managing, verifying, and viewing event tickets
 */

/**
 * @swagger
 * /api/tickets:
 *   post:
 *     summary: Create a new ticket
 *     description: Allows an authenticated user to purchase or generate a new event ticket.
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
 *                 description: The unique ID of the event this ticket belongs to.
 *                 example: 550e8400-e29b-41d4-a716-446655440000
 *               quantity:
 *                 type: integer
 *                 description: Number of tickets to create.
 *                 example: 2
 *     responses:
 *       201:
 *         description: Ticket(s) created successfully.
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
 *                   example: Ticket created successfully
 *                 ticket:
 *                   $ref: '#/components/schemas/Ticket'
 *       400:
 *         description: Invalid input or event not found.
 *       401:
 *         description: Unauthorized (missing or invalid token).
 */

/**
 * @swagger
 * /api/tickets:
 *   get:
 *     summary: Get all tickets
 *     description: Retrieves all tickets. Admins see all; regular users only see their own.
 *     tags: [Tickets]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Tickets retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 tickets:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Ticket'
 *       500:
 *         description: Internal server error.
 */

/**
 * @swagger
 * /api/tickets/{id}:
 *   get:
 *     summary: Get a ticket by ID
 *     description: Retrieve a specific ticket by its unique identifier.
 *     tags: [Tickets]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Ticket UUID
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Ticket retrieved successfully.
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
 *         description: Ticket not found.
 */

/**
 * @swagger
 * /api/tickets/{id}/status:
 *   put:
 *     summary: Update ticket status
 *     description: Allows admins or event staff to update the status of a ticket.
 *     tags: [Tickets]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Ticket UUID
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
 *                 enum: [VALID, USED, CANCELLED, REFUNDED]
 *                 example: USED
 *     responses:
 *       200:
 *         description: Ticket status updated successfully.
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
 *         description: Invalid status or ticket not found.
 *       403:
 *         description: Forbidden (insufficient permissions).
 */

/**
 * @swagger
 * /api/tickets/{id}:
 *   delete:
 *     summary: Delete a ticket
 *     description: Permanently remove a ticket from the system (admin only).
 *     tags: [Tickets]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Ticket UUID
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Ticket deleted successfully.
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
 *         description: Ticket not found.
 *       403:
 *         description: Forbidden (admin only).
 */

/**
 * @swagger
 * /api/tickets/verify:
 *   post:
 *     summary: Verify a ticket QR code
 *     description: Allows staff or admins to verify a ticket’s authenticity and mark it as used.
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
 *               - qrCode
 *             properties:
 *               qrCode:
 *                 type: string
 *                 description: The QR code string from the ticket.
 *                 example: TICKET-550e8400-e29b-41d4-a716-446655440000
 *     responses:
 *       200:
 *         description: Ticket verified successfully.
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
 *                   example: Ticket is valid and has been checked in.
 *                 ticket:
 *                   $ref: '#/components/schemas/Ticket'
 *       400:
 *         description: Invalid or expired QR code.
 *       404:
 *         description: Ticket not found.
 *       403:
 *         description: Unauthorized (staff/admin only).
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
 *           example: 321e4567-e89b-12d3-a456-426614174000
 *         status:
 *           type: string
 *           enum: [VALID, USED, CANCELLED, REFUNDED]
 *           example: VALID
 *         usedAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-20T15:00:00.000Z
 *         createdAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-19T10:00:00.000Z
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-19T11:00:00.000Z
 *
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */
