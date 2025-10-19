/**
 * @swagger
 * tags:
 *   name: Events
 *   description: Event creation, management, and viewing
 */

/**
 * @swagger
 * /api/events:
 *   post:
 *     summary: Create a new event (Admin only)
 *     tags: [Events]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - location
 *               - eventDate
 *               - price
 *               - totalTickets
 *             properties:
 *               title:
 *                 type: string
 *                 example: Summer Music Festival
 *               description:
 *                 type: string
 *                 example: A fun outdoor concert featuring top Rwandan artists.
 *               location:
 *                 type: string
 *                 example: Kigali Arena
 *               eventDate:
 *                 type: string
 *                 format: date-time
 *                 example: 2025-12-25T18:00:00.000Z
 *               price:
 *                 type: number
 *                 example: 15000
 *               totalTickets:
 *                 type: integer
 *                 example: 500
 *               category:
 *                 type: string
 *                 enum: [CONCERT, SPORTS, CONFERENCE, THEATER, OTHER]
 *                 example: CONCERT
 *               image:
 *                 type: string
 *                 format: binary
 *               isPublished:
 *                 type: boolean
 *                 example: true
 *           encoding:
 *             image:
 *               contentType: ["image/png", "image/jpeg", "image/webp"]
 *     responses:
 *       201:
 *         description: Event created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 event:
 *                   $ref: '#/components/schemas/Event'
 *       400:
 *         description: Invalid input or unauthorized access
 */

/**
 * @swagger
 * /api/events/{id}:
 *   put:
 *     summary: Update an existing event (Admin only)
 *     tags: [Events]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: ID of the event to update
 *         schema:
 *           type: string
 *     requestBody:
 *       required: false
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Updated Summer Festival
 *               description:
 *                 type: string
 *                 example: Updated details for the event.
 *               location:
 *                 type: string
 *                 example: BK Arena
 *               eventDate:
 *                 type: string
 *                 format: date-time
 *                 example: 2025-12-25T20:00:00.000Z
 *               price:
 *                 type: number
 *                 example: 20000
 *               totalTickets:
 *                 type: integer
 *                 example: 800
 *               category:
 *                 type: string
 *                 enum: [CONCERT, SPORTS, CONFERENCE, THEATER, OTHER]
 *               status:
 *                 type: string
 *                 enum: [UPCOMING, ONGOING, COMPLETED, CANCELLED]
 *               isPublished:
 *                 type: boolean
 *                 example: true
 *               image:
 *                 type: string
 *                 format: binary
 *           encoding:
 *             image:
 *               contentType: ["image/png", "image/jpeg", "image/webp"]
 *     responses:
 *       200:
 *         description: Event updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 event:
 *                   $ref: '#/components/schemas/Event'
 *       400:
 *         description: Invalid input or unauthorized access
 */

/**
 * @swagger
 * /api/events:
 *   get:
 *     summary: Get all events (no filters)
 *     tags: [Events]
 *     description: Retrieve all events without applying any filters. Pagination is supported with page and limit.
 *     parameters:
 *       - name: page
 *         in: query
 *         required: false
 *         description: Page number for pagination
 *         schema:
 *           type: integer
 *           default: 1
 *           minimum: 1
 *       - name: limit
 *         in: query
 *         required: false
 *         description: Number of events per page
 *         schema:
 *           type: integer
 *           default: 10
 *           minimum: 1
 *     responses:
 *       200:
 *         description: List of all events retrieved successfully with pagination
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
 *                     $ref: '#/components/schemas/Event'
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                       example: 100
 *                     page:
 *                       type: integer
 *                       example: 1
 *                     limit:
 *                       type: integer
 *                       example: 10
 *                     totalPages:
 *                       type: integer
 *                       example: 10
 */



/**
 * @swagger
 * /api/events/{id}:
 *   get:
 *     summary: Get a specific event by ID
 *     tags: [Events]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: ID of the event
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Event retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 event:
 *                   $ref: '#/components/schemas/Event'
 *       404:
 *         description: Event not found
 */

/**
 * @swagger
 * /api/events/{id}:
 *   delete:
 *     summary: Delete an event (Admin only)
 *     tags: [Events]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: ID of the event to delete
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Event deleted successfully
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
 *                   example: Event deleted successfully
 *       401:
 *         description: Unauthorized or token missing
 *       403:
 *         description: Access denied (not an admin)
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Event:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           example: 550e8400-e29b-41d4-a716-446655440000
 *         title:
 *           type: string
 *           example: Summer Music Festival
 *         description:
 *           type: string
 *           example: An amazing concert with top artists
 *         location:
 *           type: string
 *           example: Kigali Arena
 *         eventDate:
 *           type: string
 *           format: date-time
 *           example: 2025-12-25T18:00:00.000Z
 *         price:
 *           type: number
 *           example: 15000
 *         totalTickets:
 *           type: integer
 *           example: 500
 *         ticketsSold:
 *           type: integer
 *           example: 200
 *         imageURL:
 *           type: string
 *           example: /uploads/events/1729012345678-image.jpg
 *         isPublished:
 *           type: boolean
 *           example: true
 *         category:
 *           type: string
 *           enum: [CONCERT, SPORTS, CONFERENCE, THEATER, OTHER]
 *           example: CONCERT
 *         status:
 *           type: string
 *           enum: [UPCOMING, ONGOING, COMPLETED, CANCELLED]
 *           example: UPCOMING
 *         createdAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-14T10:00:00.000Z
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           example: 2025-10-14T10:00:00.000Z
 *
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */
