# Forum API Testing Suite

Comprehensive test coverage for the comment reactions feature including backend (Java/Spring) and frontend (React) tests.

## Backend Tests

### CommentServiceImplTest

Located: `service-forum/src/test/java/.../CommentServiceImplTest.java`

Comprehensive unit tests for the `CommentServiceImpl` service layer covering:

**Comment Creation Tests:**

- `createComment_withValidData_shouldSaveAndPublishEvent()` — Validates comment creation and event publishing
- `createComment_withNullParent_shouldDefaultToRoot()` — Ensures null parent defaults to "root"
- `createComment_withBlankParent_shouldDefaultToRoot()` — Ensures blank parent defaults to "root"
- `createComment_withValidParentId_shouldAccept()` — Validates parent comment validation
- `createComment_withNonExistentParent_shouldThrow()` — Ensures error on invalid parent ID
- `createComment_withParentFromDifferentBacaan_shouldThrow()` — Ensures comments stay in same bacaan

**Reaction Tests:**

- `addReaction_shouldIncrementCounter()` — Verifies reaction counter increment
- `addReaction_withMultipleTypes()` — Tests all reaction types (upvote, heart, laugh, etc.)
- `addReaction_withNonExistentComment_shouldThrow()` — Ensures error on non-existent comment

**Get Comment Tests:**

- `getComment_shouldReturnCommentResponse()` — Validates comment retrieval with all fields
- `getComment_withNonExistentComment_shouldThrow()` — Ensures error handling

**List Comments Tests:**

- `listComments_shouldReturnAllComments()` — Tests fetching all comments
- `listComments_filterByBacaanId_shouldReturnFilteredComments()` — Tests filtering by bacaan
- `listComments_withEmptyBacaanId_shouldReturnAll()` — Tests edge case handling

**Tree Tests:**

- `listCommentsTree_shouldBuildTreeStructure()` — Validates comment tree construction

### CommentControllerTest

Located: `service-forum/src/test/java/.../CommentControllerTest.java`

Integration tests for HTTP endpoints using MockMvc:

**Create Comment Endpoint (POST /api/forum/comments):**

- `createComment_withValidRequest_shouldReturn201()` — Happy path with full request body
- `createComment_withoutParentComment_shouldDefaultToRoot()` — Tests optional parentComment field
- `createComment_withMissingField_shouldReturn400()` — Validates request validation

**Get Comments Endpoint (GET /api/forum/comments):**

- `getComments_withoutFilter_shouldReturnAll()` — Fetch all comments
- `getComments_filterByBacaanId_shouldReturnFiltered()` — Filter by bacaanId query param

**Get Comments Tree Endpoint (GET /api/forum/comments/tree):**

- `getCommentsTree_shouldReturnTreeStructure()` — Validates tree structure response

**Add Reaction Endpoint (POST /api/forum/comments/{commentId}/reactions):**

- `addReaction_withValidRequest_shouldReturn200()` — Happy path with authentication
- `addReaction_withMultipleTypes_shouldAllWork()` — Tests all reaction types
- `addReaction_withoutAuthentication_shouldReturn401()` — Validates authentication requirement

**Update/Delete Endpoints:**

- `updateComment_withValidRequest_shouldUpdate()` — PUT endpoint validation
- `deleteComment_withValidRequest_shouldDelete()` — DELETE endpoint validation
- `deleteComment_withoutAuthentication_shouldReturn401()` — Auth validation

## Frontend Tests

### forumService Tests

Located: `frontend/src/features/forum/services/forumService.test.js`

Unit tests for the `forumService` API client using Vitest:

**Get Comments:**

- `getComments_shouldFetchAllComments()` — Tests fetching without filter
- `getComments_filterByBacaanId()` — Tests filtering by bacaanId
- `getComments_throwsOnError()` — Error handling validation

**Get Comments Tree:**

- `getCommentsTree_shouldReturnTreeStructure()` — Tree structure fetch

**Create Comment:**

- `createComment_shouldCreateNewComment()` — Happy path
- `createComment_throwsOnFailure()` — Error handling

**Update/Delete:**

- `updateComment_shouldUpdateContent()` — PUT endpoint
- `deleteComment_shouldDelete()` — DELETE endpoint

