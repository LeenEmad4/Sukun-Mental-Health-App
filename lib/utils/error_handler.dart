import 'package:flutter/material.dart';

/// Converts a raw exception into a friendly, human-readable message.
String friendlyError(Object error) {
  final raw = error.toString().toLowerCase();

  // ── Authentication ──────────────────────────────────────────────────────
  if (raw.contains('invalid login credentials') ||
      raw.contains('invalid_credentials') ||
      raw.contains('wrong password') ||
      raw.contains('invalid password')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (raw.contains('email not confirmed') ||
      raw.contains('email_not_confirmed')) {
    return 'Please verify your email address before logging in.';
  }
  if (raw.contains('user already registered') ||
      raw.contains('already registered') ||
      raw.contains('already been registered')) {
    return 'An account with this email already exists.';
  }
  if (raw.contains('password should be at least') ||
      raw.contains('weak_password') ||
      raw.contains('password is too short')) {
    return 'Password must be at least 6 characters long.';
  }
  if (raw.contains('invalid email') ||
      raw.contains('email address is invalid') ||
      raw.contains('unable to validate email')) {
    return 'Please enter a valid email address.';
  }
  if (raw.contains('too many requests') ||
      raw.contains('over_email_send_rate_limit') ||
      raw.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (raw.contains('token has expired') ||
      raw.contains('refresh_token_not_found') ||
      raw.contains('session_not_found')) {
    return 'Your session has expired. Please log in again.';
  }
  if (raw.contains('user not found') || raw.contains('no user')) {
    return 'No account found with this email address.';
  }

  // ── Network ─────────────────────────────────────────────────────────────
  if (raw.contains('socketexception') ||
      raw.contains('failed host lookup') ||
      raw.contains('network is unreachable') ||
      raw.contains('connection refused') ||
      raw.contains('no address associated')) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (raw.contains('timeout') || raw.contains('timed out')) {
    return 'The request took too long. Please try again.';
  }

  // ── Database / Supabase ──────────────────────────────────────────────────
  if (raw.contains('duplicate key') ||
      raw.contains('unique_violation') ||
      raw.contains('unique constraint')) {
    return 'This information already exists.';
  }
  if (raw.contains('permission denied') ||
      raw.contains('row-level security') ||
      raw.contains('insufficient_privilege') ||
      raw.contains('violates row-level')) {
    return "You don't have permission to do that.";
  }
  if (raw.contains('foreign key') || raw.contains('foreign_key_violation')) {
    return 'A required record could not be found.';
  }
  if (raw.contains('not found') || raw.contains('no rows returned')) {
    return 'The requested information could not be found.';
  }
  if (raw.contains('server error') ||
      raw.contains('internal_server_error') ||
      raw.contains('500')) {
    return 'A server error occurred. Please try again later.';
  }

  // ── Generic fallback ────────────────────────────────────────────────────
  return 'Something went wrong. Please try again.';
}

/// Shows a styled error snackbar.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4D514A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Shows a styled success snackbar.
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF5E6F5C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
    ),
  );
}
