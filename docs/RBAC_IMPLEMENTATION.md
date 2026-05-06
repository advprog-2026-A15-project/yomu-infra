# Role-Based Access Control Implementation

## Overview

This document describes the implementation of role-based access control (RBAC) for **Bacaan (Learning Materials)** and **Komentar (Comments)** in the Yomu microservices architecture.

## Architecture

### API Gateway

All requests from frontend go through the API Gateway (Port 8080) which routes them to the appropriate microservice:

- `/api/learning/**` → `service-learning` (Port 8082)
- `/api/forum/**` → `service-forum` (Port 8084)

### Authentication Flow

1. User logs in via `service-auth`
2. Receives JWT token containing:
    - `username` (subject)
    - `role` (ADMIN or USER)
    - `id` (userId)
3. Frontend sends JWT in `Authorization: Bearer <token>` header
4. `JwtAuthenticationFilter` (in shared-lib) validates and sets authentication context
5. Controllers use `@PreAuthorize` or custom authorization logic to check permissions

## Bacaan (Learning) Authorization

### Endpoints

| Endpoint                                      | Method | Role Required | Description                    |
| --------------------------------------------- | ------ | ------------- | ------------------------------ |
| `/api/learning/bacaan`                        | GET    | Public        | List all learning materials    |
| `/api/learning/bacaan/{id}`                   | GET    | Public        | Get specific learning material |
| `/api/learning/bacaan`                        | POST   | ADMIN         | Create new learning material   |
| `/api/learning/bacaan/{id}`                   | PUT    | ADMIN         | Update learning material       |
| `/api/learning/bacaan/{id}`                   | DELETE | ADMIN         | Delete learning material       |
| `/api/learning/bacaan/{bacaanId}/questions`   | GET    | Public        | Get quiz questions             |
| `/api/learning/questions`                     | POST   | ADMIN         | Add quiz question              |
| `/api/learning/questions/{questionId}`        | DELETE | ADMIN         | Delete quiz question           |
| `/api/learning/bacaan/{bacaanId}/quiz`        | POST   | Public        | Submit quiz answers            |
| `/api/learning/bacaan/{bacaanId}/quiz/status` | GET    | Public        | Check quiz completion status   |

### Implementation

- Located in: `service-learning/src/main/java/id/ac/ui/cs/advprog/yomu/learning/`
- Controllers: `BacaanController.java` with `@PreAuthorize("hasRole('ADMIN')")` annotations
- Security Config: `config/SecurityConfig.java` enables method security
- Only ADMIN role can create, update, or delete Bacaan and related quiz questions

### Example: Creating Bacaan (Admin Only)

```java
@PreAuthorize("hasRole('ADMIN')")
@PostMapping("/bacaan")
public ResponseEntity<Bacaan> createBacaan(
        @Valid @RequestBody CreateBacaanRequest request,
        Authentication auth) {
    String adminUserId = auth != null ? (String) auth.getCredentials() : "system";
    return ResponseEntity.status(HttpStatus.CREATED)
            .body(bacaanService.createBacaan(request, adminUserId));
}
```

## Komentar (Comments) Authorization

### Endpoints

| Endpoint                   | Method | Role Required | Who Can Act             | Description                                        |
| -------------------------- | ------ | ------------- | ----------------------- | -------------------------------------------------- |
| `/api/forum/comments`      | GET    | Public        | Anyone                  | Get all comments (optionally filtered by bacaanId) |
| `/api/forum/comments/tree` | GET    | Public        | Anyone                  | Get comments in tree structure                     |
| `/api/forum/comments`      | POST   | Authenticated | Any logged-in user      | Create new comment or reply                        |
| `/api/forum/comments/{id}` | PUT    | Authenticated | ADMIN or comment author | Update existing comment                            |
| `/api/forum/comments/{id}` | DELETE | Authenticated | ADMIN or comment author | Delete comment                                     |

### Implementation

- Located in: `service-forum/src/main/java/id/ac/ui/cs/advprog/yomu/forum/`
- Controllers: `CommentController.java` - custom authorization logic (not using `@PreAuthorize`)
- Service: `CommentServiceImpl.java` - performs authorization checks
- Security Config: `config/SecurityConfig.java` ensures authenticated access
- Authorization logic: Only comment author or ADMIN can edit/delete comments

### Example: Updating Comment (Author or Admin Only)

```java
@PutMapping("/{commentId}")
public CommentUpdatedEvent updateComment(
    @PathVariable String commentId,
    @Valid @RequestBody UpdateCommentRequest request,
    Authentication auth
) {
    String userId = auth != null ? (String) auth.getCredentials() : null;
    String role = auth != null ? auth.getAuthorities().stream()
        .map(a -> a.getAuthority().replace("ROLE_", ""))
        .findFirst().orElse(null) : null;
    return commentService.updateComment(commentId, request.commentContent(), userId, role);
}

// In CommentServiceImpl
@Override
@Transactional
public CommentUpdatedEvent updateComment(String commentId, String commentContent, String userId, String role) {
    Comment existingComment = getCommentOrThrow(commentId);

    // Authorization: only Admin or comment author can update
    if (!"ADMIN".equals(role) && !existingComment.getUserId().equals(userId)) {
        throw new ResponseStatusException(HttpStatus.FORBIDDEN,
            "Hanya admin atau penulis komentar yang bisa mengedit komentar ini");
    }
    // ... rest of update logic
}
```

## Security Configuration

### service-learning/config/SecurityConfig.java