**Add Reaction:**

- `addReaction_shouldAddReactionToComment()` — Happy path for all reaction types
- `addReaction_supportMultipleReactionTypes()` — Tests: upvote, downvote, thumbs_up, heart, laugh, surprise, sad
- `addReaction_throwsOnFailure()` — Error handling

### CommentItem Component Tests

Located: `frontend/src/features/forum/components/CommentItem.test.jsx`

React component tests using Vitest + React Testing Library:

**Rendering:**

- `shouldRenderCommentContentAndAuthor()` — Basic rendering
- `shouldRenderReactionButtonsWithInitialCounts()` — All 7 reaction buttons displayed

**User Interactions:**

- `shouldIncrementUpvoteCountWhenClicked()` — Click handling
- `shouldHandleHeartReaction()` — Alternative reaction type
- `shouldHandleLaughReaction()` — Another reaction type
- `shouldDisableButtonsWhileSaving()` — Disabled state during async
- `shouldSupportMultipleRapidClicks()` — Race condition prevention

**Error Handling:**

- `shouldRevertOptimisticUpdateOnError()` — Reverts UI on API failure
- `shouldDisplayToastOnError()` — Toast notification on failure

**Callbacks:**

- `shouldCallOnUpdateCallbackWithUpdatedComment()` — Parent component update

**Edge Cases:**

- `shouldHandleCommentWithUndefinedReactionFields()` — Graceful fallbacks
- `shouldSupportBothIdAndCommentIdProperties()` — Flexible property names
- `shouldSupportCommentAndCommentContentFieldNames()` — Field name flexibility

**Accessibility & Display:**

- `shouldDisplayTimestampInUserLocaleFormat()` — Timestamp formatting

### Toast Component Tests

Located: `frontend/src/components/Toast.test.jsx`

Unit and integration tests for the Toast notification system:

**Basic Functionality:**

- `shouldRenderToastMessageOnToastCall()` — Toast message display
- `shouldRenderSuccessToastWithSuccessClass()` — Type: success
- `shouldRenderErrorToastWithErrorClass()` — Type: error

**Lifecycle:**

- `shouldRemoveToastAfterDefaultTTL()` — Auto-dismiss after 3500ms
- `shouldSupportCustomTTL()` — Custom time-to-live

**Advanced:**

- `shouldRenderMultipleToastsConcurrently()` — Multiple notifications
- `shouldThrowErrorWhenUseToastIsUsedOutsideProvider()` — Hook validation

## Running Tests

### Backend Tests

```bash
# From service-forum directory
cd service-forum
./gradlew.bat test
```

### Frontend Tests

```bash
# From frontend directory
cd frontend
npm install  # Install testing dependencies (@testing-library/react, jsdom)
npm test     # Run vitest
```

## Test Coverage Summary

| Component         | Unit Tests | Integration Tests | Component Tests |
| ----------------- | ---------- | ----------------- | --------------- |
| CommentService    | 20+        | —                 | —               |
| CommentController | —          | 10+               | —               |
| forumService      | 15+        | —                 | —               |
| CommentItem       | —          | —                 | 15+             |
| Toast             | 8+         | —                 | —               |
| **Total**         | **43+**    | **10+**           | **15+**         |

## Key Testing Patterns

1. **Optimistic Updates** — CommentItem tests verify UI updates before API response
2. **Error Recovery** — Tests ensure UI reverts on API failures
3. **Race Conditions** — Rapid click tests prevent double-submission
4. **Mocking** — Extensive mocking of services and external dependencies
5. **Accessibility** — Toast and component tests verify user feedback mechanisms
6. **Integration** — Controller tests validate full HTTP request/response cycle

## Notes

- Backend tests use Mockito for mocking and JUnit 5 for assertions
- Frontend tests use Vitest for test runner and React Testing Library for component testing
- All tests are isolated and can run in any order
- Frontend tests require `jsdom` environment for DOM APIs
- Authentication tests validate Spring Security integration

## Future Enhancements

- E2E tests with Cypress/Playwright
- Performance benchmarking tests
- Load testing for comment reactions
- Accessibility (a11y) testing with axe-core
- Visual regression testing
