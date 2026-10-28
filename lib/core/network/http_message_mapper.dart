class HttpMessageMapper {
  static const Map<int, String> _messages = {
    200: "Everything is working fine.",
    201: "Your action was successful.",
    204: "Done! No extra data to show.",

    400: "Something went wrong with your request. Please try again.",
    401: "Please log in to continue.",
    403: "You don't have permission to access this.",
    404: "The page you're looking for can't be found.",
    409: "This action cannot be completed right now. Please try again.",

    500: "Something went wrong. Please try again later.",
    502: "Oops! Something went wrong. Please refresh the page.",
    503: "Oops! Something went wrong. Try again in a moment.",
    504: "Oops! Something went wrong. Please try again.",
  };

  static const Map<String, String> _successMessages = {
    'create_ticket': 'Ticket created successfully',
    'update_ticket': 'Ticket updated successfully',
    'assign_ticket': 'Ticket assigned successfully',
    'close_ticket': 'Ticket closed successfully',
    'delete_ticket': 'Ticket deleted successfully',
    'add_comment': 'Comment added successfully',
    'add_attachment': 'Attachments added successfully',
    'submit_feedback': 'Feedback submitted successfully',
    'change_status': 'Status changed successfully',
  };

  static String getMessage(int statusCode) {
    return _messages[statusCode] ?? "Unexpected error occurred.";
  }

  static String getSuccessMessage(String operation) {
    return _successMessages[operation] ?? "Operation completed successfully";
  }
}