- Enables `@EnableMethodSecurity(prePostEnabled = true)` for `@PreAuthorize` support
- Allows public access to GET endpoints for Bacaan and Questions
- Requires authentication for POST/PUT/DELETE operations
- JWT filter validates tokens and sets authorities

### service-forum/config/SecurityConfig.java

- Enables `@EnableMethodSecurity(prePostEnabled = true)`
- Allows public access to GET endpoints for Comments
- Requires authentication for POST/PUT/DELETE operations
- Custom logic in service layer for owner/admin checks

## Error Handling

### Backend Exception Handlers

#### service-learning/exception/GlobalExceptionHandler.java

```java
@ExceptionHandler(AccessDeniedException.class)
public ResponseEntity<ErrorResponse> handleAccessDenied(AccessDeniedException ex) {
    ErrorResponse error = new ErrorResponse(
        "Akses ditolak. Anda tidak memiliki otorisasi untuk melakukan operasi ini.",
        "AUTHORIZATION_DENIED",
        Instant.now().toEpochMilli(),
        HttpStatus.FORBIDDEN.value()
    );
    return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
}
```

Standard error response format:

```json
{
    "message": "Akses ditolak. Anda tidak memiliki otorisasi untuk melakukan operasi ini.",
    "errorCode": "AUTHORIZATION_DENIED",
    "status": 403,
    "timestamp": 1715000000000
}
```

### Frontend Error Handling

#### src/api/errorHandler.js

- `parseApiErrorResponse()`: Parses error response from API
- `isAuthorizationError()`: Checks if error is 403 Forbidden
- `getErrorMessage()`: Returns user-friendly error messages

#### Usage in Services

```javascript
try {
    const response = await fetch(url, { method: 'PUT', ... });
    return await readJsonOrThrow(response, 'Gagal mengedit...');
} catch (error) {
    if (error.status === 403) {
        // Show authorization error message
        showErrorNotification('Anda tidak memiliki izin untuk mengedit konten ini');
    }
}
```

## Frontend API Services

### src/features/learning/services/learningService.js

Provides these methods:

- `listBacaan(category)` - Get all learning materials
- `getBacaan(id)` - Get single material
- `createBacaan(data)` - Create material (requires ADMIN)
- `updateBacaan(id, data)` - Update material (requires ADMIN)
- `deleteBacaan(id)` - Delete material (requires ADMIN)
- `getQuestions(bacaanId)` - Get quiz questions
- `addQuestion(data)` - Add question (requires ADMIN)
- `deleteQuestion(questionId)` - Delete question (requires ADMIN)
- `submitQuiz(bacaanId, data)` - Submit quiz (any user)
- `checkQuizStatus(bacaanId, userId)` - Check completion (any user)

### src/features/forum/services/forumService.js

Provides these methods:

- `getComments(bacaanId)` - Get all comments (public)
- `getCommentsTree(bacaanId)` - Get nested comments (public)
- `createComment(data)` - Create comment (authenticated)
- `updateComment(commentId, content)` - Update comment (author or admin)
- `deleteComment(commentId)` - Delete comment (author or admin)

## JWT Token Structure

```json
{
    "sub": "user@example.com", // username
    "id": "uuid-of-user", // userId
    "role": "ADMIN", // or "USER"
    "iat": 1234567890,
    "exp": 1234654290
}
```

## Usage Examples

### Frontend: Create Learning Material (Admin Only)

```javascript
import { learningService } from "./services/learningService";

try {
    const newMaterial = await learningService.createBacaan({
        title: "Spring Boot Basics",
        content: "Learn Spring Boot fundamentals...",
        category: "Backend",
    });
    console.log("Created:", newMaterial);
} catch (error) {
    if (error.status === 403) {
        console.error("You are not an admin");
    }
}
```

### Frontend: Comment on Material (Any Authenticated User)

```javascript
import { forumService } from "./services/forumService";

try {
    const comment = await forumService.createComment({
        userId: "user-uuid",
        bacaanId: "material-uuid",
        commentContent: "Great material!",
        parentComment: "root",
    });
    console.log("Comment created:", comment);
} catch (error) {
    console.error("Failed to create comment:", error.message);
}
```

### Frontend: Edit Own Comment

```javascript
try {
    const updated = await forumService.updateComment(
        "comment-uuid",
        "Updated comment content",
    );
    console.log("Comment updated");
} catch (error) {
    if (error.status === 403) {
        console.error("Only the comment author or admin can edit");
    }
}
```

## Security Best Practices

1. **Always validate on backend**: Never trust frontend role checks alone
2. **Use JWT tokens**: Include in every request via `Authorization: Bearer <token>`
3. **Stateless authentication**: No session storage needed
4. **CORS configuration**: API Gateway allows requests only from `http://localhost:5173`
5. **Error messages**: Don't expose system details; use generic messages
6. **Authorization checks**: Perform both in controller and service layers

## Testing Authorization

### Test RBAC with curl

```bash
# Get list of materials (public)
curl http://localhost:8080/api/learning/bacaan

# Create material (requires ADMIN token)
curl -X POST http://localhost:8080/api/learning/bacaan \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"...","category":"Test"}'

# Update comment (requires token as author or admin)
curl -X PUT http://localhost:8080/api/forum/comments/<COMMENT_ID> \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"commentContent":"Updated content"}'
```

## Future Enhancements

1. **Role-based routes**: Add frontend route guards based on user role
2. **Permission management**: Admin dashboard for role assignments
3. **Audit logging**: Log all authorization attempts and changes
4. **Rate limiting**: Prevent abuse of creation/deletion endpoints
5. **Moderation system**: Allow moderators to flag/review content

---

Last Updated: May 6, 2026
