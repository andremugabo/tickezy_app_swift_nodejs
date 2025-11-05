/**
 * @swagger
 * tags:
 *   name: Payments
 *   description: API endpoints for creating, managing, filtering, and viewing event payments.
 */

/**
 * @swagger
 * /api/payments:
 *   post:
 *     summary: Create a new payment
 *     description: Allows an authenticated user to create a new payment for an event ticket. The `transactionId` is automatically generated if not provided.
 *     tags: [Payments]
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
 *               - ticketId
 *               - amount
 *               - paymentMethod
 *             properties:
 *               eventId:
 *                 type: string
 *                 format: uuid
 *                 description: Unique ID of the event being paid for.
 *                 example: 550e8400-e29b-41d4-a716-446655440000
 *               ticketId:
 *                 type: string
 *                 format: uuid
 *                 description: The associated ticket ID for this payment.
 *                 example: 123e4567-e89b-12d3-a456-426614174000
 *               amount:
 *                 type: number
 *                 format: double
 *                 description: Total amount to be charged.
 *                 example: 49.99
 *               paymentMethod:
 *                 type: string
 *                 enum: [STRIPE, APPLE_PAY]
 *                 description: The payment processor used.
 *                 example: STRIPE
 *               transactionId:
 *                 type: string
 *                 description: Optional external transaction reference (auto-generated if not provided).
 *                 example: txn_1NZxYJ2eZvKYlo2CeWkR2y0h
 *     responses:
 *       201:
 *         description: Payment created successfully.
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
 *                   example: Payment created successfully
 *                 payment:
 *                   $ref: '#/components/schemas/Payment'
 *       400:
 *         description: Invalid payment details or missing fields.
 *       401:
 *         description: Unauthorized (missing or invalid token).
 */

/**
 * @swagger
 * /api/payments:
 *   get:
 *     summary: Get all payments
 *     description: Retrieves all payments. Admins see all records; users only see their own.
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Payments retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 payments:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Payment'
 *       401:
 *         description: Unauthorized (missing or invalid token).
 *       500:
 *         description: Internal server error.
 */

/**
 * @swagger
 * /api/payments/{id}:
 *   get:
 *     summary: Get a payment by ID
 *     description: Retrieves details of a specific payment. Admins can access any; users only their own.
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Payment UUID
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Payment record retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 payment:
 *                   $ref: '#/components/schemas/Payment'
 *       404:
 *         description: Payment not found.
 */

/**
 * @swagger
 * /api/payments/{id}/status:
 *   put:
 *     summary: Update payment status
 *     description: Allows admins or staff to update a payment’s status (e.g., mark as SUCCESS or REFUNDED).
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Payment UUID
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
 *                 enum: [PENDING, SUCCESS, FAILED, REFUNDED]
 *                 example: SUCCESS
 *     responses:
 *       200:
 *         description: Payment status updated successfully.
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
 *                   example: Payment status updated successfully
 *                 payment:
 *                   $ref: '#/components/schemas/Payment'
 *       400:
 *         description: Invalid status or payment not found.
 *       403:
 *         description: Forbidden (insufficient permissions).
 */

/**
 * @swagger
 * /api/payments/{id}:
 *   delete:
 *     summary: Delete a payment
 *     description: Permanently deletes a payment record (admin only).
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Payment UUID
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Payment deleted successfully.
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
 *                   example: Payment deleted successfully
 *       404:
 *         description: Payment not found.
 *       403:
 *         description: Forbidden (admin only).
 */

/**
 * @swagger
 * /api/payments/filter/query:
 *   get:
 *     summary: Filter payments by status or date range
 *     description: Allows admins to filter payments for analytics, reporting, or reconciliation.
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: status
 *         in: query
 *         required: false
 *         description: Filter payments by status.
 *         schema:
 *           type: string
 *           enum: [PENDING, SUCCESS, FAILED, REFUNDED]
 *           example: SUCCESS
 *       - name: startDate
 *         in: query
 *         required: false
 *         description: Start date for filtering payments.
 *         schema:
 *           type: string
 *           format: date-time
 *           example: 2025-11-01T00:00:00.000Z
 *       - name: endDate
 *         in: query
 *         required: false
 *         description: End date for filtering payments.
 *         schema:
 *           type: string
 *           format: date-time
 *           example: 2025-11-04T23:59:59.000Z
 *     responses:
 *       200:
 *         description: Filtered payments retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 payments:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Payment'
 *       403:
 *         description: Forbidden (admin only).
 *       400:
 *         description: Invalid date range or query parameters.
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Payment:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           example: 550e8400-e29b-41d4-a716-446655440000
 *         userId:
 *           type: string
 *           format: uuid
 *           example: 321e4567-e89b-12d3-a456-426614174000
 *         eventId:
 *           type: string
 *           format: uuid
 *           example: 123e4567-e89b-12d3-a456-426614174000
 *         ticketId:
 *           type: string
 *           format: uuid
 *           example: 789e4567-e89b-12d3-a456-426614174000
 *         amount:
 *           type: number
 *           format: double
 *           example: 49.99
 *         status:
 *           type: string
 *           enum: [PENDING, SUCCESS, FAILED, REFUNDED]
 *           example: SUCCESS
 *         paymentMethod:
 *           type: string
 *           enum: [STRIPE, APPLE_PAY]
 *           example: STRIPE
 *         transactionId:
 *           type: string
 *           description: Automatically generated if not provided.
 *           example: TXN-abc123-1730743129345
 *         paymentDate:
 *           type: string
 *           format: date-time
 *           example: 2025-11-04T10:00:00.000Z
 *         createdAt:
 *           type: string
 *           format: date-time
 *           example: 2025-11-04T10:05:00.000Z
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           example: 2025-11-04T10:10:00.000Z
 *
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */
